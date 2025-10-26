//
//  ContentView.swift
//  Screenshot
//
//  Created by paul crow on 26/10/2025.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var vm = ScreenshotViewModel()
    @State private var image: NSImage? = nil
    
    var body: some View {
        VStack {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200, maximum: 300))]) {
                ForEach(vm.images, id: \.self) { image in
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                        .onDrag({NSItemProvider(object: image)})                    
                }
            }
            
            Spacer()
            
            HStack {
                Button("Area Screenshot") {
                    vm.takeScreenshot(for: .area)
                }
                Button("Window Screenshot") {
                    vm.takeScreenshot(for: .window)
                }
                Button("Full Screen Screenshot") {
                    vm.takeScreenshot(for: .screen)
                }
            }
            
        }
        .padding()
    }
    
}

#Preview {
    ContentView()
}
