# frozen_string_literal: true

require 'chunky_png'
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

    create_image
  end

  # Creates an image representation of the wallpaper by drawing
  # the background then randomly inserting pixels of the foreground
  # color(s)
  def create_image
    @image = Image.new(@width, @height, @theme.background)

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
    # Create a new canvas
    pixel = Image.new(@pixel_diameter, @pixel_diameter, @theme.foreground)

    # Replace the old image with the new canvas at the pixel coordinate
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
end
