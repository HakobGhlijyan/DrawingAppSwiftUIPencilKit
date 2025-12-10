//
//  ContentView.swift
//  DrawingAppSwiftUIPencilKit
//
//  Created by Hakob Ghlijyan on 12/10/25.
//

import SwiftUI
import PhotosUI

// MARK: - ContentView
// This SwiftUI view represents the main screen of the drawing application.
// It integrates PencilKit, image importing, saving, and a custom UI.
struct ContentView: View {
    @StateObject private var vm = ContentViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // MARK: Header
            ZStack(alignment: .bottom) {
                background
                header
            }
            .frame(height: 60)
            .topPaddingForDevice()
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            .zIndex(0)
            
            // MARK: Drawing Canvas
            ZStack {
                if let selectedImage = vm.selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                }
                
                // Optional dotted grid background
                DottedGridView()
                // PencilKit Canvas
                PencilKitKanvas(canvasView: $vm.canvasView, toolPicker: $vm.toolPicker)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.white)
            .zIndex(1)
        }
        .ignoresSafeArea(edges: .vertical)
        .sheet(isPresented: $vm.showingImagePicker) {
//            ImagePicker(image: $vm.selectedImage)
            ImageOrCameraPicker(image: $vm.selectedImage, sourceType: .photoLibrary)
        }
        .onAppear(perform: vm.appeared)
    }
}

#Preview {
    ContentView()
}

private extension ContentView {
    // Background gradient
    var background: some View {
        LinearGradient(colors: [
            Color.orange.opacity(0.8),
            Color.red.opacity(0.8)
        ], startPoint: .leading, endPoint: .trailing)
        .ignoresSafeArea()
    }
    
    var header: some View {
        HStack(spacing: 20) {
            // Title & Icon
            HStack(spacing: 12) {
                Image(systemName: "pencil.and.outline")
                    .font(.title3)
                Text("InkBoard")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)

            Spacer()

            // Header Action Buttons
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 40, height: 40)
                    PhotosPicker(selection: $vm.selectedPickerItem, matching: .images) {
                        Image(systemName: "photo.on.rectangle.angled.fill")
                            .foregroundColor(.white)
                    }
                }
                .onChange(of: vm.selectedPickerItem) { newItem in
                    Task { @MainActor in
                        guard let newItem else { return }
                        do {
                            if let data = try await newItem.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                self.vm.selectedImage = uiImage
                            }
                        } catch {
                            print("Ошибка загрузки фото: \(error)")
                        }
                    }
                }
                
                HeaderButton(icon: "photo.on.rectangle.angled", color: .white) {
                    vm.showingImagePicker = true
                }
                
                HeaderButton(icon: "trash", color: .white) {
                    vm.clear()
                }
                
                HeaderButton(icon: "square.and.arrow.down", color: .white) {
                    vm.saveDrawing()
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}
