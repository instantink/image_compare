[![Gem Version](https://badge.fury.io/rb/image_matcher.svg)](https://rubygems.org/gems/image_matcher)
[![Build](https://github.com/instantink/image_matcher/workflows/Build/badge.svg)](https://github.com/instantink/image_matcher/actions)

# ImageMatcher

Compare PNG images in pure Ruby (uses [ChunkyPNG](https://github.com/wvanbergen/chunky_png)) using different algorithms.
This is an utility library for image regression testing.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'image_matcher'
```

Or adding to your project:

```ruby
# my-cool-gem.gemspec
Gem::Specification.new do |spec|
  # ...
  spec.add_dependency 'image_matcher'
  # ...
end
```

Additionally, you may want to install [oily_png](https://github.com/wvanbergen/oily_png) to improve performance when using MRI. Just install it globally or add to your Gemfile.

## Modes

ImageMatcher supports different ways (_modes_) of comparing images.

Source images used in examples:

<img src='https://raw.githubusercontent.com/instantink/image_matcher/master/spec/fixtures/a.png' width='300' />
<img src='https://raw.githubusercontent.com/instantink/image_matcher/master/spec/fixtures/b.png' width='300' />

### Base (RGB) mode

Compare pixels by values, resulting score is a ratio of unequal pixels.
Resulting diff represents per-channel difference.

<img src='https://raw.githubusercontent.com/instantink/image_matcher/master/spec/fixtures/rgb_diff.png' width='300' />

### Grayscale mode

Compare pixels as grayscale (by brightness and alpha), resulting score is a ratio of unequal pixels (with respect to provided tolerance).

Resulting diff contains grayscale version of the first image with different pixels highlighted in red and red bounding box.

<img src='https://raw.githubusercontent.com/instantink/image_matcher/master/spec/fixtures/grayscale_diff.png' width='300' />

### Delta

Compare pixels using [Delta E](https://en.wikipedia.org/wiki/Color_difference) distance.
Resulting diff contains grayscale version of the first image with different pixels highlighted in red (with respect to diff score).

<img src='https://raw.githubusercontent.com/instantink/image_matcher/master/spec/fixtures/delta_diff.png' width='300' />

## Usage

```ruby
# create new matcher with default threshold equals to 0
# and base (RGB) mode
cmp = ImageMatcher::Matcher.new
cmp.mode #=> ImageMatcher::Modes::RGB

# create matcher with specific threshold
cmp = ImageMatcher::Matcher.new threshold: 0.05
cmp.threshold #=> 0.05

# or with a lower threshold (in case you want to test that there is some difference)
cmp = ImageMatcher::Matcher.new lower_threshold: 0.01
cmp.lower_threshold #=> 0.01

# create zero-tolerance grayscale matcher
cmp = ImageMatcher::Matcher.new mode: :grayscale, tolerance: 0
cmp.mode #=> ImageMatcher::Modes::Grayscale

res = cmp.compare(path_1, path_2)
res #=> ImageMatcher::Result
res.match? #=> true
res.score #=> 0.0

# Return diff image object
res.difference_image #=> ImageMatcher::Image
res.difference_image.save(new_path)

# without explicit matcher
res = ImageMatcher.compare(path_1, path_2, options)

# equals to
res = ImageMatcher::Matcher.new(options).compare(path_1, path_2)
```

## Excluding rectangle

<img src='https://raw.githubusercontent.com/instantink/image_matcher/master/spec/fixtures/a.png' width='300' />
<img src='https://raw.githubusercontent.com/instantink/image_matcher/master/spec/fixtures/a1.png' width='300' />

You can exclude rectangle from comparing by passing `:exclude_rect` to `compare`.
E.g., if `path_1` and `path_2` contain images above
```ruby
ImageMatcher.compare(path_1, path_2, exclude_rect: [200, 150, 275, 200]).match? # => true
```
`[200, 150, 275, 200]` is array of two vertices of rectangle -- (200, 150) is left-top vertex and (275, 200) is right-bottom.

## Including rectangle

You can set bounds of comparing by passing `:include_rect` to `compare` with array similar to previous example

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/instantink/image_matcher.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
