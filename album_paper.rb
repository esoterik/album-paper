require 'sinatra'
require './AlbumArtScraper'

configure do
  set :server, :puma
end

get '/' do
  erb :index
end

post '/gen' do
  erb :gen
end

get '/gen/:artist/:width/:height/?:singles?' do
  params[:singles] ||= "off"
  singles =  ( params[:singles] == "on" )
  images = AlbumArtScraper::Discogs::scrape_images(params[:artist].gsub('_', ' '), singles)
  if images
    gen = AlbumArtScraper::WallpaperGen.new(params[:width].to_i, params[:height].to_i, images)
    gen.generate
    gen.wallpaper.to_blob
  end
end

