# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'

require_relative 'wallpaper'
require_relative 'theme'

get '/' do
  erb :index
end

post '/gen-wallpaper' do
  @background = params['background']
  @foreground = params['foreground']
  @height = params['height'].to_i
  @width = params['width'].to_i
  t = Theme.new(@background, [@foreground])
  Wallpaper.new(theme: t, width: @width, height: @height).image.save('public/walls/1.png')
  return 'walls/1.png'
end
