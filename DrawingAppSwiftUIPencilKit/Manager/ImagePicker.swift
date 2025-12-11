//
//  ImagePicker.swift
//  DrawingAppSwiftUIPencilKit
//
//  Created by Hakob Ghlijyan on 12/10/25.
//

import SwiftUI
import PencilKit
import PhotosUI

// MARK: - Image Picker for Importing Photos
/// A wrapper around `PHPickerViewController` for selecting a background image from the photo library.
//struct ImagePicker: UIViewControllerRepresentable {
//    @Binding var image: UIImage?
//    var sourceType: UIImagePickerController.SourceType = .photoLibrary
//    var allowEditing: UIImagePickerController.InfoKey = .editedImage
//    @Environment(\.dismiss) private var dismiss
//
//    func makeUIViewController(context: Context) -> PHPickerViewController {
//        var config = PHPickerConfiguration()
//        config.filter = .images
//        config.selectionLimit = 1
//
//        let picker = PHPickerViewController(configuration: config)
//        picker.delegate = context.coordinator
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) { }
//
//    func makeCoordinator() -> Coordinator { Coordinator(self) }
//
//    // MARK: Coordinator
//    /// Handles the result of the image selection process.
//    class Coordinator: NSObject, PHPickerViewControllerDelegate {
//        var parent: ImagePicker
//
//        init(_ parent: ImagePicker) {
//            self.parent = parent
//        }
//
//        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//            parent.dismiss()
//            guard let provider = results.first?.itemProvider else { return }
//
//            if provider.canLoadObject(ofClass: UIImage.self) {
//                provider.loadObject(ofClass: UIImage.self) { image, _ in
//                    DispatchQueue.main.async {
//                        self.parent.image = image as? UIImage
//                    }
//                }
//            }
//        }
//    }
//}

//struct ImageOrCameraPicker: UIViewControllerRepresentable {
//    @Binding var image: UIImage?
//    var sourceType: UIImagePickerController.SourceType = .photoLibrary
//    var allowEditing: UIImagePickerController.InfoKey = .editedImage
//    
//    func makeUIViewController(context: Context) -> UIImagePickerController {
//        let picker = UIImagePickerController ()
//        picker.allowsEditing = allowEditing == .editedImage
//        picker.sourceType = sourceType
//        picker.delegate = context.coordinator
//        return picker
//    }
//    
//    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
//        
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(self)
//    }
//    
//    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
//        var parent: ImageOrCameraPicker
//        
//        init(_ parent: ImageOrCameraPicker) {
//            self.parent = parent
//        }
//        
//        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//            if let uiImage = info[parent.allowEditing] as? UIImage {
//                self.parent.image = uiImage
//            }
//            picker.dismiss(animated: true)
//        }
//    }
//}
