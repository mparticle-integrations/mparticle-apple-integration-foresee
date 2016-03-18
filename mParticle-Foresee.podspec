Pod::Spec.new do |s|
  s.name             = "mParticle-Foresee"
  s.version          = "6.0.0"
  s.summary          = "Foresee integration for mParticle"

  s.description      = <<-DESC
                       This is the Foresee integration for mParticle.
                       DESC

  s.homepage         = "https://www.mparticle.com"
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { "mParticle" => "support@mparticle.com" }
  s.source           = { :git => "https://github.com/mparticle-integrations/mparticle-apple-integration-foresee.git", :tag => s.version.to_s }
  s.social_media_url = "https://twitter.com/mparticles"

  s.source_files = 'mParticle-Foresee/*.{h,m,mm}'

  s.dependency 'mParticle-Apple-SDK', '6.0.0'
end
