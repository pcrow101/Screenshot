//
//  Keyboardshortcuts+Global.swift
//  Screenshot
//
//  Created by paul crow on 26/10/2025.
//

import Foundation
import KeyboardShortcuts
internal import AppKit

extension KeyboardShortcuts.Name {

    static let screenshotCapture = Self("screenshotCapture",
                                        default: .init(.three, modifiers: [.option, .command]))
    static let screenshotCaptureWindow = Self("screenshotCaptureWindow",
                                        default: .init(.four, modifiers: [.option, .command]))
    static let screenshotCaptureFull = Self("screenshotCaptureFull",
                                        default: .init(.five, modifiers: [.option, .command]))
}
