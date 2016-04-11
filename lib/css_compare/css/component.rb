require 'css_compare/css/component/value'
require 'css_compare/css/component/property'
require 'css_compare/css/component/selector'
require 'css_compare/css/component/keyframes_selector'
require 'css_compare/css/component/keyframes'
require 'css_compare/css/component/supports'
require 'css_compare/css/component/margin_box'
require 'css_compare/css/component/page_selector'

module CssCompare
  module CSS
    module Component
      def media_node(query, children, options)
        media_node = Sass::Tree::MediaNode.new(query)
        media_node.options = options
        media_node.line = 1
        media_node = Sass::Tree::Visitors::Perform.visit(media_node)
        media_node.children = children
      end

      def root_node(children)
        root = Sass::Engine.new('').to_tree
        root.children = children.is_a?(Array) ? children : [children]
        root
      end
    end
  end
end
