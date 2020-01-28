# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'

require_relative 'wallpaper'
require_relative 'theme'

get '/' do
  erb :index
end

post '/gen-wallpaper' do
  background = params['background']
  height = params['height'].to_i
  width = params['width'].to_i

  foreground_params = params.select { |k, _| k.to_s.match(/^foreground\d+/) }
  foregrounds = foreground_params.values
  puts foregrounds.to_s

  t = Theme.new(background, foregrounds)
  Wallpaper.new(theme: t, width: width, height: height).image.save('public/walls/1.png')
  return 'walls/1.png'
end
