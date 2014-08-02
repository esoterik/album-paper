require 'sinatra'
require './AlbumArtScraper'

get '/' do
  erb :index
end

post '/gen' do
  erb :gen
end

get '/gen/:artist/:width/:height' do
  images = AlbumArtScraper::Discogs::scrape_images(params[:artist], false)
  gen = AlbumArtScraper::WallpaperGen.new(params[:width].to_i, params[:height].to_i, images) if images
  gen.generate
  gen.wallpaper.to_blob
end

