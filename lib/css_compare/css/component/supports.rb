module CssCompare
  module CSS
    module Component
      # Represents the @support CSS rule.
      #
      # @see https://www.w3.org/TR/css3-conditional/#at-supports
      class Supports
        include CssCompare::CSS::Component
        
        # The name of the @support directive.
        # Can be browser-prefixed.
        #
        # @return [String]
        attr_reader :name

        # The assigned rules grouped by the @supports'
        # conditions.
        #
        # @supports van contain the same rules as a CSS
        # stylesheet. Why not to create a new engine for it?
        #
        # @return [Hash{String => CssCompare::CSS::Engine}]
        attr_accessor :rules

        # @param [Sass::Tree::SupportsNode] node
        # @param [Array<String>] query_list the query list of
        #   the parent node (the conditions under which this
        #   node is evaluated).
        def initialize(node, query_list = [])
          @name = node.name
          @rules = {}
          condition = node.condition.to_css.gsub(/\s*!important\s*/, '')
          unless query_list.empty?
            media_node = media_node([Engine::GLOBAL_QUERY], node.children, node.options)
            node = root_node(media_node, node.options)
          end
          rules = CssCompare::CSS::Engine.new(node).evaluate(nil, query_list)
          @rules[condition] = rules
        end

        # Merges this @supports rule with another one.
        #
        # @param [Supports] other
        # @return [Void]
        def merge(other)
          other.rules.each do |cond, engine|
            if @rules[cond]
              merge_selectors(engine.selectors, cond)
              merge_keyframes(engine.keyframes, cond)
              merge_namespaces(engine.namespaces, cond)
              merge_supports(engine.supports, cond)
            else
              @rules[cond] = engine
            end
          end
        end

        # Returns a deep copy of this object.
        #
        # @return [Supports]
        def deep_copy(name = @name)
          copy = dup
          copy.name = name
          copy.rules = {}
          @rules.each {|k,v| copy.rules[k] = v.deep_copy }
          copy
        end

        # Creates the JSON representation of this object.
        #
        # @return [Hash]
        def to_json
          json = { :name => @name.to_sym, :rules => {} }
          @rules.inject(json[:rules]) do |result,(k,v)|
            result.update(k => v.to_json)
          end
          json
        end

        private

        def merge_selectors(selectors, cond)
          loc_selectors = @rules[cond].selectors
          selectors.each do |key, selector|
            if loc_selectors[key]
              loc_selectors[key].merge(selector)
            else
              loc_selectors[key] = selector.deep_copy
            end
          end
        end

        def merge_keyframes(keyframes, cond)
          loc_keyframes = @rules[cond].keyframes
          keyframes.each do |key, value|
            if loc_keyframes[key]
              loc_keyframes[key].merge(value)
            else
              loc_keyframes[key] = value.deep_copy
            end
          end
        end

        def merge_namespaces(namespaces, cond)
          loc_namespaces = @rules[cond].namespaces
          namespaces.each do |key, value|
            loc_namespaces[key] = value
          end
        end

        def merge_supports(supports, cond)
          loc_supports = @rules[cond].supports
          supports.each do |key, value|
            if loc_supports[key]
              loc_supports[key].merge(value)
            else
              loc_supports[key] = value.deep_copy
            end
          end
        end
      end
    end
  end
end