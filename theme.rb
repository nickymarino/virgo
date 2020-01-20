# frozen_string_literal: true

require 'chunky_png'

# Includes a background color and one or more foreground colors, each
# of type ChunkyPNG::Color. For a Wallpaper, the background is the base
# color and the foreground colors determine the color of the pixels
#
# Predefined backgrounds and foreground collections are provided as
# examples
class Theme
  include ChunkyPNG

  # Predefined background colors
  BACKGROUNDS = {
    black: '#000000',
    white: '#ffffff',
    dark_blue: '#355c7d',
    chalkboard: '#2a363b',
    peach: '#ff8c94',
    gray: '#363636',
    teal: '#2f9599',
    orange: 'ff4e50',
    brown: '#594f4f',
    gray_green: '#83af9b'
  }

  # Predefined foreground color sets
  FOREGROUNDS = {
    white: ['#ffffff'],
    ruby: ['#8d241f', '#a22924', '#b72f28', '#cc342d', '#d4453e', '#d95953',
           '#de6d68'],
    sunset: ['#f8b195', '#f67280', '#c06c84', '#6c5b7b'],
    primaries: ['#99b898', '#feceab', '#ff847c', '#e84a5f'],
    primaries_light: ['#a8e6ce', '#bcedc2', '#ffd3b5', '#ffaaa6'],
    gothic: ['#a8a7a7', '#cc527a', '#e8175d', '#474747'],
    solar: ['#a7226e', '#ec2049', '#f26b38', '#9dedad'],
    yellows: ['#e1f5c4', '#ede574', '#f9d423', '#fc913a'],
    earth: ['#e5fcc2', '#9de0ad', '#45ada8', '#547980'],
    faded: ['#fe4365', '#fc9d9a', '#f9cdad', '#c8c8a9']
  }

  # The background and the foregrounds for a Theme can be from the predefined
  # BACKGROUNDS and FOREGROUNDS, or any valid color hex code
  #
  # foregrounds is an Array of hex codes
  def initialize(background = BACKGROUNDS[:black],
                 foregrounds = FOREGROUNDS[:ruby])
    @background = Color.from_hex(background)
    @foregrounds = foregrounds.map { |x| Color.from_hex(x) }
  end

  attr_reader :background

  # Returns a random foreground from @foregrounds
  def foreground
    # (Slightly) speed up getting a foreground by returning the first
    # item if only one exists
    if @foregrounds.length == 1
      @foregrounds[0]
    else
      @foregrounds.sample
    end
  end
end
