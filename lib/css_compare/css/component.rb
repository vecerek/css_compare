require 'css_compare/css/component/value'
require 'css_compare/css/component/property'
require 'css_compare/css/component/selector'
require 'css_compare/css/component/keyframes_selector'
require 'css_compare/css/component/keyframes'
require 'css_compare/css/component/supports'
require 'css_compare/css/component/margin_box'
require 'css_compare/css/component/page_selector'
require 'css_compare/css/component/font_face'

module CssCompare
  module CSS
    module Component
      # Creates a new {Sass::Tree::RootNode}.
      #
      # @param [Array<Sass::Tree::Node>] children the child nodes
      #   of the newly created node.
      # @param [Hash] options node options
      # @return [Sass::Tree::RootNode]
      def root_node(children, options)
        root = Sass::Engine.new('').to_tree
        root.options = options
        root.children = children.is_a?(Array) ? children : [children]
        root
      end

      # Creates a new {Sass::Tree::MediaNode} from scratch.
      #
      # @param [Array<String, Sass::Media::Query>] query the
      #   list of media queries
      # @param [Sass::Tree::Node] children (see #root_node)
      # @param [Hash] options (see #root_node)
      # @return [Sass::Tree::MediaNode]
      def media_node(query, children, options)
        media_node = Sass::Tree::MediaNode.new(query)
        media_node.options = options
        media_node.line = 1
        media_node = Sass::Tree::Visitors::Perform.visit(media_node)
        media_node.children = children
        media_node
      end
    end
  end
end
