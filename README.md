# ✨ InkBoard — Modern Drawing App for iOS (SwiftUI + PencilKit)

Beautiful, clean, and developer‑friendly documentation for GitHub.
InkBoard is a minimalistic yet powerful drawing application built with **SwiftUI**, **PencilKit**, and **PhotosUI**, supporting Apple Pencil, background images, and exporting artwork.

---

## 🎯 Overview

InkBoard позволяет пользователю:

* рисовать пальцем или Apple Pencil
* выбирать изображение как фон
* очищать холст в один тап
* сохранять рисунок в Фото в высоком качестве

Интерфейс построен полностью на **SwiftUI**, а мощные графические возможности обеспечиваются через **UIKit** (PKCanvasView).

---

## 🚀 Features

### 🖊 PencilKit Drawing Tools

* Инструменты рисования Apple Pencil
* Поддержка пальца (drawingPolicy = .anyInput)
* Встраивание PKCanvasView через UIViewRepresentable

### 🖼 Import Background Images

* Импорт фото через современный `PHPickerViewController`
* Автоматическая подстановка изображения в качестве подложки

### 💾 Export Artwork

* Комбинирование фона и рисунков PencilKit
* Рендер через `UIGraphicsImageRenderer`
* Сохранение в Фото

### 🎛 Clean UI

* Градиентный header
* Круглые action‑кнопки
* Точечная сетка-фон через SwiftUI Canvas API

---

## 🛠 Technology Stack

| Framework                   | Purpose                      |
| --------------------------- | ---------------------------- |
| **SwiftUI**                 | UI, layout, reactive logic   |
| **PencilKit**               | Холст, инструменты рисования |
| **UIKit Interop**           | Встраивание PKCanvasView     |
| **PhotosUI**                | Импорт изображений           |
| **UIGraphicsImageRenderer** | Экспорт финального рисунка   |

---

## 🧩 Architecture

```
ContentView
│
├── HeaderButton — кнопки в шапке
├── DottedGridView — точечная сетка
└── PencilKitKanvas — PKCanvasView внутри SwiftUI

ImagePicker — импорт фото
```

Главная идея:
**SwiftUI отвечает за UI, UIKit — за точный контроль PencilKit.**

---

## 📘 Detailed Code Documentation

### 1. ContentView

Главный экран, который управляет состоянием: канвас, изображения, tool picker, сохранение.

#### appeared()

Настраивает PencilKit при загрузке экрана.

```swift
/// Configures PKCanvasView and PKToolPicker on appear.
private func appeared() {
    canvasView.drawingPolicy = .anyInput
    toolPicker.setVisible(true, forFirstResponder: canvasView)
    toolPicker.addObserver(canvasView)
    canvasView.becomeFirstResponder()
}
```

#### saveDrawing()

Комбинирует фоновое изображение и рисунок в одно изображение.

```swift
    /// Renders the final combined image and saves it to Photos.
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

        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
```

---

### 2. PencilKitKanvas

Обертка для использования `PKCanvasView` в SwiftUI.

```swift
struct PencilKitKanvas: UIViewRepresentable { ... }
```

Настройки:

* прозрачный фон
* pen tool как инструмент по умолчанию
* полный контроль пальцем и Pencil

---

### 3. ImagePicker

Импорт изображений через Photos API.

Использует Coordinator для получения результата:

```swift
provider.loadObject(ofClass: UIImage.self) { image, _ in
    DispatchQueue.main.async {
        self.parent.image = image as? UIImage
    }
}
```

---

### 4. DottedGridView

Легкий, кастомный фон с использованием `Canvas`.

---

### 5. HeaderButton

Кастомная круглая кнопка для действий: импорт, очистка, сохранение.

---

## 📸 Screenshots

*(Добавь изображения позже)*

```
/docs
   /screen-header.png
   /screen-canvas.png
   /screen-picker.png
```

---

## 🧱 Installation

1. Clone the repo
2. Open in Xcode 15+
3. Run on iOS 16+ device (real device recommended for Apple Pencil)

---

## 🔮 Future Improvements

* Undo/Redo
* Layers system
* Brush size & color selector
* Text tool
* Export to PNG/PDF with transparency

---

## 🧾 License

MIT
