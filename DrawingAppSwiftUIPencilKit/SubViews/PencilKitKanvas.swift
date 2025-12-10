//
//  PencilKitKanvas.swift
//  DrawingAppSwiftUIPencilKit
//
//  Created by Hakob Ghlijyan on 12/10/25.
//

import SwiftUI
import PencilKit
import PhotosUI

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
