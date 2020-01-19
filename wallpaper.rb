# frozen_string_literal: true

require 'chunky_png'

# A wallpaper implementation that creates an image during initialization.
# The image can be saved using +save+ or updated using +create_image+.
class Wallpaper
  include ChunkyPNG

  # Initializes a Wallpaper object and creates the image to be saved
  #
  # args:
  # - background_hex: Hex code for the color of the image background
  # - pixel_hexes: Array of possible hex codes for the pixel colors (randomly
  #     placed)
  # - width: Width of the image in pixels
  # - height: Height of the image in pixels
  # - density: Ratio of color pixels to background pixels (e.g., 5 = 5% of the
  #     image pixels are foreground colors)
  # - pixel_diameter: Diameter of each pixel (e.g., 3 means the pixel will be
  #     a 9x9 grid of pixels in the image)
  def initialize(args = {})
    args[:background_hex] ||= '#000000'
    args[:pixel_hexes] ||= ['#ffffff']
    args[:width] ||= 2048
    args[:height] ||= 2732
    args[:density] ||= 0.01 # percentage
    args[:pixel_diameter] ||= 3

    @background_rgb = Color.from_hex(args[:background_hex])
    *@pixel_colors = args[:pixel_hexes].map { |x| Color.from_hex(x) }
    @width = args[:width]
    @height = args[:height]
    @density = args[:density]
    @pixel_diameter = args[:pixel_diameter]

    create_image
  end

  # Creates an image representation of the wallpaper by drawing
  # the background then randomly inserting pixels of the foreground
  # color(s)
  def create_image
    @image = Image.new(@width, @height, @background_rgb)

    # Find how many pixels are to be converted into a different color
    number_pixels_to_place = @width * @height * (@density / 100)

    # For larger images, a very small percentage can be used that's not
    # appropriate for smaller images (such as 0.1 density for 2000x2000 vs
    # 400x400), so update the pixel count to 10% if the density was too small
    if number_pixels_to_place < 1
      number_pixels_to_place = @width * @height * 0.10
    end

    # Place the pixels
    (1..number_pixels_to_place).each { place_pixel }
  end

  # Overlays a pixel canvas on @image
  def place_pixel
    # Create a new canvas to replace a portion of the image with
    color = if @pixel_colors.length == 1
              @pixel_colors[0]
            else
              @pixel_colors.sample
            end

    pixel = Image.new(@pixel_diameter, @pixel_diameter, color)
    @image = @image.replace(pixel, pixel_coordinate.x, pixel_coordinate.y)
  end

  # Returns a random point within the image at which a pixel can
  # be placed. Returns a hash {x: x-coordinate, y: y-coordinate}, both
  # of which are Integers
  def pixel_coordinate
    # (x, y) determines the top-left corner of the new pixel
    # Set the max coordinate of the pixel based on the diameter
    x_max = @width - @pixel_diameter
    y_max = @height - @pixel_diameter
    x = rand(0...x_max)
    y = rand(0...y_max)

    Point.new(x, y)
  end

  # Saves @image with the filename
  def save(filename = 'output.png')
    @image.save(filename)
  end

  # Saves examples of wallpapers to the folder
  def self.write_examples(folder = 'examples')
    # Map hashes of arguments to create wallpapers
    examples = [
      { width: 400, height: 400, density: 0.5, pixel_diameter: 1 },
      { width: 400, height: 400, density: 0.5 },
      { width: 400,
        height: 400,
        density: 0.5,
        pixel_hexes: ['#00cdcd', '#800800', '#808000']
      }
    ].map { |args| Wallpaper.new(args) }

    # Create the folder if it's missing
    if !Dir.exist?(folder)
      Dir.mkdir(folder)
    end

    # Save each example
    examples.each_with_index do |example, index|
      filename = "#{folder}/example_#{index}.png"
      example.save(filename)
    end
  end
end
