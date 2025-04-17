# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

target 'ManulMonday' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Firebase
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'Firebase/Analytics'
  pod 'FirebaseFirestoreSwift'

  # UI
  pod 'Kingfisher', '~> 7.0'  # For image loading and caching

end

# Workaround for Xcode 12+ build issues with ARM simulators
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
    end
  end
end
