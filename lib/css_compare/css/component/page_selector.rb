module CssCompare
  module CSS
    module Component
      # Represents @page directive's page selector
      # (`:right`, `LandscapeTable`, `CompanyLetterHead:first`)
      # combined with the page body, that can contain a
      # list of declarations and a list of page margin boxes.
      #
      # The declarations not assigned to any margin symbol
      # will be automatically grouped under the global
      # margin symbol.
      #
      # @see https://www.w3.org/TR/css3-page/
      class PageSelector
        # The value of this page selector
        #
        # @return [String]
        attr_accessor :value

        # The margin box directives containing
        # the declarations.
        #
        # @return [Hash{String => MarginBox}]
        attr_accessor :margin_boxes

        # The global margin symbol.
        GLOBAL_MARGIN_SYMBOL = '@all'

        # @param [String] value the page selector
        # @param [Array<Sass::Tree::Node>] children page body
        # @param [Array<String>] conditions applying media query conditions
        def initialize(value, children, conditions)
          @value = value
          @margin_boxes = {}
          process_margin_boxes(children, conditions)
        end

        # Merges this page selector with another one.
        #
        # @param [PageSelector]
        # @return [Void]
        def merge(other)
          other.margin_boxes.each do |_,prop|
            add_margin_box(prop, true)
          end
        end

        # Creates a deep copy of this page selector.
        #
        # @param [String] value the new value of
        #   the selector's copy.
        # @return [PageSelector] a copy of self
        def deep_copy(value = @value)
          copy = dup
          copy.value = value
          copy.margin_boxes = @margin_boxes.inject({}) do |result,(k,v)|
            result.update(k => v.deep_copy)
          end
          copy
        end

        # Creates the JSON representation of this page selector.
        #
        # @return [Hash]
        def to_json
          json = { selector: @value, margin_boxes: [] }
          @margin_boxes.inject(json[:margin_boxes]) do |result,(k,v)|
            result << v.to_json
          end
          json
        end

        private

        # Adds a new or updates an already existing margin box.
        #
        # @param [MarginBox] margin_box the margin box to be added
        # @param [Boolean] deep_copy checks whether the margin_box
        #   should be added by reference or its deep copied value.
        def add_margin_box(margin_box, deep_copy = false)
          if @margin_boxes[margin_box.name]
            @margin_boxes[margin_box.name].merge(margin_box)
          else
            if deep_copy
              @margin_boxes[margin_box.name] = margin_box.deep_copy
            else
              @margin_boxes[margin_box.name] = margin_box
            end
          end
        end

        # Processes and evaluates the page body.
        #
        # @param [Array<Sass::Tree::Node>] nodes (see #initialize)
        # @param [Array<String>] conditions (see #initialize)
        def process_margin_boxes(nodes, conditions)
          nodes.each do |node|
            if node.is_a?(Sass::Tree::PropNode)
              margin_box = GLOBAL_MARGIN_SYMBOL
              children = [node]
            elsif node.is_a?(Sass::Tree::DirectiveNode)
              margin_box = node.resolved_value
              children = node.children
            else
              next #just ignore these nodes
            end
            add_margin_box(MarginBox.new(margin_box, children, conditions))
          end
        end
      end
    end
  end
end