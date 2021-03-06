# Homey macOS app

<p align=center>
<img src="/Assets/Icon/Icon%40256px.png?raw=true" width="128">
</p>

This project is a macOS app that embeds the [Homey Web App](https://my.homey.app) in a [WKWebView](https://developer.apple.com/documentation/webkit/wkwebview). It's not officially supported by Athom, so contributions are very much welcome.

## Wishlist

- [x] Auto-update
- [ ] Flow Widget
- [ ] Device Widget
- [ ] Touch Bar
- [ ] Push Notifications

## Usage

Head over to [Releases](https://github.com/athombv/homey-mac-app/releases) to download the latest version.

## Building

1. In Xcode, navigate to _Product_ > _Archive_.
2. In the _Archives_ window, click _Distribute App_ > _Developer ID_ > _Export_ and select the Athom B.V. Developer ID certificate. No profiles should be selected. Xcode will export _Homey.app_.
3. Run `./scripts/publish.sh /path/to/Homey.app` to pack it into `Homey.dmg`, notarize and staple it.

> This will create a `.dmg` file in `./docs/releases/Homey-{build}.dmg` and update `./docs/appcast.xml`.

> GitHub Pages will then host the new release (`./docs` directory).

## Contributing

Head over to [Issues](https://github.com/athombv/homey-mac-app/issues) to see what needs to be done.
