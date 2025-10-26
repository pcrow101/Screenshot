//
//  ScreenshotApp.swift
//  Screenshot
//
//  Created by paul crow on 26/10/2025.
//

import SwiftUI

@main
struct ScreenshotApp: App {
    
    @StateObject var vm = ScreencaptureViewModel()
    @AppStorage("menuBarExtraIsInserted") var menuBarExtraIsInserted = true
    
    var body: some Scene {
        MenuBarExtra("Screenshots",
                     systemImage: "photo.badge.plus",
                     isInserted: $menuBarExtraIsInserted) {
            MenubarContentView(vm: vm)
        }
        .menuBarExtraStyle(.window)
        
        Settings {
            SettingsView()
        }
        
        
    }
}
