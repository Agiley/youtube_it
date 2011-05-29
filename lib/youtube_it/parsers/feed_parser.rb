class YouTubeIt
  module Parsers #:nodoc:
    class FeedParser #:nodoc:
      attr_accessor :namespaces, :content
      
      def initialize(content)
        self.namespaces = {
          :atom         => "http://www.w3.org/2005/Atom",
          :app          => {"app" => "http://purl.org/atom/app#"},
          :media        => {"media" => "http://search.yahoo.com/mrss/"},
          :open_search  => {"openSearch" => "http://a9.com/-/spec/opensearchrss/1.0/"},
          :gd           => {"gd" => "http://schemas.google.com/g/2005"},
          :gml          => {"gml" => "http://www.opengis.net/gml"},
          :youtube      => {"yt" => "http://gdata.youtube.com/schemas/2007"},
          :geo_rss      => {"georss" => "http://www.georss.org/georss"},
        }
        
        if (content && content.is_a?(Nokogiri::XML::Document))
          self.content = content
        else
          self.content = open(content).read rescue content
          self.content = (self.content.is_a?(String)) ? self.content : self.content.body rescue nil
          self.content = Nokogiri::XML(self.content, nil, "utf-8") if (self.content && self.content.is_a?(String))
        end
      end

      def parse
        parse_content(self.content)
      end

      def parse_videos
        videos = []
        content.xpath("/entry").each do |video|
          videos << parse_entry(video)
        end
        
        return videos
      end
    end

  end
end

