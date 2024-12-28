require 'liquid'

module Redmineup
  module Liquid
    module Filters
      module Additional
        def parse_inline_attachments(text, obj)
          attachments = obj.attachments if obj.respond_to?(:attachments)

          if attachments.present?
            text.gsub!(/src="([^\/"]+\.(bmp|gif|jpg|jpe|jpeg|png))"(\s+alt="([^"]*)")?/i) do |m|
              filename, ext, alt, alttext = $1, $2, $3, $4
              # search for the picture in attachments
              if found = Attachment.latest_attach(attachments, CGI.unescape(filename))
                image_url = found.url
                desc = found.description.to_s.delete('"')
                if !desc.blank? && alttext.blank?
                  alt = " title=\"#{desc}\" alt=\"#{desc}\""
                end
                "src=\"#{image_url}\"#{alt} loading=\"lazy\""
              else
                m
              end
            end
          end

          text
        end
      end

      ::Liquid::Template.register_filter(Redmineup::Liquid::Filters::Additional)
    end
  end
end
