//
//  DottedGridView.swift
//  DrawingAppSwiftUIPencilKit
//
//  Created by Hakob Ghlijyan on 12/10/25.
//

import SwiftUI
import PencilKit
import PhotosUI

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
