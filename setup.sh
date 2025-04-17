#!/bin/bash

# Manul Monday Setup Script
# This script helps set up the Manul Monday iOS app for development

echo "🐱 Setting up Manul Monday iOS app..."

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode is not installed. Please install Xcode from the App Store."
    exit 1
fi

echo "✅ Xcode is installed."

# Check if CocoaPods is installed
if ! command -v pod &> /dev/null; then
    echo "⚠️ CocoaPods is not installed. Installing CocoaPods..."
    sudo gem install cocoapods
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install CocoaPods. Please install it manually: sudo gem install cocoapods"
        exit 1
    fi
    echo "✅ CocoaPods installed successfully."
else
    echo "✅ CocoaPods is already installed."
fi

# Install dependencies using CocoaPods
echo "📦 Installing dependencies using CocoaPods..."
pod install

if [ $? -ne 0 ]; then
    echo "⚠️ CocoaPods installation failed. Trying to update repo and install again..."
    pod repo update
    pod install
    
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install dependencies with CocoaPods."
        echo "You can try installing dependencies manually:"
        echo "1. Run 'pod repo update'"
        echo "2. Run 'pod install'"
        exit 1
    fi
fi

echo "✅ Dependencies installed successfully."

# Check if GoogleService-Info.plist exists
if [ ! -f "ManulMonday/Resources/GoogleService-Info.plist" ]; then
    echo "⚠️ GoogleService-Info.plist not found in ManulMonday/Resources/"
    echo "Please make sure to add your Firebase configuration file to the project."
    echo "You can get this file from the Firebase console:"
    echo "1. Go to https://console.firebase.google.com/"
    echo "2. Create a new project or select an existing one"
    echo "3. Add an iOS app with bundle ID 'com.fuzz.ManulMonday'"
    echo "4. Download the GoogleService-Info.plist file"
    echo "5. Place it in the ManulMonday/Resources/ directory"
else
    echo "✅ GoogleService-Info.plist found."
fi

# Create Xcode workspace if it doesn't exist
if [ ! -f "ManulMonday.xcworkspace" ]; then
    echo "📝 Creating Xcode workspace..."
    pod install
fi

echo "🎉 Setup complete! You can now open the project by running:"
echo "open ManulMonday.xcworkspace"

# Open the workspace
echo "🚀 Opening Xcode workspace..."
open ManulMonday.xcworkspace

echo "🐱 Happy coding with Manul Monday!"
