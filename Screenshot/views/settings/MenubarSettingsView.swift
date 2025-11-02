//
//  MenubarSettingsView.swift
//  Screenshot
//
//  Created by paul crow on 26/10/2025.
//

import SwiftUI

struct MenubarSettingsView: View {
    @AppStorage("menuBarExtraIsInserted") var menuBarExtraIsInserted = true
    @AppStorage("playScreenshotSound") var playScreenshotSound = true
    @AppStorage("secondScreenAvailable") var secondScreenAvailable = true
    
    var body: some View {
        Form {
            Toggle("Show menu bar extra", isOn: $menuBarExtraIsInserted)
            Toggle("Play sound on screenshot", isOn: $playScreenshotSound)
            Toggle("Second Screen available", isOn: $secondScreenAvailable)
        }
    }
}

#Preview {
    MenubarSettingsView()
}
