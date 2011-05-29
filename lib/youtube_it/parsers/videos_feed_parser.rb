class YouTubeIt
  module Parsers #:nodoc:
    
    class VideosFeedParser < VideoFeedParser #:nodoc:

    private
      def parse_content(doc)
        videos  = []
        feed    = doc.at_xpath("/xmlns:feed")
        total_result_count, offset, max_result_count = nil
        
        if (feed)
          feed_id            = feed.at_xpath("xmlns:id").content
          updated_at         = Time.parse(feed.at_xpath("xmlns:updated").content)
          
          #Somehow it isn't possible to parse the nodes (maybe a JRuby/Nokogiri bug?) from the openSearch-namespace using xpath... Have to do it this way instead...
          feed.children.each do |child|
            if (child.namespace && child.namespace.prefix.eql?("openSearch"))
              case child.name
                when "totalResults" then total_result_count = child.content.to_i
                when "startIndex"   then offset = child.content.to_i
                when "itemsPerPage" then max_result_count = child.content.to_i
              end
            end
          end
          
          feed.xpath("xmlns:entry").each do |entry|
            videos << parse_entry(entry)
          end
        end
        
        YouTubeIt::Response::VideoSearch.new(
          :feed_id => feed_id || nil,
          :updated_at => updated_at || nil,
          :total_result_count => total_result_count || nil,
          :offset => offset || nil,
          :max_result_count => max_result_count || nil,
          :videos => videos)
      end
    end

  end
end

