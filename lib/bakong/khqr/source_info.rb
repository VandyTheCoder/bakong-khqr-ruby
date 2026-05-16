# frozen_string_literal: true

module Bakong
  module Khqr
    # Optional metadata sent alongside a deep-link generation request so that
    # the receiving wallet can render the originating app's icon and name.
    SourceInfo = Struct.new(:app_icon_url, :app_name, :app_deep_link_callback, keyword_init: true) do
      def complete?
        !app_icon_url.nil? && !app_name.nil? && !app_deep_link_callback.nil? &&
          app_icon_url != "" && app_name != "" && app_deep_link_callback != ""
      end

      def to_h
        {
          appIconUrl: app_icon_url,
          appName: app_name,
          appDeepLinkCallback: app_deep_link_callback
        }
      end
    end
  end
end
