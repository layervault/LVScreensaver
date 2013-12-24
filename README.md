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

- Currently not using Keychain Access to store user credentials. This app *will* store your LayerVault credentials in plain text.
- There is currently no error state of the credentials (either OAuth or user) are invalid, neither at the screen saver level or at the input sheet level. 
- The polling mechanism is a bit dumb, and could start overlapping responses if: the user has a lot of projects or if the responses for each project is slow. We should collect the responses before issues a new top-level request.
