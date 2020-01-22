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
  }.freeze

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
  }.freeze

  # The background and the foregrounds for a Theme can be from the predefined
  # BACKGROUNDS and FOREGROUNDS, or any valid color hex code
  #
  # foregrounds is an Array of hex codes
  def initialize(background = BACKGROUNDS[:black],
                 foregrounds = FOREGROUNDS[:ruby])
    @background = Color.from_hex(background)
    @foregrounds = foregrounds.map { |x| Color.from_hex(x) }

    # Because NArray can't handle the size of some ChunkyPNG::Color
    # values, create a Hash of the background and foreground colors,
    # where the key of the hash is an Integer, and the
    # value is the value of the color
    # Background has a key of 0, foregrounds have keys from 1..n
    colors = [@background] + @foregrounds
    colors_with_indices = colors.each_with_index.map do |color, idx|
      [idx, color]
    end
    @color_hash = Hash[colors_with_indices]
  end

  # Returns a new Theme using predefined colors
  #
  # background_sys is a symbol in BACKGROUNDS, and foreground_sym is
  # a symbol in FOREGROUNDS
  def self.from_syms(background_sym, foreground_sym)
    Theme.new(BACKGROUNDS[background_sym], FOREGROUNDS[foreground_sym])
  end

  # Returns a random predefined theme
  def self.random_theme
    THEMES[THEMES.keys.sample]
  end

  # Predefined themes
  THEMES = {
    ruby: Theme.from_syms(:black, :ruby),
    retro: Theme.from_syms(:dark_blue, :sunset),
    back_to_school: Theme.from_syms(:chalkboard, :primaries),
    peachy: Theme.from_syms(:peach, :primaries_light),
    gothic: Theme.from_syms(:gray, :gothic),
    teal: Theme.from_syms(:teal, :solar),
    orange: Theme.from_syms(:orange, :yellows),
    earth: Theme.from_syms(:brown, :earth),
    gray: Theme.from_syms(:gray_green, :faded)
  }.freeze

  # Returns the key for the background color
  def background_key
    # The background always has a key of 0
    0
  end

  # Returns a random @color_hash foreground key
  def random_foreground_key
    # (Slightly) speed up getting a foreground by returning the first
    # item if only one exists
    color = if @foregrounds.length == 1
              @foregrounds[0]
            else
              @foregrounds.sample
            end

    key_from_color(color)
  end

  # Returns the ChunkyPNG::Color value for a color key
  def color_from_key(key)
    @color_hash[key]
  end

  # Returns the key (in @color_hash) for a color value
  def key_from_color(color)
    @color_hash.key(color)
  end
end
