//
//  ContentView.swift
//  DrawingAppSwiftUIPencilKit
//
//  Created by Hakob Ghlijyan on 12/10/25.
//

import SwiftUI
import PencilKit
import PhotosUI

struct ContentView: View {
    @State private var canvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    @State private var showingToolPicker: Bool = true
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker: Bool = false

    
    var body: some View {
        VStack(spacing: 0) {
            //Header
            ZStack(alignment: .bottom) {
                LinearGradient(colors: [
                    Color.orange.opacity(0.8), Color.red.opacity(0.8),
                ], startPoint: .leading, endPoint: .trailing)
                
                HStack(spacing: 20) {
                    HStack(spacing: 12) {
                        Image(systemName: "pencil.and.scribble")
                            .font(.title3)
                        Text("InkBoard")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    
                    Spacer()
                    
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
                .padding(.top, 50)
                .padding(.bottom, 16)
            }
            .frame(height: 130)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            //Canvas
            ZStack {
                //Background
                DottedGridView()
                
                //Canvas
                PencilKitKanvas(canvasView: $canvasView, toolPicker: $toolPicker)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.white)
        }
        .ignoresSafeArea(edges: .vertical)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .onAppear(perform: appeared)
    }
    
    private func saveDrawing() {
        let bounds = canvasView.bounds
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        
        let image = renderer.image { context in
            if let selectedImage {
                //Draw background image if exists
                selectedImage.draw(in: bounds)
            } else {
                //Draw white background
                UIColor.white.setFill()
                context.fill(bounds)
            }
            
            //Draw the canvas drawing on top
            canvasView
                .drawing
                .image(from: bounds, scale: UIScreen.main.scale)
                .draw(in: bounds)
        }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
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

struct DottedGridView: View {
    let dotSize: CGFloat = 2
    let spacing: CGFloat = 20
    
    var body: some View {
        Canvas { context, size in
            let rows = Int(size.height / spacing)
            let columns = Int(size.width / spacing)
            
            for row in 0...rows {
                for column in 0...columns {
                    let x = CGFloat(column) + spacing
                    let y = CGFloat(row) + spacing
                    
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
