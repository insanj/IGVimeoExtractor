Pod::Spec.new do |s|
  s.name         = "IGVimeoExtractor"
  s.version      = "1.2.0"
  s.summary      = "Fetches Vimeo's mp4 URLs for iOS."
  s.description  = <<-DESC
                    IGVimeoExtractor lets you get the iOS compatible video url 
                    from Vimeo which you can use in MPMoviePlayerController, 
                    no need to use a UIWebView.
                    DESC
  s.homepage     = "https://github.com/siuying/IGVimeoExtractor"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 
    "Louis Larpin" => "louis.larpin@gmail.com",
    "Francis Chong" => "francis@ignition.hk" 
  }
  s.source       = { 
    :git => "https://github.com/siuying/IGVimeoExtractor.git", :tag => s.version.to_s
  }

  s.ios.deployment_target = "7.0"
  s.osx.deployment_target = "10.8"

  s.source_files = 'IGVimeoExtractor/*.{h,m}'
  s.requires_arc = true
end
