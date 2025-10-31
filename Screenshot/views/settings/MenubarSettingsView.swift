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
    
    var body: some View {
        Form {
            Toggle("Show menu bar extra", isOn: $menuBarExtraIsInserted)
            Toggle("Play sound on screenshot", isOn: $playScreenshotSound)
        }
    }
}

#Preview {
    MenubarSettingsView()
}
