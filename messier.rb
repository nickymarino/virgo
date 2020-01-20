# frozen_string_literal: true

require_relative 'wallpaper'
require_relative 'theme'

# Saves examples of wallpapers to the folder
def write_examples(folder = 'examples')
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
  end
end

write_examples
