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
    @State private var confirmingClearAll = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Your Screenshots")
                    .font(.title2)
                
                if !vm.images.isEmpty {
                    if confirmingClearAll {
                        Button {
                            vm.removeAll()
                            confirmingClearAll = false
                        } label: {
                            Label("Confirm Delete", systemImage: "trash")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        .onAppear {
                            // Auto-cancel after 4 seconds if not confirmed
                            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                confirmingClearAll = false
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    } else {
                        Button("Clear All") {
                            confirmingClearAll = true
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
            }
            .padding(.bottom, 10)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 75, maximum: 150))]) {
                    ForEach(vm.images.reversed(), id: \.self) { image in
                        ZStack(alignment: .topTrailing) {
                            Image(nsImage: image)
                                .resizable()
                                .scaledToFit()
                                .shadow(radius: 5)
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
                                    .font(.caption)
                                    .padding(4)
                            }
                            .buttonStyle(.plain)
                            .background(.ultraThinMaterial, in: Circle())
                            .padding(4)
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

