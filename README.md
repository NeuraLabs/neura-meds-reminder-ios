# Neura Meds Reminder Sample App

This app serves two purposes
1. A Neura sample app that uses a webhook for Neura events in conjunction with the (webhook sample)[https://github.com/NeuraLabs/neura-webhook-sample]
2. A product example for using Neura events to help a patient take their medications

## Requirements

Xcode 8
Swift 3

## Develop

### Important functions to notice

(Neura sdk manager class)[./MedicatioNeura//NeuraSDK%20Manager/NeuraSDKManager.swift] holds the basic interaction with the Neura SDK framework.

* setup - Sets the app id and app secret (you can find them once you create your app using [this guide](https://dev.theneura.com/docs/guide/ios/setup))
  * setup also manages adding a user to the server if it failed when the user authenticated

* login - Handles the authentication process with Neura and adding the user to the server

* addUserToServer - As it name suggests :)... also handles the event subscription with Neura
  * Notice that the event identifier is unique with the user's id from the server. The reason is to identify this user in the server when the event is sent to the webhook

### Developer speceific information

The app is missing some information you need to add by yourself (run a search in the code):
* appUID
* appSecret
* webhookId
* serverUrl

## Using the app

### Dependencies

Run ``` pod install ``` to install NeuraSDK and Alamofire

## License
[MIT](LICENSE)
