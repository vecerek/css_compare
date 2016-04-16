# css_compare

Processes, evaluates and compares 2 CSS files based on their AST. The repository has been created in order to be able to test the [less2sass](https://github.com/vecerek/less2sass) project. The program returns `true` or `false` to the `$stdout`, so far.
Uses the Sass parser to get the CSS files' AST.

Supported CSS features:
- all types of selectors (they are normalized - duplicity removal and logical/alphabetical ordering)
- @media, partially
- @import (lazy loading of imported css files, that can be found, otherwise ignored)
- @font-face
- @namespace
- @charset
- @keyframes
- @page
- @supports, partially

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'css-compare'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install css-compare

## Usage
Command line usage:

    $ css_compare CSS_FILE_1 CSS_FILE_2
    
Programmatic usage:

```ruby
opts = {
    :operands => ["path/to/file1.css", "path/to/file2.css"]
}
result = CssCompare::Engine.new(opts)
                   .parse!
                   .equal?
```

## TODO

- Evaluate shorthand properties, so the values of base properties get overridden.
- Evaluate @media rule's and @supports rule's conditions.
- Output the difference, optionally.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/vecerek/css_compare.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

