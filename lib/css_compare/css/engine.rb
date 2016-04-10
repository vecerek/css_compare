require 'yaml'
require 'json'

module CssCompare
  module CSS
    # The CSS Engine that computes the values of the
    # properties under all the declared conditions in
    # the stylesheet.
    #
    # It can handle:
    #   - simple property overriding
    #   - property overriding with !import
    #   - @media queries overriding
    #
    # However, the last is not 100% reliable, since
    # the media query is not interpreted and evaluated
    # by the engine. The query is stringified as a whole,
    # instead and used as the key for selector-property
    # pairs.
    class Engine
      # The inner representation of the computed properties
      # of each selector under every condition specified by
      # the declared @media directives.
      #
      # @return [Hash<Symbol, Array<Component::Selector, String>]
      attr_accessor :engine

      # A list of nodes, that could not be evaluated due to
      # being not supported by this engine.
      #
      # @return [Array<Sass::Tree::Node>] unsupported CSS nodes
      attr_accessor :unsupported

      attr_accessor :selectors, :keyframes, :namespaces,
                  :pages, :supports, :charset

      def initialize(input)
        @tree = Parser.new(input).parse.freeze if input.is_a?(String)
        @tree = input.freeze if input.is_a?(Sass::Tree::Node)
        @engine = {}
        @selectors = {}
        @keyframes = {}
        @namespaces = {}
        @pages = {}
        @supports = {}
        @unsupported = []
        @charset
      end

      # Computes the values of each declared selector's properties
      # under each condition declared by the @media directives.
      #
      # @return [Void]
      def evaluate!
        @tree.children.each do |node|
          if node.is_a?(Sass::Tree::MediaNode)
            process_media_node(node)
          elsif node.is_a?(Sass::Tree::RuleNode)
            process_rule_node(node)
          elsif node.is_a?(Sass::Tree::DirectiveNode)
            if node.is_a?(Sass::Tree::SupportsNode)
              process_supports_node(node)
            elsif node.name
              case node.name
                when '@keyframes'
                  process_keyframes_node(node)
                when '@namespace'
                  process_namespace_node(node)
                when '@page'
                  #puts node.to_yaml
                  process_page_node(node)
                else
                  # Unsupported DirectiveNodes, that have a name property
                  @unsupported << node
              end
            else
              # Unsupported DirectiveNodes, that do not have a name property
              @unsupported << node
            end
          elsif node.is_a?(Sass::Tree::CharsetNode)
            process_charset_node(node)
          else
            # Unsupported Node
            @unsupported << node
          end
        end
        @engine[:selectors] = @selectors
        @engine[:keyframes] = @keyframes
        @engine[:namespaces] = @namespaces
        @engine[:pages] = @pages
        @engine[:supports] = @supports
        @engine[:charset] = @charset
        self
      end

      # Returns the inner representation of the processed
      # CSS stylesheet.
      #
      # @return [Hash]
      def to_json
        engine = {
            :selectors => [],
            :keyframes => [],
            :namespaces => @namespaces,
            :pages => [],
            :supports => [],
            :charset => @charset
        }
        @selectors.inject(engine[:selectors]) {|arr, (_,s)| arr << s.to_json }
        @keyframes.inject(engine[:keyframes]) {|arr, (_,k)| arr << k.to_json }
        @pages.inject(engine[:pages]) {|arr, (_,p)| arr << p.to_json }
        @supports.inject(engine[:supports]) {|arr, (_,s)| arr << s.to_json}
        engine
      end

      # Creates a deep copy of this object.
      #
      # @return [Engine]
      def deep_copy
        copy = dup
        copy.selectors = @selectors.inject({}) do |result,(k,v)|
          result.update(k => v.deep_copy)
        end
        copy.keyframes = @keyframes.inject({}) do |result,(k,v)|
          result.update(k => v.deep_copy)
        end
        #copy.pages = {}
        copy.supports = @supports.inject({}) do |result,(k,v)|
          result.update(k => v.deep_copy)
        end
        copy.engine = {
            :selectors => copy.selectors,
            :keyframes => copy.keyframes,
            :namespaces => copy.namespaces,
            :pages => copy.pages,
            :supports => copy.supports
        }
        copy
      end

      private

      # Processes the queries of the @media directive and
      # starts processing its {Sass::Tree::RulesetNode}.
      #
      # @param [Sass::Tree::MediaNode] node the node
      #   representing the @media directive.
      # @return [Void]
      def process_media_node(node)
        queries = node.resolved_query.queries.inject([]) {|queries, q| queries << q.to_css}
        rules = node.children
        rules.each do |child|
          if child.is_a?(Sass::Tree::RuleNode)
            process_rule_node(child, queries)
          elsif child.is_a?(Sass::Tree::DirectiveNode)
            process_keyframes_node(child, queries) if child.name == '@keyframes'
          end
        end
      end

      # Processes the {Sass::Tree::RuleNode} and saves the selectors
      # with their properties accordingly to its parenting media queries
      # in a reasonable data structure.
      #
      # @note Only one of the comma-separated selector sequences gets
      #   created as a new instance of {Component::Selector}. Since the
      #   whole group of selectors share the same property declaration
      #   block, there's no need to analyze the block again by instantiating
      #   each of the selectors. A deep copy should be done instead with
      #   a small change in the the selector's name.
      #
      # @param [Sass::Tree:RuleNode] node the Rule node
      # @param [Array<String>] conditions processed conditions of the
      #   parent media node. If the rule is global, it will be assigned
      #   to the media query equal to `@media all {}`.
      # @return [Void]
      def process_rule_node(node, conditions = ['all'])
        selectors = selector_sequences(node)
        selector = Component::Selector.new(selectors.shift, node.children, conditions)
        save_selector(selector)
        selectors.each do |name|
          save_selector(selector.deep_copy(name))
        end
      end

      # Saves the selector and its properties.
      # If the selector already exists, it merges its properties
      # with the existent selector's properties.
      #
      # @see {Component::Selector#merge}
      # @return [Void]
      def save_selector(selector)
        if @selectors[selector.name]
          @selectors[selector.name].merge(selector)
        else
          @selectors[selector.name] = selector
        end
      end

      # Returns the comma-separated selectors.
      #
      # @param [Sass::Tree::RuleNode] node the node representing
      #   a CSS rule (group of selectors + declaration of properties).
      # @return [Array<String>] array of selectors sharing the same
      #   block of properties.
      def selector_sequences(node)
        node.parsed_rules.members.inject([]) {|selectors, sequence| selectors << optimize_sequence(sequence)}
      end

      # Optimizes a CSS selector selector, a selector separated
      # by empty strings, like input#id.class[type="text"]:first-child,
      # in two ways:
      #
      #   1. gets rid of redundancy:
      #     Example:
      #       ".a.h.c.e.c" => ".a.h.c.e"
      #
      #   2. puts the simple sequences' nodes in alphabetical order
      #     Example:
      #       ".a.h.c > .div.elem[type='text'].col" => ".a.c.h > .col.div.elem[type='text']"
      #
      # `basket`'s keys are in a specific order.
      # 1. Universal selector (*) should be the first in order.
      #    It shouldn't be followed by any element selector,
      #    whereas ids, classes and pseudo classes can follow it.
      #
      # 2. An element selector should go before any other
      #    selector, except the universal.
      #
      # 3. Id can follow an element selector, as well as
      #    a class selector. To unify the compared selectors
      #    a strict order had to be created.
      #
      # 4. Class selectors.
      #
      # 5. Placeholder selectors are a special type found in
      #    Sass code and are not a part of the CSS selectors.
      #    I included it just for the sake of completeness.
      #
      # 6. Pseudo selectors should be the last in the order.
      #
      # 7. Attribute selectors do not have their own place
      #    in the order. They get tied to the preceding
      #    selector.
      #
      # @param [Sass::Selector::Sequence] selector a node
      # representing a selector sequence.
      # @return [String] optimized selector.
      def optimize_sequence(selector)
        selector.members.inject([]) do |final, sequence|
          if sequence.is_a?(Sass::Selector::SimpleSequence)
            baskets = {
                Sass::Selector::Universal => [],
                Sass::Selector::Element => [],
                Sass::Selector::Id => [],
                Sass::Selector::Class => [],
                Sass::Selector::Placeholder => [],
                Sass::Selector::Pseudo => []
            }
            sequence.members.each_with_index do |simple, i|
              last = i + 1 == sequence.members.length
              if !last && sequence.members[i + 1].is_a?(Sass::Selector::Attribute)
                baskets[simple.class] << simple.to_s + sequence.members[i + 1].to_s
                sequence.members.delete_at(i + 1)
              else
                baskets[simple.class] << simple.to_s
              end
            end
            final << baskets.values.inject([]) {|partial, b| partial + b.uniq.sort}.join('')
          else
            final << sequence.to_s
          end
        end.join(' ')
      end

      # Processes and evaluates the {Sass::Tree::KeyframeRuleNode}.
      #
      # An @keyframe directive can't be extended by later re-declarations.
      # However, you can bend their behaviour by declaring keyframes
      # under different @media queries. The browser then keeps track of
      # different keyframes declarations under the same name. Like it would
      # be namespaced. But still, the re-declarations do not extend the
      # original @keyframe.
      #
      # Example:
      #   @keyframes my-value {
      #     from { top: 0px; }
      #     to   { top: 100px; }
      #   }
      #   @media (max-width: 600px) {
      #     @keyframes my-value {
      #       50% { top: 50px; }
      #     }
      #   }
      #
      #   The keyframe under the media query WON'T be interpreted like this:
      #   @media (max-width: 600px) {
      #     @keyframes my-value {
      #       from { top: 0px; }
      #       50%  { top: 50px; }
      #       to   { top: 100px; }
      #     }
      #   }
      #
      # @param [Sass::Tree::DirectiveNode] node the node containing
      #   information about and the keyframe rules of the @keyframes
      #   directive.
      # @return [Void]
      def process_keyframes_node(node, conditions = ['all'])
        keyframes = Component::Keyframes.new(node, conditions)
        save_keyframes(keyframes)
      end

      # Saves the keyframes into the collection.
      # If keyframes already exists, merges it with
      # the existing value.
      #
      # @return [Void]
      def save_keyframes(keyframes)
        if @keyframes[keyframes.name]
          @keyframes[keyframes.name].merge(keyframes)
        else
          @keyframes[keyframes.name] = keyframes
        end
      end

      # Processes the charset directive, if present.
      def process_charset_node(node)
        @charset = node.name
      end

      # Unifies the namespace by replacing the ' or " characters with an
      # empty space if the namespace name is given by a URL.
      # The namespaces declaration without any specified prefix value are
      # automatically assigned to the default namespace.
      #
      # "If a namespace prefix or default namespace is declared more than
      # once only the last declaration shall be used. Declaring a namespace
      # prefix or default namespace more than once is nonconforming."
      # @see https://www.w3.org/TR/css3-namespace/#prefixes
      #
      # @param [Sass::Tree::DirectiveNode] node the namespace node
      # @return [Void]
      def process_namespace_node(node)
        values = node.value[1].strip.split(/\s+/)
        values = values.unshift('default') if values.length == 1
        values[1].gsub!(/("|')/, '') if values[1] =~ /^url\(("|').+("|')\)$/
        @namespaces.update(values[0].to_sym => values[1])
      end

      def process_page_node(node, conditions = ['all'])
        selectors = node.value[1].strip.split(/,\s+/)
        page_selector = Component::PageSelector.new(selectors.shift, node.children, conditions)
        save_page_selector(page_selector)
        selectors.each do |selector|
          save_page_selector(page_selector.deep_copy(selector))
        end
      end

      def save_page_selector(page_selector)
        if @pages[page_selector.value]
          @pages[page_selector.value].merge(page_selector)
        else
          @pages[page_selector.value] = page_selector
        end
      end

      # Processes and saves a {SupportsNode}.
      #
      # @see {Component::Supports}
      # @param [Sass::Tree::SupportsNode] node
      # @return [Void]
      def process_supports_node(node)
        supports = Component::Supports.new(node)
        save_supports(supports)
      end

      def save_supports(supports)
        if @supports[supports.name]
          @supports[supports.name].merge(supports)
        else
          @supports[supports.name] = supports
        end
      end
    end
  end
end