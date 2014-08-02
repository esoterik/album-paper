require 'sinatra'
require './AlbumArtScraper'

get '/' do
  erb :index
end

post '/gen' do
  images = AlbumArtScraper::Discogs::scrape_images(params[:artist], false)
  @gen = AlbumArtScraper::WallpaperGen.new(params[:width].to_i, params[:height].to_i, images) if images
  @gen.generate
  erb :gen
end
