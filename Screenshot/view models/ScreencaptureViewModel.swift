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
        case full1
        case full2
        case window
        case area
        
        func processArguments(playSound: Bool) -> [String] {
            switch self {
                case .full1:
                    return playSound ? ["-c"] : ["-cxD1"]
                case .full2:
                    return playSound ? ["-c"] : ["-cxD2"]
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
            self.takeScreenshot(for: .full1)
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
