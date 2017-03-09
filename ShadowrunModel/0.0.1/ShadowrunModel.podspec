Pod::Spec.new do |s|
  s.name             = "ShadowrunModel"
  s.version          = "0.0.1"
  s.summary          = "Domain model for the Shadowrun™ RPG"
  s.homepage         = "https://github.com/metacosm/ShadowrunModel"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "Christophe Laprun" => "metacosm@gmail.com" }
  s.source           = { :git => "https://github.com/metacosm/ShadowrunModel.git", :tag => s.version }
  s.social_media_url = 'https://twitter.com/metacosm'

  s.platform     = :ios, '10.2'

  s.source_files = 'ShadowrunModel'

  s.frameworks = 'Foundation'
  s.module_name = 'ShadowrunModel'
end