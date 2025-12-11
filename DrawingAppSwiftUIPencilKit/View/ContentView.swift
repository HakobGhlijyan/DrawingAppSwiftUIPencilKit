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
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            
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
        }
        .overlay(alignment: .center) {
            if vm.isSaving {
                savingOverlay
            }

            if vm.showSuccess {
                successOverlay
            }
        }
        .sheet(isPresented: $vm.showingImagePicker) {
            ImageOrCameraPicker(image: $vm.selectedImage, sourceType: .photoLibrary)
        }
        .alert("Saved!", isPresented: $vm.showSaveAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your drawing has been saved to the Photos app.")
        }
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
                    .font(.subheadline)
                Text("InkBoard")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            Spacer()
            // Header Action Buttons
            HStack(spacing: 12) {
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
    
    var savingOverlay: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.4)
                .tint(.white)

            Text("Saving…")
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding(30)
        .background(.black.opacity(0.6))
        .cornerRadius(20)
        .transition(.opacity)
    }
    
    var successOverlay: some View {
        Image(systemName: "checkmark.circle.fill")
            .symbolRenderingMode(.palette)
            .foregroundStyle(.white, .green)
            .font(.system(size: 80))
            .transition(.scale.combined(with: .opacity))
    }
}
