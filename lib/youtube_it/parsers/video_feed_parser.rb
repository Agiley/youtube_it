class YouTubeIt
  module Parsers #:nodoc:
    
    class VideoFeedParser < FeedParser #:nodoc:

      def parse_content(doc)
        entry = doc.at_xpath("xmlns:entry")
        parse_entry(entry)
      end

      protected
      def parse_entry(entry)
        video_id      = entry.at_xpath("xmlns:id").content
        published_at  = entry.at_xpath("xmlns:published") ? Time.parse(entry.at_xpath("xmlns:published").content) : nil
        updated_at    = entry.at_xpath("xmlns:updated") ? Time.parse(entry.at_xpath("xmlns:updated").content) : nil

        # parse the category and keyword lists
        categories = []
        keywords = []
        entry.xpath("xmlns:category").each do |category|
          # determine if  it's really a category, or just a keyword
          scheme = category["scheme"]
          if (scheme =~ /\/categories\.cat$/)
            # it's a category
            categories << YouTubeIt::Model::Category.new(
                            :term => category["term"],
                            :label => category["label"])

          elsif (scheme =~ /\/keywords\.cat$/)
            # it's a keyword
            keywords << category["term"]
          end
        end

        title = entry.at_xpath("xmlns:title").content
        content_element = entry.at_xpath("xmlns:content")
        html_content = (content_element && content_element.content && content_element.content.length > 0) ? content_element.content : nil

        # parse the author
        author_element = entry.at_xpath("xmlns:author")
        author = nil
        if author_element
          author = YouTubeIt::Model::Author.new(
                     :name => author_element.at_xpath("xmlns:name").content,
                     :uri => author_element.at_xpath("xmlns:uri").content)
        end
        media_group = entry.at_xpath("media:group", self.namespaces[:media])

        # if content is not available on certain region, there is no media:description, media:player or yt:duration
        description = ""
        unless media_group.at_xpath("media:description", self.namespaces[:media]).nil?
          description = media_group.at_xpath("media:description", self.namespaces[:media]).content
        end

        # if content is not available on certain region, there is no media:description, media:player or yt:duration
        duration = 0
        unless media_group.at_xpath("yt:duration", self.namespaces[:youtube]).nil?
          duration = media_group.at_xpath("yt:duration", self.namespaces[:youtube])["seconds"].to_i
        end

        # if content is not available on certain region, there is no media:description, media:player or yt:duration
        player_url = ""
        unless media_group.at_xpath("media:player", self.namespaces[:media]).nil?
          player_url = media_group.at_xpath("media:player", self.namespaces[:media])["url"]
        end

        unless media_group.at_xpath("yt:aspectRatio", self.namespaces[:youtube]).nil?
          widescreen = media_group.at_xpath("yt:aspectRatio", self.namespaces[:youtube]).content == 'widescreen' ? true : false
        end

        media_content = []
        media_group.xpath("media:content", self.namespaces[:media]).each do |mce|
          media_content << parse_media_content(mce)
        end

        # parse thumbnails
        thumbnails = []
        media_group.xpath("media:thumbnail", self.namespaces[:media]).each do |thumb_element|
          # TODO: convert time HH:MM:ss string to seconds?
          thumbnails << YouTubeIt::Model::Thumbnail.new(
                          :url => thumb_element["url"],
                          :height => thumb_element["height"].to_i,
                          :width => thumb_element["width"].to_i,
                          :time => thumb_element["time"])
        end

        rating_element = entry.at_xpath("gd:rating", self.namespaces[:gd])
        extended_rating_element = entry.at_xpath("yt:rating", self.namespaces[:youtube])

        rating = nil
        if rating_element
          rating_values = {
            :min => rating_element["min"].to_i,
            :max => rating_element["max"].to_i,
            :rater_count => rating_element["numRaters"].to_i,
            :average => rating_element["average"].to_f
          }

          if extended_rating_element
            rating_values[:likes] = extended_rating_element["numLikes"].to_i
            rating_values[:dislikes] = extended_rating_element["numDislikes"].to_i
          end

          rating = YouTubeIt::Model::Rating.new(rating_values)
        end

        if (el = entry.at_xpath("yt:statistics", self.namespaces[:youtube]))
          view_count, favorite_count = el["viewCount"].to_i, el["favoriteCount"].to_i
        else
          view_count, favorite_count = 0,0
        end

        noembed = entry.at_xpath("yt:noembed", self.namespaces[:youtube]) ? true : false
        racy = entry.at_xpath("media:rating", self.namespaces[:media]) ? true : false

        if where = entry.at_xpath("georss:where", self.namespaces[:geo_rss])
          position = where.at_xpath("gml:Point/gml:pos", self.namespaces[:gml]).content
          latitude, longitude = position.split(" ")
        end

        YouTubeIt::Model::Video.new(
          :video_id => video_id,
          :published_at => published_at,
          :updated_at => updated_at,
          :categories => categories,
          :keywords => keywords,
          :title => title,
          :html_content => html_content,
          :author => author,
          :description => description,
          :duration => duration,
          :media_content => media_content,
          :player_url => player_url,
          :thumbnails => thumbnails,
          :rating => rating,
          :view_count => view_count,
          :favorite_count => favorite_count,
          :widescreen => widescreen,
          :noembed => noembed,
          :racy => racy,
          :where => where,
          :position => position,
          :latitude => latitude,
          :longitude => longitude)
      end

      def parse_media_content (media_content_element)
        content_url = media_content_element["url"]
        format_code = media_content_element["format"].to_i
        format = YouTubeIt::Model::Video::Format.by_code(format_code)
        duration = media_content_element["duration"].to_i
        mime_type = media_content_element["type"]
        default = (media_content_element["isDefault"] == "true")

        YouTubeIt::Model::Content.new(
          :url => content_url,
          :format => format,
          :duration => duration,
          :mime_type => mime_type,
          :default => default)
      end
    end

  end
end

