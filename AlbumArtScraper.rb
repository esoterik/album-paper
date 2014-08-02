require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'RMagick'

module AlbumArtScraper
  class Discogs

    # takes an artist name, searches discogs, returns array of Magick::Images if successful
    # singles is a boolean that determines whether or not to include art from single releases
    def self.scrape_images(artist, singles)

      # search discogs for artist
      search_results = search(artist)

      # results are ordered by relevance ; first one should be the one we want
      art_urls = get_art_urls(search_results.first)
      
      # populate array of Magick::Images
      images = Array.new
      art_urls.each { |url| images.push(Magick::Image::read(url).first) }

      images
    end

    # searches discogs for an artist's page, returns array of partial urls 
    def self.search(artist)
    end

    # returns a list of album 
    # singles is a boolean that determines whether or not to include art from single releases
    def self.get_art_urls(artist_url, singles)
    end
  end
end


