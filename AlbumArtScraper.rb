require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'RMagick'

module AlbumArtScraper
  class Discogs
    @@DISC_URL = 'http://www.discogs.com'
    @@USER_AGENT = { 'User-Agent' => 'firefox' }

    # takes an artist name, searches discogs, returns array of Magick::Images if successful, otherwise returns nil
    # singles is a boolean that determines whether or not to include art from single releases
    def self.scrape_images(artist, singles)

      # search discogs for artist
      search_results = search(artist)

      # if no results, return nil
      if not search_results then return nil end

      # handle case where first result is not the right one
      art_urls = Array.new
      search_results.each do |url|
        art_urls = get_art_urls(url, singles)
        # stop looping at the first url that has art
        if art_urls then break end
      end

      # if no art could be found, return nil
      if not art_urls then return nil end
      
      # populate array of Magick::Images
      images = Array.new
      art_urls.each do |url|
        begin
          images.push(Magick::Image::read(url).first)
        rescue
        end
      end

      images
    end

    # searches discogs for an artist's page, returns array of partial urls 
    def self.search(artist)
      # strip nonalphanumeric characters from artist name; leave spaces
      artist = artist.gsub(/[^0-9a-z ]/, "")

      # replace spaces with '+'s for url
      artist = artist.gsub(/[\s]/, '+')

      # search discogs
      page = Nokogiri::HTML(open("#{@@DISC_URL}/search/?q=#{artist}&advanced1&type=artist", @@USER_AGENT))

      # get links out of page
      results = page.css('a').to_a.collect do |a|
        if a.has_attribute? 'class' 
          a.get_attribute('href') if a.get_attribute('class') == "search_result_title rollover_link"
        end
      end

      results.delete(nil)
      
      results
    end

    # returns a list of album 
    # singles is a boolean that determines whether or not to include art from single releases
    def self.get_art_urls(artist_url, singles)
      begin
        page = Nokogiri::HTML(open("#{@@DISC_URL}#{artist_url}?sort=year%2Casc&limit=500&subtype=Albums&type=Releases", @@USER_AGENT))
      rescue OpenURI::HTTPError
        return nil
      end

      # find img tags
      imgs = page.css('img')

      # 'R-90' is in all discog art urls; collect urls that have it
      img_urls = imgs.to_a.collect { |img| if img.get_attribute('src').include? 'R-90' then img.get_attribute('src') end }

      # if we want singles, repeat process then combine
      if singles
        begin
          page = Nokogiri::HTML(open("#{@@DISC_URL}#{artist_url}?sort=year%2Casc&limit=500&subtype=Singles-EPs&type=Releases", @@USER_AGENT))
          imgs = page.css 'img'
          singles_urls = imgs.to_a.collect { |img| if img.get_attribute('src').include? 'R-90' then img.get_attribute('src') end }
          img_urls += singles_urls
        rescue OpenURI::HTTPError
        end
      end

      img_urls.delete(nil)

      img_urls
    end
  end

  class WallpaperGen
    attr_reader :wallpaper
    # takes desired resolution, array of images
    def initialize(width, height, images)
      @wallpaper = Magick::Image.new(width, height)
      @collage_items = images
      @tile_x_size = @collage_items.first.rows
      @tile_y_size = @collage_items.first.columns
      # number of rows / columns of tiles in wallpaper ; add one to ensure entire image is covered
      @num_rows = ( width / @tile_x_size ) + 1
      @num_cols = ( height / @tile_y_size ) + 1
    end

    # generates a  random wallpaper from the tiles
    def generate
      @num_rows.times do |r|
        @num_cols.times do |c|
          @wallpaper.composite!(@collage_items.sample, (r - 1) * @tile_x_size, (c - 1) * @tile_y_size, Magick::OverCompositeOp)
        end
      end
    end

    def write
    end
  end
end


