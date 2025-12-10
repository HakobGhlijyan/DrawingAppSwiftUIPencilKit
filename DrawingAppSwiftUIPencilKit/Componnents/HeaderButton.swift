//
//  HeaderButton.swift
//  DrawingAppSwiftUIPencilKit
//
//  Created by Hakob Ghlijyan on 12/10/25.
//

import SwiftUI
import PencilKit
import PhotosUI

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
