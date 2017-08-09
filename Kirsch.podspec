#
# Be sure to run `pod lib lint Kirsch.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Kirsch'
  s.version          = '0.2.8'
  s.summary          = 'Cool scanner developed with swift'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This library provides a bunch of functions in order to convert and control the camera into an automatic scanner. This library is named before Russell A. Kirsch, the one who developed the first digital scanner
                       DESC

  s.homepage         = 'https://github.com/coverfy/KirschScanner'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'josepbordesjove' => 'josep.bordes@coverfy.com' }
  s.source           = { :git => 'https://github.com/coverfy/KirschScanner.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/coverfy'

  s.ios.deployment_target = '9.0'

  s.source_files = 'Kirsch/Classes/**/*'
  
  # s.resource_bundles = {
  #   'Kirsch' => ['Kirsch/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
