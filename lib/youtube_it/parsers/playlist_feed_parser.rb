class YouTubeIt
  module Parsers #:nodoc:
    
    class PlaylistFeedParser < FeedParser #:nodoc:

      def parse_content(doc)
        entry = (doc.name.eql?("entry") || doc.name.eql?("feed")) ? doc : doc.at_xpath("xmlns:entry") || doc.at_xpath("xmlns:feed")
        
        YouTubeIt::Model::Playlist.new(
          :title         => entry.at_xpath("xmlns:title").content,
          :summary       => (entry.at_xpath("xmlns:summary").content || entry.at_xpath("media:group/media:description", self.namespaces[:media]).content),
          :description   => (entry.at_xpath("xmlns:summary").content || entry.at_xpath("media:group/media:description", self.namespaces[:media]).content),
          :playlist_id   => entry.at_xpath("xmlns:id").content[/playlist([^<]+)/, 1].sub(':',''),
          :published     => entry.at_xpath("xmlns:published") ? entry.at_xpath("xmlns:published").content : nil,
          :xml           => entry.to_xml)
      end
    end

  end
end

