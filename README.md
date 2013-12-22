# LVScreensaver

An example API app written in Objective-C. It's a screensaver that displays the latest designs in your LayerVault.

## Setup

Checkout the repo and do a `pod install`

## Notes

- Currently waiting for the [LayerVaultAPI](https://github.com/layervault/LayerVaultAPI.objc) library to be 
merged into the core CocoaPods/Specs repo. You will have to alias it directly with `:git => https://github.com/layervault/LayerVaultAPI.objc`
in your Podfile for the time being.
- The screensaver itself is really slow, due to my hilariously inefficient `drawRect` method. Currentlyer searching CoreGraphics
and OpenGL possibilities.
