//
//  ScreencaptureViewModel.swift
//  Screenshot
//
//  Created by paul crow on 26/10/2025.
//

import SwiftUI
import Combine

class ScreenshotViewModel: ObservableObject {

    enum ScreenshotTypes {
        case screen
        case window
        case area
        
        var screenshotType: [String] {
            switch self {
            case .screen:
                ["-c"]
            case .window:
                ["-cw"]
            case .area:
                ["-cs"]
            }
        }
    }
    
    
    @Published var images = [NSImage]()
    
    func takeScreenshot(for type: ScreenshotTypes) {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        task.arguments = type.screenshotType
        
        do {
            try task.run()
            task.waitUntilExit()
            getImageFromPastboard()
        } catch {
            print("Could not take Screenshot: \(error)")
        }
    }
    
    private func getImageFromPastboard() {
        guard NSPasteboard.general.canReadItem(withDataConformingToTypes: NSImage.imageTypes) else { return }
        
        guard let image = NSImage(pasteboard: NSPasteboard.general) else { return }
        
        self.images.append(image)
        
    }
}
