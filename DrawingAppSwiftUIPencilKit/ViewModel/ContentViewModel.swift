//
//  ContentViewModel.swift
//  DrawingAppSwiftUIPencilKit
//
//  Created by Hakob Ghlijyan on 12/10/25.
//

import SwiftUI
import Combine
import PencilKit
import PhotosUI

final class ContentViewModel: ObservableObject{
    /// PKCanvasView instance used for drawing.
    @Published var canvasView = PKCanvasView()
    /// Tool picker for PencilKit tools.
    @Published var toolPicker = PKToolPicker()
    /// Controls visibility of the PencilKit tool picker.
    @Published var showingToolPicker: Bool = true
    /// Selected background image from the photo library.
    @Published var selectedImage: UIImage?
    
    @Published private var _selectedPhotoItem: Any? // internal storage
    
    @available(iOS 16.0, *)
    var selectedPhotoItem: PhotosPickerItem? {
        get { _selectedPhotoItem as? PhotosPickerItem }
        set { _selectedPhotoItem = newValue }
    }
    
    /// Controls presentation of the image picker.
    @Published var showingImagePicker: Bool = false
    
    // Для показа Alert
    @Published var showSaveAlert = false
    @Published var saveMessage = ""
    
    // MARK: Save Drawing
    /// Renders the current drawing (and optional background image) into a single UIImage
    /// and saves it to the user's photo library.
    func saveDrawing() {
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
        
        // Сохраняем и обрабатываем результат
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompletion(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func saveCompletion(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        DispatchQueue.main.async {
            if let error = error {
                self.saveMessage = "Ошибка при сохранении: \(error.localizedDescription)"
            } else {
                self.saveMessage = "Изображение успешно сохранено!"
            }
            self.showSaveAlert = true
        }
    }
    
    
    // MARK: Appearance Configuration
    /// Configures the PencilKit tool picker and prepares the canvas.
    func appeared() {
        canvasView.drawingPolicy = .anyInput
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
    }
    
    func clear() {
        canvasView.drawing = PKDrawing()
        selectedImage = nil
    }
    
    @available(iOS 16.0, *)
    func loadImage() {
        guard let item = selectedPhotoItem else { return }
        
        Task {
            do {
                if let data = try await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        self.selectedImage = uiImage
                    }
                }
            } catch {
                print("Ошибка загрузки изображения: \(error)")
            }
        }
    }
    
}
