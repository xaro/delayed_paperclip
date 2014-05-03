require 'uri'

module DelayedPaperclip
  module UrlGenerator
    def self.included(base)
      base.alias_method_chain :most_appropriate_url, :processed
      base.alias_method_chain :timestamp_possible?, :processed
      base.alias_method_chain :for, :processed
    end

    def for_with_processed(style_name, options)
      most_appropriate_url = most_appropriate_url(style_name)

      escape_url_as_needed(
        timestamp_as_needed(
          @attachment_options[:interpolator].interpolate(most_appropriate_url, @attachment, style_name),
          options
      ), options)
    end

    # This method is a mess
    def most_appropriate_url_with_processed(style = nil)
      if @attachment.original_filename.nil? || delayed_default_url?(style)
        if @attachment.delayed_options.nil? ||
           @attachment.processing_image_url.nil? ||
           !@attachment.processing?

          default_url
        else
          @attachment.processing_image_url
        end
      else
        @attachment_options[:url]
      end
    end

    def timestamp_possible_with_processed?
      if delayed_default_url?
        false
      else
        timestamp_possible_without_processed?
      end
    end

    def delayed_default_url?(style = nil)
      return false if @attachment.job_is_processing
      return false if @attachment.dirty?
      return false if not @attachment.delayed_options.try(:[], :url_with_processing)
      return false if not processing?(style)
      true
    end

    private

    def processing?(style)
      return @attachment.processing_style?(style) if style
      return true if @attachment.processing?
    end
  end

end
