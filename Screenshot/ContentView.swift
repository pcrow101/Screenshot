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
    @State private var showClearAllConfirmation = false
    
    
    var body: some View {
        VStack {
            HStack {
                Text("Your Screenshots")
                    .font(.title2)
                Spacer()
                if !vm.images.isEmpty {
                    Button("Clear All") {
                        showClearAllConfirmation = true
                    }
                }
            }
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 200, maximum: 300))]) {
                    ForEach(vm.images, id: \.self) { image in
                        ZStack(alignment: .topTrailing) {
                            Image(nsImage: image)
                                .resizable()
                                .scaledToFit()
                                .contextMenu {
                                    Button(role: .destructive) {
                                        vm.delete(image)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .onDrag {
                                    let tmpDir = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                                    let fileURL = tmpDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")
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
                                        return NSItemProvider(contentsOf: fileURL) ?? NSItemProvider()
                                    } else {
                                        return NSItemProvider(object: image)
                                    }
                                }

                            Button {
                                vm.delete(image)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .symbolRenderingMode(.multicolor)
                                    .font(.title3)
                                    .padding(6)
                            }
                            .buttonStyle(.plain)
                            .background(.ultraThinMaterial, in: Circle())
                            .padding(6)
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
        .alert("Delete all screenshots?", isPresented: $showClearAllConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete All", role: .destructive) {
                vm.removeAll()
            }
        } message: {
            Text("This action cannot be undone.")
        }
        .padding()
    }
}

#Preview {
    ContentView(vm: ScreencaptureViewModel())
}
