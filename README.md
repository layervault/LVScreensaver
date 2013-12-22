# LVScreensaver

An example API app written in Objective-C. It's a screensaver that displays the latest designs in your LayerVault.

## Setup

Checkout the repo and do a `pod install`.

Insert your LayerVault application client and secret keys into `LVScreenSaverView.m`. You can register
an application at [https://layervault.com/settings](https://layervault.com/settings). Accounts are free and
can be created here: [https://layervault.com/pricing](https://layervault.com/pricing).

When in XCode, you'll have to Build the project. This will create the `LVScreensaver.saver` file. Double-click 
that to load it into System Preferences.

Set your LayerVault user name and password by clicking "Screen Saver Options..."

## Notes

- Currently waiting for the [LayerVaultAPI](https://github.com/layervault/LayerVaultAPI.objc) library to be 
merged into the core CocoaPods/Specs repo. You will have to alias it directly with `:git => https://github.com/layervault/LayerVaultAPI.objc`
in your Podfile for the time being.
- The screensaver itself is really slow, due to my hilariously inefficient `drawRect` method. Currentlyer searching CoreGraphics
and OpenGL possibilities.
- Currently not using Keychain Access to store user credentials. This app *will* store your LayerVault credentials in plain text.
- There is currently no error state of the credentials (either OAuth or user) are invalid, neither at the screen saver level or at the input sheet level. 
