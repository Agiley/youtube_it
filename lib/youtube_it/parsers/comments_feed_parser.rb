class YouTubeIt
  module Parsers #:nodoc:
    
    class CommentsFeedParser < FeedParser #:nodoc:
      # return array of comments
      def parse_content(doc)
        comments = []
        doc.xpath("/xmlns:feed/xmlns:entry").each do |entry|
          comments << parse_entry(entry)
        end
        return comments
      end

      protected
      def parse_entry(entry)
        author = YouTubeIt::Model::Author.new(
          :name   => entry.at_xpath("xmlns:author/xmlns:name").content,
          :uri    => entry.at_xpath("xmlns:author/xmlns:uri").content,
        )
        YouTubeIt::Model::Comment.new(
          :author     => author,
          :content    => entry.at_xpath("xmlns:content").content,
          :published  => entry.at_xpath("xmlns:published").content,
          :title      => entry.at_xpath("xmlns:title").content,
          :updated    => entry.at_xpath("xmlns:updated").content,
          :url        => entry.at_xpath("xmlns:id").content,
        )
      end
    end

  end
end

