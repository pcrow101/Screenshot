//
//  ContentView.swift
//  Screenshot
//
//  Created by paul crow on 26/10/2025.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var vm: ScreencaptureViewModel
    @AppStorage("secondScreenAvailable") var secondScreenAvailable = true
    
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 200, maximum: 300))]) {
                    ForEach(vm.images, id: \.self) { image in
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFit()
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
                                    // Provide a file URL; OneNote will import the image file
                                    return NSItemProvider(contentsOf: fileURL) ?? NSItemProvider()
                                } else {
                                    // Fallback to in-memory image if conversion failed
                                    return NSItemProvider(object: image)
                                }
                            }
                        
                    }
                }
            }
            
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
                    Button {
                        vm.takeScreenshot(for: .full1)
                    } label: {
                        HStack {
                            Image(systemName: "macbook.gen2")
                            Text("Main Screen")
                        }
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView(vm: ScreencaptureViewModel())
}
