#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint dataroid_sdk_ios.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'dataroid_sdk_ios'
  s.version          = '4.1.0'
  s.summary          = 'iOS implementation of Dataroid SDK'
  s.description      = <<-DESC
iOS platform implementation of the Dataroid Flutter SDK.
                       DESC
  s.homepage         = 'https://www.dataroid.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Dataroid SDK Team' => 'sdk@dataroid.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'DataroidCore', '~> 4.2.0'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES', 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
  s.swift_version = '5.0'
end

