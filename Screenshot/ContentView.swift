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
    @AppStorage("thumbnailSize") var thumbnailSize: Double = 200 // persisted thumbnail size
    @State private var showClearAllConfirmation = false
    @State private var selectedPreset: SizePreset = .medium

    enum SizePreset: Int, CaseIterable, Identifiable {
        case xs, small, medium, large, extraLarge, xxl
        var id: Int { rawValue }
        var title: String {
            switch self {
            case .xs: return "XS"
            case .small: return "S"
            case .medium: return "M"
            case .large: return "L"
            case .extraLarge: return "XL"
            case .xxl: return "XXL"
            }
        }
        var size: Double? {
            switch self {
            case .xs: return 80
            case .small: return 200
            case .medium: return 300
            case .large: return 400
            case .extraLarge: return 600
            case .xxl: return 800
            }
        }
    }

    // Map a persisted thumbnailSize to the nearest preset so the Picker reflects it on appear
    private func preset(for size: Double) -> SizePreset {
        var best = SizePreset.medium
        var bestDiff = Double.greatestFiniteMagnitude
        for preset in SizePreset.allCases {
            if let s = preset.size {
                let diff = abs(s - size)
                if diff < bestDiff {
                    bestDiff = diff
                    best = preset
                }
            }
        }
        return best
    }

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

            // Presets controls
            HStack(spacing: 12) {
                Picker("Size", selection: Binding(get: { selectedPreset }, set: { new in
                    selectedPreset = new
                    if let s = new.size {
                        thumbnailSize = s
                    }
                })) {
                    ForEach(SizePreset.allCases) { preset in
                        Text(preset.title).tag(preset)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.vertical, 6)

            // Thumbnails use the persisted thumbnailSize
            GeometryReader { proxy in
                let spacing: CGFloat = 10
                let displayedSize = CGFloat(thumbnailSize)

                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: displayedSize), spacing: spacing)], spacing: spacing) {
                        ForEach(vm.images, id: \.self) { image in
                            ZStack(alignment: .topTrailing) {
                                Image(nsImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: displayedSize)
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
                    .padding(.top, 6)
                    .padding(.bottom, 12)
                }
            }
            .frame(minHeight: 200) // keep GeometryReader from collapsing

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
        .onAppear {
            // Initialize the picker selection from the persisted thumbnail size
            selectedPreset = preset(for: thumbnailSize)
        }
        .padding()
    }
}

#Preview {
    ContentView(vm: ScreencaptureViewModel())
}
