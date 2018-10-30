
Pod::Spec.new do |s|

  s.name         = "Muni"
  s.version      = "0.7.4"
  s.summary      = "Firestore message framework"
  s.description  = <<-DESC
Muni is a chat framework made with Firestore.
                   DESC
  s.homepage     = "https://github.com/1amageek/Muni"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "1amageek" => "tmy0x3@icloud.com" }
  s.social_media_url   = "http://twitter.com/1amageek"
  s.platform     = :ios, "10.0"
  s.ios.deployment_target = "10.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/1amageek/Muni.git", :tag => "#{s.version}" }
  s.source_files = "Muni/**/*.{swift}"
  s.resources = "Muni/**/*.{xib}"
  s.requires_arc = true
  s.static_framework = true
  s.dependency "Pring"
  s.dependency "Toolbar"
  s.dependency "Firebase"
  s.dependency "Firebase/Firestore"
  s.dependency "Firebase/Storage"
end
