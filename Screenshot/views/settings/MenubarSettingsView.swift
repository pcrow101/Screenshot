//
//  MenubarSettingsView.swift
//  Screenshot
//
//  Created by paul crow on 26/10/2025.
//

import SwiftUI

struct MenubarSettingsView: View {
    @AppStorage("menuBarExtraIsInserted") var menuBarExtraIsInserted = true
    
    var body: some View {
        Form {
            Toggle("show menu bar extra", isOn: $menuBarExtraIsInserted)
        }
    }
}

#Preview {
    MenubarSettingsView()
}
