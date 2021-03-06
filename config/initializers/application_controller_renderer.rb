# Be sure to restart your server when you modify this file.

# ActiveSupport::Reloader.to_prepare do
#   ApplicationController.renderer.defaults.merge!(
#     http_host: 'example.org',
#     https: false
#   )
# end
ActionController::Base.asset_host = Proc.new { |source|
if source.ends_with?('.jpg')
  "https://stage-greattimes-app.s3.amazonaws.com/"
else
  "https://stage-greattimes-app.herokuapp.com/"
end
}