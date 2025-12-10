//
//  View+EXT.swift
//  FoodAppSwiftUI
//
//  Created by Hakob Ghlijyan on 12/5/25.
//

import SwiftUI

// MARK: - Dynamic Top Padding
/// Applies adaptive top padding based on the device’s safe area.
///
/// Logic:
/// - Devices without notch (e.g., iPhone SE) → `20pt`
/// - Devices with notch or Dynamic Island → `55pt`
///
/// This ensures consistent visual spacing for headers and top UI elements
/// across all iPhones regardless of screen type.
///
/// - Returns: A view with automatically calculated `.padding(.top)`
extension View {
    func topPaddingForDevice() -> some View {
        let topInset: CGFloat
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first
        
        let safeTop = window?.safeAreaInsets.top ?? 0
        
        if safeTop <= 20 {
            // iPhone SE или другие без выреза
            topInset = 20
        } else {
            // iPhone с island / Dynamic Island
            topInset = 55
        }
        
        return self.padding(.top, topInset)
    }
}

/*
 1️⃣ Safe area top (верхний inset) на разных iPhone
 Пояснение:
     •    «Island» / notch → устройства с верхним вырезом, top safe area ≥44 pt.
     •    iPhone SE / iPhone 8 → без island, top safe area ~20 pt.
     •    iPhone 13 обычный → у него не “остров”, а обычный notch, top safe area ~47 pt.
     •    iPhone 14 Pro / 15 Pro → у них настоящий «Dynamic Island», top safe area ~59 pt.
 ⸻
 2️⃣ Вывод для твоей задачи с padding
 Если хочешь, чтобы padding был:
     •    iPhone SE / 8 / без island → 20 pt
     •    iPhone с обычным notch (iPhone X, 11, 12, 13) → 50 pt
     •    iPhone с Dynamic Island (iPhone 14 Pro, 15 Pro) → 50 pt (можно увеличить, если хочешь больше)
 То код с проверкой через safeAreaInsets.top будет работать для всех этих случаев.
 */
