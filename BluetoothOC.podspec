Pod::Spec.new do |s|
    s.name             = "BluetoothOC"
    s.version          = "1.0.0"
    s.summary          = "BluetoothOC"
    s.description      = <<-DESC
    BluetoothOC USAGE
    DESC
    s.homepage         = "https://github.com/coolnameismy/BabyBluetooth"
    s.license          = 'MIT'
    s.author           = { "ZJaDe" => "zjade@outlook.com" }
    s.source           = { :git => "https://e.coding.net/aibol/nazha-charging/charging-ui-app-ios.git", :tag => s.version.to_s }
    s.source_files       = 'Source/**/*'

    s.requires_arc          = true
    
    s.ios.deployment_target = '10.0'
    s.swift_versions        = '5.0'
    s.dependency "BabyBluetooth"
end
