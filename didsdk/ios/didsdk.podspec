#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint didsdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'didsdk'
  s.version          = '9.3.1'
  s.summary          = 'Appgate DID SDK'
  s.description      = <<-DESC
  DID SDK wrapper for Flutter
                       DESC
  s.homepage         = 'http://appgate.com'
  s.license          = { :file => '../LICENSE.md' }
  s.author           = { 'Appgate' => 'camilo.ortegon@appgate.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.vendored_frameworks = 'Assets/appgate_sdk.xcframework', 'Assets/didm_core.xcframework', 'Assets/didm_sdk.xcframework'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
