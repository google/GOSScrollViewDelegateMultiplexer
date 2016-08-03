Pod::Spec.new do |s|
  s.name         = "MDFScrollViewDelegateMultiplexer"
  s.version      = "2.0.1"
  s.authors      = { 'Chris Cox' => 'cjcox@google.com' }
  s.summary      = "A proxy object for UIScrollViewDelegate that forwards all received events to an ordered list of registered observers."
  s.homepage     = "https://github.com/material-foundation/material-scrollview-delegate-multiplexer-ios"
  s.license      = 'Apache 2.0'
  s.source       = { :git => "https://github.com/material-foundation/material-scrollview-delegate-multiplexer-ios.git", :tag => s.version.to_s }
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.public_header_files = 'src/*.h'
  s.source_files = 'src/*.{h,m}'
end
