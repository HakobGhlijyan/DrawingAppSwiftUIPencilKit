//
//  ContentView.swift
//  DrawingAppSwiftUIPencilKit
//
//  Created by Hakob Ghlijyan on 12/10/25.
//

// MARK: - ContentView
// This SwiftUI view represents the main screen of the drawing application.
// It integrates PencilKit, image importing, saving, and a custom UI.

import SwiftUI
import PencilKit
import PhotosUI

struct ContentView: View {
    /// PKCanvasView instance used for drawing.
    @State private var canvasView = PKCanvasView()
    /// Tool picker for PencilKit tools.
    @State private var toolPicker = PKToolPicker()
    /// Controls visibility of the PencilKit tool picker.
    @State private var showingToolPicker: Bool = true
    /// Selected background image from the photo library.
    @State private var selectedImage: UIImage?
    /// Controls presentation of the image picker.
    @State private var showingImagePicker: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // MARK: Header
            ZStack(alignment: .bottom) {
                // Background gradient
                LinearGradient(colors: [
                    Color.orange.opacity(0.8),
                    Color.red.opacity(0.8)
                ], startPoint: .leading, endPoint: .trailing)
                .ignoresSafeArea()
                
                HStack(spacing: 20) {
                    // Title & Icon
                    HStack(spacing: 12) {
                        Image(systemName: "pencil.and.scribble")
                            .font(.title3)
                        Text("InkBoard")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(.white)

                    Spacer()

                    // Header Action Buttons
                    HStack(spacing: 12) {
                        HeaderButton(icon: "photo.on.rectangle.angled", color: .white) {
                            showingImagePicker = true
                        }
                        
                        HeaderButton(icon: "trash", color: .white) {
                            canvasView.drawing = PKDrawing()
                            selectedImage = nil
                        }
                        
                        HeaderButton(icon: "square.and.arrow.down", color: .white) {
                            saveDrawing()
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
            }
            .frame(height: 60)
            .topPaddingForDevice()
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            .zIndex(0)

            // MARK: Drawing Canvas
            ZStack {
                if let selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                }

                // Optional dotted grid background
                DottedGridView()
                
                // PencilKit Canvas
                PencilKitKanvas(canvasView: $canvasView, toolPicker: $toolPicker)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.white)
            .zIndex(1)
        }
        .ignoresSafeArea(edges: .vertical)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .onAppear(perform: appeared)
    }

    // MARK: Save Drawing
    /// Renders the current drawing (and optional background image) into a single UIImage
    /// and saves it to the user's photo library.
    private func saveDrawing() {
        let bounds = canvasView.bounds
        let renderer = UIGraphicsImageRenderer(bounds: bounds)

        let image = renderer.image { context in
            
            // --- 1. Fill background white
            UIColor.white.setFill()
            context.fill(bounds)

            // --- 2. Draw background image with aspectFit (NOT full stretch)
            if let selectedImage {

                let imageSize = selectedImage.size
                let canvasSize = bounds.size
                
                // Calculate aspectFit rect
                let imageAspect = imageSize.width / imageSize.height
                let canvasAspect = canvasSize.width / canvasSize.height
                
                var drawRect = CGRect.zero
                
                if imageAspect > canvasAspect {
                    // image is wider → full width, height scaled
                    let width = canvasSize.width
                    let height = width / imageAspect
                    drawRect = CGRect(
                        x: 0,
                        y: (canvasSize.height - height) / 2,
                        width: width,
                        height: height
                    )
                } else {
                    // image is taller → full height, width scaled
                    let height = canvasSize.height
                    let width = height * imageAspect
                    drawRect = CGRect(
                        x: (canvasSize.width - width) / 2,
                        y: 0,
                        width: width,
                        height: height
                    )
                }

                selectedImage.draw(in: drawRect)
            }

            // --- 3. Draw PencilKit drawing on top
            let drawingImage = canvasView.drawing.image(
                from: bounds,
                scale: UIScreen.main.scale
            )
            drawingImage.draw(in: bounds)
        }

        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    // MARK: Appearance Configuration
    /// Configures the PencilKit tool picker and prepares the canvas.
    private func appeared() {
        canvasView.drawingPolicy = .anyInput
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
    }
}

#Preview {
    ContentView()
}

// MARK: - Header Button
/// Custom reusable icon button used in the app header.
struct HeaderButton: View {
    var icon: String
    var color: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(color)
                .frame(width: 40, height: 40)
                .background(.white.opacity(0.2))
                .clipShape(.circle)
        }
    }
}

// MARK: - Dotted Grid Background
/// Draws a grid of evenly spaced dots using `Canvas`. Used as a decorative drawing background.
struct DottedGridView: View {
    let dotSize: CGFloat = 2
    let spacing: CGFloat = 20

    var body: some View {
        Canvas { context, size in
            let rows = Int(size.height / spacing)
            let columns = Int(size.width / spacing)

            for row in 0...rows {
                for column in 0...columns {
                    let x = CGFloat(column) * spacing
                    let y = CGFloat(row) * spacing
                    let rect = CGRect(x: x, y: y, width: dotSize, height: dotSize)

                    context.fill(
                        Path(ellipseIn: rect),
                        with: .color(.gray.opacity(0.2))
                    )
                }
            }
        }
    }
}

// MARK: - PencilKit Canvas Wrapper
/// Wraps `PKCanvasView` into SwiftUI using `UIViewRepresentable`.
/// Responsible for configuring the drawing tool and syncing tool picker.
struct PencilKitKanvas: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var toolPicker: PKToolPicker

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 2)
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .anyInput
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) { }
}

// MARK: - Image Picker for Importing Photos
/// A wrapper around `PHPickerViewController` for selecting a background image from the photo library.
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    var allowEditing: UIImagePickerController.InfoKey = .editedImage
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) { }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    // MARK: Coordinator
    /// Handles the result of the image selection process.
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            guard let provider = results.first?.itemProvider else { return }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.image = image as? UIImage
                    }
                }
            }
        }
    }
}
