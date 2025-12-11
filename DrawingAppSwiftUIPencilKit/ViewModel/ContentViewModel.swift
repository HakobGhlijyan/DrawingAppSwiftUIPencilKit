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
    /// Controls presentation of the image picker.
    @Published var showingImagePicker: Bool = false
    @Published var selectedPickerItem: PhotosPickerItem?
    
    @Published var showSaveAlert = false
    @Published var isSaving = false
    @Published var showSuccess = false

    init() { appeared() }
    
    // MARK: Save Drawing
    /// Renders the current drawing (and optional background image) into a single UIImage
    /// and saves it to the user's photo library.
//    func saveDrawing() {
//        let bounds = canvasView.bounds
//        let renderer = UIGraphicsImageRenderer(bounds: bounds)
//        
//        let image = renderer.image { context in
//            
//            // --- 1. Fill background white
//            UIColor.white.setFill()
//            context.fill(bounds)
//            
//            // --- 2. Draw background image with aspectFit (NOT full stretch)
//            if let selectedImage {
//                
//                let imageSize = selectedImage.size
//                let canvasSize = bounds.size
//                
//                // Calculate aspectFit rect
//                let imageAspect = imageSize.width / imageSize.height
//                let canvasAspect = canvasSize.width / canvasSize.height
//                
//                var drawRect = CGRect.zero
//                
//                if imageAspect > canvasAspect {
//                    // image is wider → full width, height scaled
//                    let width = canvasSize.width
//                    let height = width / imageAspect
//                    drawRect = CGRect(
//                        x: 0,
//                        y: (canvasSize.height - height) / 2,
//                        width: width,
//                        height: height
//                    )
//                } else {
//                    // image is taller → full height, width scaled
//                    let height = canvasSize.height
//                    let width = height * imageAspect
//                    drawRect = CGRect(
//                        x: (canvasSize.width - width) / 2,
//                        y: 0,
//                        width: width,
//                        height: height
//                    )
//                }
//                
//                selectedImage.draw(in: drawRect)
//            }
//            
//            // --- 3. Draw PencilKit drawing on top
//            let drawingImage = canvasView.drawing.image(
//                from: bounds,
//                scale: UIScreen.main.scale
//            )
//            drawingImage.draw(in: bounds)
//        }
//        
//        // Сохраняем и обрабатываем результат
//        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//    }
    
//    func saveDrawing(completion: @escaping (Bool) -> Void) {
//        let bounds = canvasView.bounds
//        let renderer = UIGraphicsImageRenderer(bounds: bounds)
//
//        // Рендер — можно делать на фоновом потоке
//        DispatchQueue.global(qos: .userInitiated).async {
//
//            let image = renderer.image { context in
//
//                // 1) Белый фон
//                UIColor.white.setFill()
//                context.fill(bounds)
//
//                // 2) Фоновое изображение
//                if let selectedImage = self.selectedImage {
//                    let imageSize = selectedImage.size
//                    let canvasSize = bounds.size
//
//                    let imageAspect = imageSize.width / imageSize.height
//                    let canvasAspect = canvasSize.width / canvasSize.height
//
//                    var drawRect = CGRect.zero
//
//                    if imageAspect > canvasAspect {
//                        let width = canvasSize.width
//                        let height = width / imageAspect
//                        drawRect = CGRect(
//                            x: 0,
//                            y: (canvasSize.height - height) / 2,
//                            width: width,
//                            height: height
//                        )
//                    } else {
//                        let height = canvasSize.height
//                        let width = height * imageAspect
//                        drawRect = CGRect(
//                            x: (canvasSize.width - width) / 2,
//                            y: 0,
//                            width: width,
//                            height: height
//                        )
//                    }
//
//                    selectedImage.draw(in: drawRect)
//                }
//
//                // 3) Рисунок PencilKit
//                let drawingImage = self.canvasView.drawing.image(from: bounds, scale: UIScreen.main.scale)
//                drawingImage.draw(in: bounds)
//            }
//
//            // Теперь сохраняем через Photos Framework
//            PHPhotoLibrary.shared().performChanges({
//                PHAssetChangeRequest.creationRequestForAsset(from: image)
//            }) { success, error in
//                DispatchQueue.main.async {
//                    if let error = error {
//                        print("🔥 Ошибка сохранения: \(error.localizedDescription)")
//                    }
//                    completion(success && error == nil)
//                }
//            }
//        }
//    }
    
    func saveDrawing() {
        isSaving = true
        showSuccess = false
        
        let bounds = canvasView.bounds
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        
        DispatchQueue.global(qos: .userInitiated).async {
            let image = renderer.image { context in
                UIColor.white.setFill()
                context.fill(bounds)
                
                if let selectedImage = self.selectedImage {
                    let imageSize = selectedImage.size
                    let canvasSize = bounds.size
                    
                    let imageAspect = imageSize.width / imageSize.height
                    let canvasAspect = canvasSize.width / canvasSize.height
                    
                    var drawRect = CGRect.zero
                    
                    if imageAspect > canvasAspect {
                        let width = canvasSize.width
                        let height = width / imageAspect
                        drawRect = CGRect(x: 0, y: (canvasSize.height - height) / 2, width: width, height: height)
                    } else {
                        let height = canvasSize.height
                        let width = height * imageAspect
                        drawRect = CGRect(x: (canvasSize.width - width) / 2, y: 0, width: width, height: height)
                    }
                    
                    selectedImage.draw(in: drawRect)
                }
                
                let drawingImage = self.canvasView.drawing.image(
                    from: bounds,
                    scale: UIScreen.main.scale
                )
                drawingImage.draw(in: bounds)
            }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { success, error in
                DispatchQueue.main.async {
                    
                    self.isSaving = false
                    
                    if success && error == nil {
                        self.triggerHaptic()

                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            self.showSuccess = true
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                self.showSuccess = false
                            }
                            self.showSaveAlert = true
                        }
                    }

                }
            }
        }
    }
    
    // MARK: - HAPTIC
    func triggerHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
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
}
