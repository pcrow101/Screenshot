//
//  KeyboardShortcutSettingsView.swift
//  Screenshot
//
//  Created by paul crow on 26/10/2025.
//

import SwiftUI
import KeyboardShortcuts

struct KeyboardShortcutSettingsView: View {
    var body: some View {
        Form {
            KeyboardShortcuts.Recorder("Screenshot Area:",
                                       name: .screenshotCapture)
            KeyboardShortcuts.Recorder("Screenshot Window:",
                                       name: .screenshotCaptureWindow)
            KeyboardShortcuts.Recorder("Screenshot Full Screen:",
                                       name: .screenshotCaptureFull)
        }
        .padding()
    }
}

#Preview {
    KeyboardShortcutSettingsView()
}
