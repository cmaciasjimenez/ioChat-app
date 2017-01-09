# ioChat-app
Application for iOS and watchOS. You can send text messages and location coordinates between devices through Socket.io.

# Description

This is an app to send and receive messages from iOS to watchOS and viceversa. You can also do the same with a browser app for Socket.io (works between the three platforms). You will need a Socket.io server for the app in order to get it to work.

The node.js server I built myself for this app is also available [here](https://github.com/cmaciasjimenez/ioChat-server).

## Message types:

- Text: ["type": "messages", "value": "message-string"]
- Position: ["type": "position", "latitude": latitude, "longitude": longitude]

# How to use

1. Download the files and open *iochat app.xcodeproj* with Xcode.
2. Set the URL for your server in *SocketIOManager.swift*
3. Run the app.
