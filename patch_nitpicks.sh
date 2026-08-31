#!/bin/bash
# Adding NSApp.setActivationPolicy(.accessory)
sed -i 's/app.run()/app.setActivationPolicy(.accessory)\napp.run()/' Sources/PinWinTop/main.swift

# Adding collectionBehavior
sed -i '/self.level = .floating/a \        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]' Sources/PinWinTop/FloatingPinWindow.swift
