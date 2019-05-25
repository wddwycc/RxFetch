Pod::Spec.new do |s|
  s.name             = 'RxFetch'
  s.version          = '0.1.0'
  s.swift_version    = '5.0'
  s.summary          = 'fetch abstraction based on Rx'
  s.description      = <<-DESC
    fetch abstraction based on Rx with declarative taste.
                       DESC

  s.homepage         = 'https://github.com/wddwycc/RxFetch'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'wddwycc' => 'wddwyss@gmail.com' }
  s.source           = { :git => 'https://github.com/wddwycc/RxFetch.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/wddwycc'

  s.ios.deployment_target = '10.0'
  s.tvos.deployment_target = '10.0'
  s.osx.deployment_target = '10.10'
  s.watchos.deployment_target = '3.0'

  s.requires_arc = true

  s.source_files = 'Sources/**/*'
  
  s.dependency 'RxSwift', '~> 5.0'
  s.dependency 'RxCocoa', '~> 5.0'
end
