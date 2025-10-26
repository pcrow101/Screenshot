//
//  SettingsView.swift
//  Screenshot
//
//  Created by paul crow on 26/10/2025.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            KeyboardShortcutSettingsView()
                .tabItem { Label("Keyboard", systemImage: "keyboard") }
            
            MenubarSettingsView()
                .tabItem { Label("MenuBarExtra", systemImage: "rectangle.topthird.inset.filled") }
        }
        .frame(minWidth: 400, minHeight: 300)
    }
}

#Preview {
    SettingsView()
}
