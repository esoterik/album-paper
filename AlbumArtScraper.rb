require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'RMagick'

module AlbumArtScraper
  class Discogs
    @@DISC_URL = 'http://www.discogs.com'
    @@USER_AGENT = { 'User-Agent' => 'firefox' }

    # takes an artist name, searches discogs, returns array of Magick::Images if successful
    # singles is a boolean that determines whether or not to include art from single releases
    def self.scrape_images(artist, singles)

      # search discogs for artist
      search_results = search(artist)

      # results are ordered by relevance ; first one should be the one we want
      art_urls = get_art_urls(search_results.first, singles)
      
      # populate array of Magick::Images
      images = Array.new
      art_urls.each { |url| images.push(Magick::Image::read(url).first) }

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

      
      results
    end

    # returns a list of album 
    # singles is a boolean that determines whether or not to include art from single releases
    def self.get_art_urls(artist_url, singles)
      page = Nokogiri::HTML(open("#{@@DISC_URL}#{artist_url}?sort=year%2Casc&limit=500&subtype=Albums&type=Releases", @@USER_AGENT))

      # find img tags
      imgs = page.css('img')

      # 'R-90' is in all discog art urls; collect urls that have it
      img_urls = imgs.to_a.collect { |img| if img.get_attribute('src').include? 'R-90' then img.get_attribute('src') end }

      # if we want singles, repeat process then combine
      if singles
        page = Nokogiri::HTML(open("#{@DiscUrl}#{artist_url}?sort=year%2Casc&limit=500&subtype=Singles-EPs&type=Releases", @@USER_AGENT))
        imgs = page.css 'img'
        singles_urls = imgs.to_a.collect { |img| if img.get_attribute('src').include? 'R-90' then img.get_attribute('src') end }
        img_urls += singles_urls
      end

      img_urls
    end
  end
end


