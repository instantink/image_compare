[![Gem Version](https://badge.fury.io/rb/image_compare.svg)](https://rubygems.org/gems/image_compare)
[![Build](https://github.com/instantink/image_compare/workflows/Build/badge.svg)](https://github.com/instantink/image_compare/actions)

# ImageCompare

Compare PNG images in pure Ruby (uses [ChunkyPNG](https://github.com/wvanbergen/chunky_png)) using different algorithms.
This is an utility library for image regression testing.

## Installation

Add this line to your application"s Gemfile:

```ruby
gem "image_compare"
```

Or adding to your project:

```ruby
# my-cool-gem.gemspec
Gem::Specification.new do |spec|
  # ...
  spec.add_dependency "image_compare"
  # ...
end
```

Additionally, you may want to install [oily_png](https://github.com/wvanbergen/oily_png) to improve performance when using MRI. Just install it globally or add to your Gemfile.

## Modes

ImageCompare supports different ways (_modes_) of comparing images.

Source images used in examples:

a1.png

<img alt="a.png" src="spec/fixtures/a.png" />

b.png

<img alt="b.png" src="spec/fixtures/b.png" />

a1.png

<img alt="a1.png" src="spec/fixtures/a1.png" />

### Base (Color) mode (a.png X a1.png)

Compare pixels, resulting score is a ratio of unequal pixels (with respect to provided tolerance).

Resulting diff contains version of the first image with different pixels highlighted in red and red bounding box.

<img alt="color_diff" src="spec/fixtures/color_diff.png" />

### RGB mode (a.png X b.png)

Compare pixels by values, resulting score is a ratio of unequal pixels.
Resulting diff represents per-channel difference.

<img alt="rgb_diff.png" src="spec/fixtures/rgb_diff.png" />

### Grayscale mode (a.png X a1.png)

Compare pixels as grayscale (by brightness and alpha), resulting score is a ratio of unequal pixels (with respect to provided tolerance).

Resulting diff contains grayscale version of the first image with different pixels highlighted in red and red bounding box.

<img alt="grayscale_diff.png" src="spec/fixtures/grayscale_diff.png" />

### Delta (a.png X a1.png)

Compare pixels using [Delta E](https://en.wikipedia.org/wiki/Color_difference) distance.
Resulting diff contains grayscale version of the first image with different pixels highlighted in red (with respect to diff score).

<img alt="delta_diff.png" src="spec/fixtures/delta_diff.png" />

## Usage

```ruby
# Create new matcher with default threshold equals to 0
# and base (Color) mode
cmp = ImageCompare::Matcher.new
cmp.mode #=> ImageCompare::Modes::Color

# Create new matcher with default threshold equals to 0
# and base (RGB) mode
cmp = ImageCompare::Matcher.new mode: :rgb
cmp.mode #=> ImageCompare::Modes::RGB

# Create matcher with specific threshold
cmp = ImageCompare::Matcher.new threshold: 0.05
cmp.threshold #=> 0.05

# or with a lower threshold (in case you want to test that there is some difference)
cmp = ImageCompare::Matcher.new lower_threshold: 0.01
cmp.lower_threshold #=> 0.01

# Create zero-tolerance grayscale matcher
cmp = ImageCompare::Matcher.new mode: :grayscale, tolerance: 0
cmp.mode #=> ImageCompare::Modes::Grayscale

res = cmp.compare("path/image1.png", "path/image2.png")
res #=> ImageCompare::Result
res.match? #=> true
res.score #=> 0.0

# Return diff image object
res.difference_image #=> ImageCompare::Image
res.difference_image.save(result)

# without explicit matcher
res = ImageCompare.compare("path/image1.png", "path/image2.png", options)
res.match? #=> true
res.score #=> 0.0

# equals to
res = ImageCompare::Matcher.new(options).compare("my_images_path/image1.png", "my_images_path/image2.png")
res.match? #=> true
res.score #=> 0.0
```

## Excluding rectangle (a.png X a1.png)

<img alt="a1.png" src="spec/fixtures/rgb_exclude_rect.png" />

You can exclude rectangle from comparing by passing `:exclude_rect` to `compare`.
E.g., if `path_1` and `path_2` contain images above
```ruby
ImageCompare.compare("path/image1.png", "path/image2.png", mode: :rgb, exclude_rect: [200, 150, 275, 200]).match? # => true

# or

cmp = ImageCompare::Matcher.new mode: :rgb, exclude_rect: [200, 150, 275, 200]
res = cmp.compare("path/image1.png", "path/image2.png")
res #=> ImageCompare::Result
res.match? #=> true
res.score #=> 0.0

# Return diff image object
res.difference_image #=> ImageCompare::Image
res.difference_image.save("path/diff.png")
```
`[200, 150, 275, 200]` is array of two vertices of rectangle -- (200, 150) is left-top vertex and (275, 200) is right-bottom.

### Cucumber + Capybara example
`support/env.rb`:
```ruby
require "image_compare"
```

`support/capybara_extensions.rb`:
```ruby
# frozen_string_literal: true

Capybara::Node::Element.class_eval do
  def rect_area
    rect_area = self.evaluate_script("this.getBoundingClientRect()") # rubocop:disable Style/RedundantSelf

    [
      rect_area["left"].to_f.round,
      rect_area["top"].to_f.round,
      rect_area["right"].to_f.round,
      rect_area["bottom"].to_f.round
    ]
  rescue StandardError => e # rubocop:disable Style/RescueStandardError
    raise "Error getting element rect area: #{e.inspect}!"
  end
end
```

`steps/my_step.rb`:
```ruby
my_element = page.find("#my_element").rect_area

cmp = ImageCompare::Matcher.new exclude_rect: my_element.rect_area
res = cmp.compare("path/image1.png", "path/image2.png")
res.difference_image.save("path/diff.png")

expect(res.match?).to eq(true)
```

## Including rectangle

You can set bounds of comparing by passing `:include_rect` to `compare` with array similar to previous example

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/instantink/image_compare.

### Running tests and code inspections

- `rake rubocop`
- `rake rubocop:md`
- `rake spec`
- `ruby examples/performance.rb` Create the "gemfile.local" file with the content below to run the performance tests:
```ruby
# frozen_string_literal: true

source "https://rubygems.org"
gem "benchmark-ips", "~> 2.7", ">= 2.7.2"
```


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
