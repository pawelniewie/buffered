Pod::Spec.new do |s|
  s.name         = "Buffered"
  s.version      = "0.0.1"
  s.summary      = "Mac SDK for Bufferapp.com"
  s.homepage     = "https://github.com/pawelniewie/buffered"
  s.license      = { :type => 'BSD', :file => 'LICENSE' }
  s.author       = { "pawelniewie" => "11110000b@gmail.com" }
  # s.source       = { :git => "https://github.com/pawelniewie/buffered.git", :commit => "4a0d69e455595bb60fd5377473940de6515322fb" }
  s.source       = { :git => "https://github.com/pawelniewie/buffered.git", :tag => "0.0.1" }
  s.platform     = :osx, '10.8'
  s.source_files = 'Buffered'
  s.public_header_files = 'Buffered/*.h'
  s.resources = "Buffered/*.xib"
  s.frameworks = 'WebKit', 'Cocoa'
  s.requires_arc = true
  s.dependency 'gtm-oauth2'
  s.xcconfig = { 'HEADER_SEARCH_PATHS' => 'Buffered', 'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) POD=1' }
end
