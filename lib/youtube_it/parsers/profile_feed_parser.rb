class YouTubeIt
  module Parsers #:nodoc:
    
    class ProfileFeedParser < FeedParser #:nodoc:
      def parse_content(content)
        xml = REXML::Document.new(content.body)
        entry = xml.at_xpath("entry") || xml.at_xpath("feed")
        YouTubeIt::Model::User.new(
          :age              => entry.at_xpath("yt:age", self.namespaces[:youtube])           ? entry.at_xpath("yt:age", self.namespaces[:youtube]).content : nil,
          :company          => entry.at_xpath("yt:company", self.namespaces[:youtube])       ? entry.at_xpath("yt:company", self.namespaces[:youtube]).content : nil,
          :gender           => entry.at_xpath("yt:gender", self.namespaces[:youtube])        ? entry.at_xpath("yt:gender", self.namespaces[:youtube]).content : nil,
          :hobbies          => entry.at_xpath("yt:hobbies", self.namespaces[:youtube])       ? entry.at_xpath("yt:hobbies", self.namespaces[:youtube]).content : nil,
          :hometown         => entry.at_xpath("yt:hometown", self.namespaces[:youtube])      ? entry.at_xpath("yt:hometown", self.namespaces[:youtube]).content : nil,
          :location         => entry.at_xpath("yt:location", self.namespaces[:youtube])      ? entry.at_xpath("yt:location", self.namespaces[:youtube]).content : nil,
          :last_login       => entry.at_xpath("yt:statistics", self.namespaces[:youtube])["lastWebAccess"],
          :join_date        => entry.at_xpath("xmlns:published") ? doc.at_xpath("xmlns:published").content : nil,
          :movies           => entry.at_xpath("yt:movies", self.namespaces[:youtube])        ? entry.at_xpath("yt:movies", self.namespaces[:youtube]).content : nil,
          :music            => entry.at_xpath("yt:music", self.namespaces[:youtube])         ? entry.at_xpath("yt:music", self.namespaces[:youtube]).content : nil,
          :occupation       => entry.at_xpath("yt:occupation", self.namespaces[:youtube])    ? entry.at_xpath("yt:occupation", self.namespaces[:youtube]).content : nil,
          :relationship     => entry.at_xpath("yt:relationship", self.namespaces[:youtube])  ? entry.at_xpath("yt:relationship", self.namespaces[:youtube]).content : nil,
          :school           => entry.at_xpath("yt:school", self.namespaces[:youtube])        ? entry.at_xpath("yt:school", self.namespaces[:youtube]).content : nil,
          :subscribers      => entry.at_xpath("yt:statistics", self.namespaces[:youtube])["subscriberCount"],
          :videos_watched   => entry.at_xpath("yt:statistics", self.namespaces[:youtube])["videoWatchCount"],
          :view_count       => entry.at_xpath("yt:statistics", self.namespaces[:youtube])["viewCount"],
          :upload_views     => entry.at_xpath("yt:statistics", self.namespaces[:youtube])["totalUploadViews"]
        )
      end
    end

  end
end

