Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '10.0'
s.name = "StdSdkGame"
s.summary = "STDGame allow user connect to STDGAme"
s.requires_arc = true

# 2
s.version = "0.1.4"

# 3
s.license = { :type => "MIT", :file => "LICENSE" }

# 4 - Replace with your name and e-mail address
s.author = { "Jude" => "chidungc2@gmail.com" }

# 5 - Replace this URL with your own Github page's URL (from the address bar)
s.homepage = "https://github.com/dungnc/StdSdkGameDemo"

# 6 - Replace this URL with your own Git URL from "Quick Setup"
s.source = { :git => "https://github.com/dungnc/StdSdkGameDemo.git", :tag => "#{s.version}"}
  
# 7
s.framework = "UIKit"

#s.static_framework = true
# 8
s.source_files = "StdSdkGame/**/*.{swift}"

# 9
s.resources = "StdSdkGame/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"

# 10
s.swift_version = "5.0"

end
