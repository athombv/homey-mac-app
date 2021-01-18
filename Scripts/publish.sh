#!/bin/sh

if [ -z "$1" ]
  then
    echo "Usage: ./publish.sh /path/to/Homey.app"
    exit 1
fi

rm -rf ./Homey.app
cp -r "$1" ./Homey.app

if [ ! -d "Homey.app" ] 
then
    echo "Error: Homey.app does not exist." 
    exit 1
fi
BUILD=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" Homey.app/Contents/Info.plist)
echo "Creating DMG for build $BUILD..."

appdmg ../Assets/Homey-appdmg.json ../docs/releases/Homey-$BUILD.dmg

rm ../docs/appcast.xml
../Tools/Sparkle-1.24.0/bin/generate_appcast -o ../docs/appcast.xml --download-url-prefix "https://homey-mac-app.athom.com/releases/" ../docs/releases/

rm -r ./Homey.app