dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

require 'css_compare/constants'
require 'css_compare/exec'
require 'css_compare/util'
