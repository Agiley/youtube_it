class YouTubeIt
  module Parsers #:nodoc:
    
    class PlaylistsFeedParser < FeedParser #:nodoc:

      # return array of playlist objects
      def parse_content(doc)
        playlists = []
        
        doc.xpath("xmlns:feed/xmlns:entry").each do |entry|
          playlists << PlaylistFeedParser.new(entry).parse_content(entry)
        end
        
        return playlists
      end
    end

  end
end

