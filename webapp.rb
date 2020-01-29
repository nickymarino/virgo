# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pry'

require_relative 'framework/wallpaper'
require_relative 'framework/theme'

get '/' do
  erb :index, locals: { wallpaper: default_wallpaper }
end

# Returns a link to a generated wallpaper given params according
# to the Wallpaper class
post '/wallpaper-link' do
  background = params['background']
  height = params['height'].to_i
  width = params['width'].to_i

  foreground_params = params.select { |k, _| k.to_s.match(/^foreground\d+/) }
  foregrounds = foreground_params.values
  puts foregrounds.to_s

  t = Theme.new(background, foregrounds)
  Wallpaper.new(theme: t,
                width: width,
                height: height,
                ).image.save('public/walls/1.png')
  return 'walls/1.png'
end

# Returns a wallpaper with default settings for the index page to show
# on load
def default_wallpaper
  theme = Theme.from_syms(:black, :dark_violet)
  Wallpaper.new(theme: theme,
                width: 1920,
                height: 1080,
                create_map: false)
end
