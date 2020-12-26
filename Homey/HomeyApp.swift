//
//  HomeyApp.swift
//  Homey
//
//  Created by Emile Nijssen on 25/12/2020.
//

import SwiftUI
import Sparkle

@main
struct HomeyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.commands {
            CommandGroup(replacing: .help) {
                Button(action: {
                    if let url = URL(string: "https://homey.support") {
                        NSWorkspace.shared.open(url)
                    }
                }, label: {
                    Text("Homey Support")
                })
                Button(action: {
                    if let url = URL(string: "https://homey.app") {
                        NSWorkspace.shared.open(url)
                    }
                }, label: {
                    Text("Homey Website")
                })
            }
            CommandGroup(after: CommandGroupPlacement.appInfo) {
                Button(action: {
                    let updater = SUUpdater()
                    updater.checkForUpdates(body)
                }, label: {
                    Text("Check for Updates...")
                })
            }
        }
    }
    
    
}
