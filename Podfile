# Uncomment this line to define a global platform for your project
use_frameworks!
platform :ios, '8.0'

def demo_chat_frameworks
    #start - add firebase
    pod 'Firebase', '~> 3.17.0'
    pod 'Firebase/Database', '~> 3.17.0'
    pod 'Firebase/Auth', '~> 3.17.0'
    pod 'Firebase/Storage', '~> 3.17.0'
    pod 'Kingfisher', '~> 3.10.3'
    #end
    
    #start - add google adMob
    pod 'Firebase/AdMob', '~> 3.17.0'
    #end
    
    #start - google analytics
    pod 'GoogleAnalytics', '~> 3.17.0'
    pod 'Firebase/Core', '~> 3.17.0'
    #end
    
    pod 'EZAlertController', '~> 3.2' #lib message
    
    #start - add fabric and login twitter
    pod 'Fabric', '~> 1.6.3'
    pod 'Crashlytics'
    pod 'TwitterKit', '~> 2.8.1'
    #end
    
    #Nifty cloud
    pod 'NCMB', :git => 'https://github.com/NIFTYCloud-mbaas/ncmb_ios.git'
    #end
    
    #start - tracking user in MAP
    pod 'GoogleMaps', '~> 2.3.1'
    pod 'Socket.IO-Client-Swift', '~> 11.0.0'
    #end
    
    #start - add pod support movie function
    pod 'Alamofire', '~> 4.5.0'
    #pod 'PageMenu', '~> 1.2.9'
    pod 'youtube-parser', '~> 0.2.3'
    #end
    
    #start - add pod support music function
    pod 'FMDB', '~> 2.7.2'
    #end
end

target 'HuCaChat_Dev' do
    demo_chat_frameworks
end

target 'HuCaChat_Release' do
    demo_chat_frameworks
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
