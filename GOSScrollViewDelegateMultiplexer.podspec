Pod::Spec.new do |s|
  s.name         = "GOSScrollViewDelegateMultiplexer"
  s.version      = "1.0.1"
  s.authors      = { 'Chris Cox' => 'cjcox@google.com' }
  s.summary      = "A proxy object for UIScrollViewDelegate that forwards all received events to an ordered list of registered observers."
  s.homepage     = "https://github.com/google/GOSScrollViewDelegateMultiplexer"
  s.license      = 'Apache 2.0'
  s.source       = { :git => "https://github.com/google/GOSScrollViewDelegateMultiplexer.git", :tag => s.version.to_s }
  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.deprecated_in_favor_of = 'MDFScrollViewDelegateMultiplexer'

  s.public_header_files = 'src/*.h'
  s.source_files = 'src/*.{h,m}'
  s.header_mappings_dir = 'src/*'

end
