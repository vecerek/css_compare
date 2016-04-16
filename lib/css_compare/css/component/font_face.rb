module CssCompare
  module CSS
    module Component
      # Represents the @font-face directive.
      #
      # Multiple @font-face rules can be used to construct
      # font families with a variety of faces. Each @font-face
      # rule specifies a value for every font descriptor,
      # either implicitly or explicitly. Those not given explicit
      # values in the rule take the initial value listed with
      # each descriptor in the w3.org specification.
      #
      # If multiple declarations of @font-face rules, that share
      # the same `font-family` and `src` values are present, the last
      # declaration overrides the other.
      #
      # `Font-family` property is saved downcased, since the user
      # agents, when matching font-family names, do it in
      # a case-insensitive manner.
      #
      # @see https://www.w3.org/TR/css-fonts-3/#font-face-rule
      class FontFace < Base
        attr_reader :declarations

        # @param [Array<Sass::Tree::PropNode>] children font properties
        def initialize(children)
          @declarations = {}
          init_declarations
          process_declarations(children)
        end

        # Checks, whether two @font-face declarations are equal.
        #
        # No need to check, whether both font-faces have the same
        # keys, since they are also initialized with the default
        # values.
        #
        # @param [FontFace] other the @font-face to compare this
        #   with.
        def ==(other)
          @declarations.all? { |k, _| @declarations[k] === other.declarations[k] }
        end

        # Tells, whether this rule is valid or not.
        #
        # @font-face rules require a font-family and src descriptor;
        # if either of these are missing, the @font-face rule is
        # invalid and must be ignored entirely.
        #
        # @return [Boolean]
        def valid?
          family && src
        end

        # @return [String, nil] font-family name, if set
        def family
          @declarations['font-family']
        end

        # @return [String, nil] the source of the font if set
        def src
          @declarations['src']
        end

        # Creates the JSON representation of this object.
        #
        # @return [Hash]
        def to_json
          @declarations
        end

        private

        INITIAL_VALUES = {
          :font_family => {
            :default => nil
          },
          :src => {
            :default => nil
          },
          :font_style => {
            :default => 'normal',
            :allowed => %w(normal italic oblique)
          },
          :font_weight => {
            :default => '400',
            :allowed => %w(normal bold 100 200 300 400 500 600 700 800 900),
            :synonyms => {
              :normal => '400',
              :bold => '600'
            }
          },
          :font_stretch => {
            :default => 'normal',
            :allowed => %w(normal ultra-condensed extra-condensed condensed semi-condensed semi-expanded expanded
                           extra-expanded ultra-expanded)
          },
          :unicode_range => {
            :default => 'U+0-10FFFF'
          },
          :font_variant => {
            :default => 'normal'
          },
          :font_feature_settings => {
            :default => 'normal'
          },
          :font_kerning => {
            :default => 'auto',
            :allowed => %w(auto normal none)
          },
          :font_variant_ligatures => {
            :default => 'normal'
          },
          :font_variant_position => {
            :default => 'normal',
            :allowed => %w(normal sub super)
          },
          :font_variant_caps => {
            :default => 'normal',
            :allowed => %w(normal small-caps all-small-caps petite-caps all-petite-caps unicase titling-caps)
          },
          :font_variant_numeric => {
            :default => 'normal'
          },
          :font_variant_alternates => {
            :default => 'normal'
          },
          :font_variant_east_asian => {
            :default => 'normal'
          },
          :font_language_override => {
            :default => 'normal'
          }

        }.freeze

        # Initializes the font-face with values from
        # the official specifications.
        #
        # @return [Void]
        def init_declarations
          INITIAL_VALUES.each { |k, v| @declarations[k.to_s.tr('_', '-')] = v[:default] }
        end

        # Processes the @font-face declarations and set
        # the values if:
        #   1. the property processed is a valid font-face property
        #   2. the property has a valid value
        # If the property's value is not valid, it falls back to
        # the default one.
        #
        # @param [Array<Sass::Tree::PropNode>] children
        # @return [Void]
        def process_declarations(children)
          children.each do |child|
            next unless child.is_a?(Sass::Tree::PropNode)
            name = child.resolved_name
            value = child.resolved_value
            key = name.tr('-', '_').to_sym
            property = INITIAL_VALUES[key]
            next unless property
            @declarations[name] = value.downcase if name == 'font-family'
            @declarations[name] = value.gsub(/'|"/, '') if name == 'src'
            next if name == 'font-family' || name == 'src'
            @declarations[name] = value
            allowed_values = property[:allowed]
            next unless allowed_values
            if allowed_values.include?(value)
              @declarations[name] = get_synonym(property, value.to_sym) || value
            else
              @declaration[name] = property[:default]
            end
          end
        end

        # Returns the synonym for a property's value.
        #
        # @example
        #   get_synonym(INITIAL_VALUES[:font-weight], [:bold]) #=> '600'
        #
        # @return [String, nil] a string, if a synonym exists
        #                       nil otherwise
        def get_synonym(property, key)
          return unless property[:synonyms] && property[:synonyms].include?(key)
          property[:synonyms][key]
        end
      end
    end
  end
end
