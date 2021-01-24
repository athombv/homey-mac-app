#!/bin/sh

# Check arguments
if [ -z "$1" ]
  then
    echo "Usage: ./publish.sh /path/to/Homey.app"
    exit 1
fi

# Move (don't copy, this will break the signature) Homey.app
echo "✅ Moving $1 to ./Homey.app..."
rm -rf ./Homey.app
mv "$1" ./Homey.app

if [ ! -d "Homey.app" ] 
then
    echo "Error: Homey.app does not exist." 
    exit 1
fi

# Set environment
BUILD=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" Homey.app/Contents/Info.plist)
DMG=../docs/releases/Homey-$BUILD.dmg

echo "✅ Creating Homey.dmg (Build $BUILD)..."
appdmg ../Assets/Homey-appdmg.json $DMG

echo "✅ Notarizing Homey.dmg..."
npx notarize-cli \
  --file $DMG \
  --bundle-id "com.athom.macos.dmg" \
  --username "emile@athom.nl" \
  --password "@keychain:com.athom.macos.dmg"

echo "✅ Stapling Homey.dmg..."
xcrun stapler staple -v $DMG

echo "✅ Generating appcast.xml"
rm ../docs/appcast.xml
../Tools/Sparkle-1.24.0/bin/generate_appcast -o ../docs/appcast.xml --download-url-prefix "https://homey-mac-app.athom.com/releases/" ../docs/releases/

echo "✅ Cleaning up..."
mv ./Homey.app "$1"

echo "✅ Creating GitHub Release..."
gh config set prompt disabled
gh release create $BUILD --title "Build $BUILD" --notes "Build $BUILD"
gh release upload $BUILD $DMG