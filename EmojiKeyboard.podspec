#
# Be sure to run `pod lib lint EmojiKeyboard.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "EmojiKeyboard"
  s.version          = "0.1.0"
  s.summary          = "A keyboard that only allows Emojis to be entered, and does not allow toggling to other keyboards."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
                       DESC

  s.homepage         = "https://github.com/yeti/EmojiKeyboard"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Lee McDole" => "lee@yeti.co" }
  s.source           = { :git => "https://github.com/yeti/EmojiKeyboard.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/yetillc'

  s.ios.deployment_target = '8.0'

  s.source_files = 'EmojiKeyboard/Classes/**/*'
  
  # s.resource_bundles = {
  #   'EmojiKeyboard' => ['EmojiKeyboard/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
