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
    
    // MARK: - Deletion
    /// Delete screenshots at the given offsets (use with List.onDelete)
    func delete(at offsets: IndexSet) {
        images.remove(atOffsets: offsets)
    }

    /// Delete a screenshot at a specific index if valid
    func delete(at index: Int) {
        guard images.indices.contains(index) else { return }
        images.remove(at: index)
    }

    /// Delete the first matching screenshot instance
    func delete(_ image: NSImage) {
        if let idx = images.firstIndex(where: { $0 == image }) {
            images.remove(at: idx)
        }
    }

    /// Remove all captured screenshots
    func removeAll() {
        images.removeAll()
    }
}
