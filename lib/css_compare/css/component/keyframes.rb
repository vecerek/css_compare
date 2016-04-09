module CssCompare
  module CSS
    module Component
      # Represents an @keyframes declaration
      class Keyframes
        # The name of the keyframes.
        #
        # @return [String] the name
        attr_reader :name

        # The rules of the keyframe grouped by
        # @media query conditions.
        #
        # Rules' example structure:
        #   {
        #     'all' => {
        #       '0%'   => {KeyframeSelector},
        #       '100%' => {KeyframeSelector}
        #     },
        #     '(max-width: 600px)' => {
        #       '0%'   => {KeyframeSelector},
        #       '50%'  => {KeyframeSelector},
        #       '100%' => {KeyframeSelector}
        #     }
        #   }
        #
        # @return [Hash{String => Hash{String => KeyframeSelector}}]
        attr_reader :rules

        def initialize(node, conditions)
          @name = node.value[1]
          process_conditions(conditions, process_rules(node.children))
        end

        # Merges this selector with another one.
        #
        # The new declaration of the keyframe under the same
        # condition rewrites the previous one. No deep_copy
        # needs to be made and the value can be passed by
        # reference.
        #
        # @param [Keyframes] keyframes the keyframes to
        #   extend this one.
        # @return [Void]
        def merge(keyframes)
          keyframes.rules.each do |condition, selector|
            @rules[condition] = selector
          end
        end

        # Creates the JSON representation of this keyframes.
        #
        # @return [Hash]
        def to_json
          json = { :name => @name.to_sym, :rules => {} }
          @rules.each do |cond, rules|
            cond = cond.to_sym
            json[:rules][cond] = {}
            rules.each do |value, rule|
              json[:rules][cond][value.to_sym] = rule.to_json
            end
          end
          json
        end

        # Assigns the processed rules to the passed conditions
        # By reference. No deep copy needed, as the {KeyframeSelector}s
        # won't be altered or merged with another {KeyframeSelector},
        # since this feature is missing at @keyframe directives.
        #
        # @return [Hash{String => Hash}]
        # @see `@rules`
        def process_conditions(conditions, keyframe_rules)
          @rules = conditions.inject({}) do |kf, condition|
            kf.update(condition => keyframe_rules)
          end
        end

        # Processes the keyframe rules and creates their
        # internal representation.
        #
        # @return [Hash{String => KeyframeSelector}]
        def process_rules(rule_nodes)
          rule_nodes.inject({}) do |rules, node|
            rule = Component::KeyframesSelector.new(node)
            rules.update(rule.value => rule)
          end
        end
      end
    end
  end
end