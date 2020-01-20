#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rubygems'
require 'commander/import'
require_relative 'wallpaper'
require_relative 'theme'

# Saves examples of wallpapers to the folder
def save_examples(folder)
  # Create example themes to be chosen randomly for each wallpaper
  themes = [
    {
      background: Theme::BACKGROUNDS[:black],
      foregrounds: Theme::FOREGROUNDS[:ruby]
    },
    {
      background: Theme::BACKGROUNDS[:dark_blue],
      foregrounds: Theme::FOREGROUNDS[:sunset]
    },
    {
      background: Theme::BACKGROUNDS[:chalkboard],
      foregrounds: Theme::FOREGROUNDS[:primaries]
    },
    {
      background: Theme::BACKGROUNDS[:peach],
      foregrounds: Theme::FOREGROUNDS[:primaries_light]
    },
    {
      background: Theme::BACKGROUNDS[:gray],
      foregrounds: Theme::FOREGROUNDS[:gothic]
    },
    {
      background: Theme::BACKGROUNDS[:teal],
      foregrounds: Theme::FOREGROUNDS[:solar]
    },
    {
      background: Theme::BACKGROUNDS[:orange],
      foregrounds: Theme::FOREGROUNDS[:yellows]
    },
    {
      background: Theme::BACKGROUNDS[:brown],
      foregrounds: Theme::FOREGROUNDS[:earth]
    },
    {
      background: Theme::BACKGROUNDS[:gray_green],
      foregrounds: Theme::FOREGROUNDS[:faded]
    }
  ].map { |x| Theme.new(x[:background], x[:foregrounds]) }

  # Example arguments to create wallpapers (theme will be added later)
  args = [
    { width: 20,  height: 20,  density: 0.5, pixel_diameter: 1 },
    { width: 20,  height: 20,  density: 5, pixel_diameter: 1 },
    { width: 20,  height: 20,  density: 10, pixel_diameter: 5 },
    { width: 100,  height: 100,  density: 0.5, pixel_diameter: 1 },
    { width: 100,  height: 100,  density: 10, pixel_diameter: 3 },
    { width: 500,  height: 500,  density: 5, pixel_diameter: 1 },
    { width: 828,  height: 1792,  density: 0.1, pixel_diameter: 5 }
  ]

  # Add a random theme to each set of args and create the wallpapers
  wallpapers = args.map do |arg_set|
    arg_set[:theme] = themes.sample
    Wallpaper.new(arg_set)
  end

  # Create the folder if it's missing
  if !Dir.exist?(folder)
    Dir.mkdir(folder)
  end

  # Save each example to the folder
  wallpapers.each_with_index do |example, index|
    filename = "#{folder}/example_#{index}.png"
    example.save(filename)
    puts "Wallpaper saved at #{filename}"
  end
end

program :name, 'virgo.rb'
program :version, '1.0.0'
program :description, 'Random wallpaper generator inspired by Virgo A'

# Save command
command :save do |c|
  c.syntax = './virgo.rb save PATH [options]'
  c.summary = 'Generate a wallpaper and save it at a location'
  c.example 'Save a random wallpaper with default options', './virgo.rb save'
  c.example 'Save a wallpaper with a white background and black pixels', './virgo.rb save --background "#ffffff" --foregrounds "#000000"'
  c.example 'Save a wallpaper with predefined theme names as test.png', './virgo.rb save --background dark_blue --foreground sunset --width 100 --height 100 --density 2 --diameter 1 --path test.png'
  c.option '--background BACKGROUND', String, 'Wallpaper background as a hexcode. Use list-backgrounds to list predefined background names'
  c.option '--foregrounds FOREGROUNDS', String, 'Wallpaper foregrounds as hexcodes separated by commans. Use list-foregrounds to list predefined foreground names'
  c.option '--width PIXELS', Integer, 'Width of the wallpaper'
  c.option '--height PIXELS', Integer, 'Height of the wallpaper'
  c.option '--density RATIO', Integer, 'Ratio of pixels to size of the image, as a percent integer'
  c.option '--diameter PIXELS', Integer, 'Diameter of each pixel drawn on the wallpaper'
  c.action do |args, options|
    # Default values for each option
    options.default background: Theme::BACKGROUNDS[:black],
                    foregrounds: Theme::FOREGROUNDS[:ruby],
                    width: 100,
                    height: 100,
                    density: 1,
                    diameter: 1,
                    path: 'output.png'

    # Get path from non-optional terminal args
    if args.length >= 2
      puts 'Error: Incorrect number of arguments. See --help for info'
      # Exit from command
      next
    end

    path = if args.length.zero?
             'output.png'
           else
             args[0]
           end

    # Get the predefined background if not a hexcode
    options.background = if options.background.include? '#'
                           options.background
                         else
                           Theme::BACKGROUNDS[options.background.to_sym]
                         end

    # Get the predefined foreground if not a hexcode
    options.foregrounds = if options.foregrounds.include? '#'
                            # Split the hexcodes into an array for the Wallpaper
                            # constructor
                            options.foregrounds.split(',')
                          elsif !options.foregrounds.is_a? Array
                            Theme::FOREGROUNDS[options.foregrounds.to_sym]
                          else
                            # If the foreground is an array, then it's already
                            # converted from the predefined color list
                            options.foregrounds
                          end

    # Create the wallpaper and save
    theme = Theme.new(options.background, options.foregrounds)
    wallpaper = Wallpaper.new(theme: theme, width: options.width,
                              height: options.height, density: options.density,
                              pixel_diameter: options.diameter)
    wallpaper.save(path)
    puts "Wallpaper saved at #{path}"
  end
end

# save_examples command
command :save_examples do |c|
  c.syntax = './virgo.rb save_examples FOLDER'
  c.summary = 'Saves examples of wallpapers to a folder'
  c.action do |args, _options|
    if args.length != 1
      puts 'Error: Incorrect number of arguments. See --help for info.'
      next
    end

    folder = args[0]
    save_examples(folder)
  end
end

# list_backgrounds command
command :list_backgrounds do |c|
  c.syntax = './virgo.rb list_backgrounds'
  c.summary = 'Lists the names and hexcodes of predefined backgrounds'
  c.action do |_args, _options|
    Theme::BACKGROUNDS.each_pair { |name, hex| puts "#{name}: #{hex}" }
  end
end

# list_foregrounds command
command :list_foregrounds do |c|
  c.syntax = './virgo.rb list_foregrounds'
  c.summary = 'Lists the names and hexcodes of predefined foregrounds'

  c.action do |_args, _options|
    Theme::FOREGROUNDS.each_pair { |name, hex| puts "#{name}: #{hex}" }
  end
end
