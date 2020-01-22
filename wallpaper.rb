# frozen_string_literal: true

require 'chunky_png'
require 'narray'
require_relative 'distribution'
require_relative 'theme'

# A wallpaper implementation that creates an image during initialization.
# The image can be saved using +save+ or updated using +create_image+.
class Wallpaper
  include ChunkyPNG

  # Initializes a Wallpaper object and creates the image to be saved
  #
  # args:
  # - theme: Instance of Theme to set the background and foreground colors
  # - width: Width of the image in pixels
  # - height: Height of the image in pixels
  # - density: Ratio of color pixels to background pixels (e.g., 5 = 5% of the
  #     image pixels are foreground colors)
  # - pixel_diameter: Diameter of each pixel (e.g., 3 means the pixel will be
  #     a 9x9 grid of pixels in the image)
  # - x_normal_mean: Enables a normal distribution of the pixel x-coordinates
  #     The mean is the mean of the normal distribution. If nil, uses a uniform
  #     distribution.
  # - y_normal_mean: Enables a normal distribution of the pixel y-coordinates
  #     The mean is the mean of the normal distribution. If nil, uses a uniform
  #     distribution.
  def initialize(args = {})
    args[:theme] ||= Theme.new
    args[:width] ||= 2048
    args[:height] ||= 2732
    args[:density] ||= 0.01 # percentage
    args[:pixel_diameter] ||= 3

    @theme = args[:theme]
    @width = args[:width]
    @height = args[:height]
    @density = args[:density]
    @pixel_diameter = args[:pixel_diameter]

    # Set the pixel x- and y-coordinate distributions
    @x_distribution = dist_from_mean(args[:x_normal_mean], @width)
    @y_distribution = dist_from_mean(args[:y_normal_mean], @height)

    # Generate a map (NArray of Integers) to represent the image
    @map = create_map
  end

  # Initializes the (uniform or normal) distribution for
  # generating random pixel coordinates
  #
  # If mean is set, a normal distribution is used with a mean of
  # +dimension+. Otherwise, a uniform distribution is used with
  # a mean of +dimension+ / 2
  #
  # +dimension+ is the dimension for the distribution, which can either be
  # @width or @height
  def dist_from_mean(mean, dimension)
    # (x, y) determines the top-left corner of the new pixel,
    # so the maximum value of x or y must be the maximum point
    # allowed by the image dimensions less the pixel diameter
    max = dimension - @pixel_diameter - 1

    # Minimum is always 0, because pixels can't be placed out of the image
    min = 0

    # If mean is nil, return a uniform distribution
    if mean
      # Std conversion factor is a "magic" number for getting a "pretty"
      # standard deviation based on the height/width parameter
      std_conversion = 0.125
      std = dimension * std_conversion
      Distribution.new(mean, min, max, std)
    else
      Distribution.from_dim(max)
    end
  end

  # Creates a representation of the wallpaper as a map of Integers
  # in an array. Returns an NArray, where the values are ChunkyPNG::Colors,
  # and each row in @map is a row in the ChunkyPNG::Image
  def create_map
    # Start with each pixel in the image as the background color
    map = NArray.int(@width, @height).fill!(@theme.background_key)

    # Place each pixel in the map
    count = number_pixels_to_place
    (1..count).each do
      # Determine pixel location
      x = @x_distribution.random_point
      x_max = x + @pixel_diameter
      y = @y_distribution.random_point
      y_max = y + @pixel_diameter

      # Replace the pixel in the map with a new (random) color
      map[x..x_max, y..y_max] = @theme.random_foreground_key
    end

    map
  end

  # Returns the number of pixels are to be converted into a different color
  def number_pixels_to_place
    # (Total available pixels) * (percentage of total pixels to add)
    pixel_count = @width * @height * (@density / 100)

    # For larger images, a very small percentage can be used that's not
    # appropriate for smaller images (such as 0.1 density for 2000x2000 vs
    # 400x400), so update the pixel count to 10% if the density was too small
    if pixel_count < 1
      @width * @height * 0.10
    else
      pixel_count
    end
  end

  # Returns a ChunkyPNG::Image of @map
  #
  # Use .image.save(filename) to save an image of the Wallpaper instance
  def image
    img = Image.new(@width, @height, Color::TRANSPARENT)

    # Put each row of @map into the image
    num_rows = @map.shape[1]
    (0...num_rows).each do |row_idx|
      # Create a Ruby Array so that 'large' Integers can be used
      # (Typical Integer range of ChunkyPNG::Color isn't supported
      # by NArray))
      row = @map[true, row_idx].to_a

      # Find the color value for each key in the row
      row.map! { |key| @theme.color_from_key(key) }

      # Replace the row in the image with the new colors
      img.replace_row!(row_idx, row)
    end

    img
  end
end
