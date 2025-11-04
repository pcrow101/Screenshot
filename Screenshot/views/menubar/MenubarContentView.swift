//
//  MenubarContentView.swift
//  Screenshot
//
//  Created by paul crow on 26/10/2025.
//

import SwiftUI

struct MenubarContentView: View {
    
    @ObservedObject var vm: ScreencaptureViewModel
    @AppStorage("secondScreenAvailable") var secondScreenAvailable = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Your Screenshots")
                    .font(.title2)
                
                if !vm.images.isEmpty {
                    Button("Clear All") {
                        vm.images = []
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .padding(.bottom, 10)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 75, maximum: 150))]) {
                    ForEach(vm.images.reversed(), id: \.self) { image in
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFit()
                            .shadow(radius: 5)
                            .onDrag {
                                let tmpDir = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                                let fileURL = tmpDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")
                                
                                // Convert NSImage to PNG data
                                func pngData(from nsImage: NSImage) -> Data? {
                                    guard
                                        let tiff = nsImage.tiffRepresentation,
                                        let rep = NSBitmapImageRep(data: tiff),
                                        let data = rep.representation(using: .png, properties: [:])
                                    else { return nil }
                                    return data
                                }
                                
                                if let data = pngData(from: image) {
                                    try? data.write(to: fileURL, options: .atomic)
                                    // Provide a file URL
                                    return NSItemProvider(contentsOf: fileURL) ?? NSItemProvider()
                                } else {
                                    // Fallback to in-memory image if conversion failed
                                    return NSItemProvider(object: image)
                                }
                            }
                    }
                }
            }
            .frame(minHeight: 50, maxHeight: 200)
            
            Divider()
                .padding(.horizontal, -15)
            
            HStack {
                Button(action: {
                    vm.takeScreenshot(for: .area)
                }, label: {
                    Label("Area", systemImage: "rectangle.center.inset.filled.badge.plus")
                })
                
                Button(action: {
                    vm.takeScreenshot(for: .window)
                }, label: {
                    Label("Window", systemImage: "macwindow")
                })
                
                if secondScreenAvailable {
                    Button(action: {
                        vm.takeScreenshot(for: .full1)
                    }, label: {
                        Label("Main Screen", systemImage: "macbook.gen2")
                    })
                    Button(action: {
                        vm.takeScreenshot(for: .full2)
                    }, label: {
                        Label("2nd Screen", systemImage: "display")
                    })
                } else {
    
                    Button(action: {
                        vm.takeScreenshot(for: .full1)
                    }, label: {
                        Label("Full Screen", systemImage: "macbook.gen2")
                    })
                }
                
                SettingsLink()
                    .labelStyle(.iconOnly)
            }
            .frame(maxWidth: .infinity)
            .fontWidth(.condensed)

            
        }
        .frame(minWidth: 440)
        .padding()
    }
}

#Preview {
    MenubarContentView(vm: ScreencaptureViewModel())
}
