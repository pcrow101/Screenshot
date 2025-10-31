//
//  ScreencaptureViewModel.swift
//  Screenshot
//
//  Created by paul crow on 26/10/2025.
//

import SwiftUI
import KeyboardShortcuts
import Combine

class ScreencaptureViewModel: ObservableObject {
    
    @AppStorage("playScreenshotSound") private var playScreenshotSound: Bool = true
    
    enum ScreenshotTypes {
        case full
        case window
        case area
        
        func processArguments(playSound: Bool) -> [String] {
            switch self {
                case .full:
                    return playSound ? ["-c"] : ["-cx"]
                case .window:
                    return playSound ? ["-cw"] : ["-cwx"]
                case .area:
                    return playSound ? ["-cs"] : ["-csx"]
            }
        }
    }
    
    
   @Published var images = [NSImage]()
 
    init() {
        KeyboardShortcuts.onKeyUp(for: .screenshotCapture) { [self] in
            self.takeScreenshot(for: .area)
        }
        
        KeyboardShortcuts.onKeyUp(for: .screenshotCaptureFull) { [self] in
            self.takeScreenshot(for: .full)
        }
        
        KeyboardShortcuts.onKeyUp(for: .screenshotCaptureWindow) { [self] in
            self.takeScreenshot(for: .window)
        }
    }
    
    func takeScreenshot(for type: ScreenshotTypes) {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        task.arguments = type.processArguments(playSound: playScreenshotSound)
        
        do {
            try task.run()
            task.waitUntilExit()
            getImageFromPasteboard()
        } catch {
            print("could not take screenshot: \(error)")
        }
    }
    
   private func getImageFromPasteboard() {
        guard NSPasteboard.general.canReadItem(withDataConformingToTypes: NSImage.imageTypes) else { return }
        
        guard let image =  NSImage(pasteboard: NSPasteboard.general) else { return }
        
        self.images.append(image)
    }
}
