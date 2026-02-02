import AppKit

/// Generates an 8-bit pixel art Gandalf-style wizard icon for the menu bar.
/// For notch blending: the icon is wider than normal with a black background
/// that visually extends the MacBook notch. The wizard sits on the left side
/// and the right side is pure black, seamlessly merging with the notch.
struct WizardIcon {

    // MARK: - Pixel Art Definition

    /// 18x18 pixel grid — Gandalf-inspired wizard with tall pointed hat, long beard, staff
    /// Values encode body parts for coloring:
    ///   0 = empty, 1 = hat, 2 = face, 3 = beard, 4 = robe, 5 = staff, 6 = staff crystal
    static let pixelMap: [[UInt8]] = [
        // Tall pointed hat — slightly crooked like Gandalf's
        [0,0,0,0,0,0,0,0,1,0,0,0,0,6,0,0,0,0],  // row 0:  hat tip + staff crystal
        [0,0,0,0,0,0,0,1,1,1,0,0,0,5,0,0,0,0],  // row 1:  hat + staff
        [0,0,0,0,0,0,1,1,1,1,0,0,0,5,0,0,0,0],  // row 2:  hat body + staff
        [0,0,0,0,0,1,1,0,1,1,0,0,0,5,0,0,0,0],  // row 3:  hat — star cutout + staff
        [0,0,0,0,1,1,1,1,1,1,0,0,0,5,0,0,0,0],  // row 4:  hat lower + staff
        [0,0,0,1,1,1,1,1,1,1,1,0,0,5,0,0,0,0],  // row 5:  hat brim + staff
        // Face
        [0,0,0,0,2,2,2,2,2,2,0,0,0,5,0,0,0,0],  // row 6:  forehead + staff
        [0,0,0,0,2,0,2,2,0,2,0,0,0,5,0,0,0,0],  // row 7:  eyes + staff
        [0,0,0,0,2,2,2,2,2,2,0,0,0,5,0,0,0,0],  // row 8:  face + staff
        // Beard — long and flowing, classic Gandalf
        [0,0,0,0,0,3,3,0,3,3,0,0,0,5,0,0,0,0],  // row 9:  mustache + staff
        [0,0,0,0,3,3,3,3,3,3,3,0,0,5,0,0,0,0],  // row 10: beard + staff
        [0,0,0,3,3,3,0,3,0,3,3,0,0,5,0,0,0,0],  // row 11: flowing beard + staff
        // Robe — arm reaching to hold staff
        [0,0,0,4,4,4,4,4,4,4,0,4,4,5,0,0,0,0],  // row 12: robe + arm to staff
        [0,0,0,0,4,4,4,4,4,4,4,0,0,0,0,0,0,0],  // row 13: robe body
        [0,0,0,0,0,4,4,4,4,4,0,0,0,0,0,0,0,0],  // row 14: robe narrowing
        [0,0,0,0,0,4,4,4,4,4,0,0,0,0,0,0,0,0],  // row 15: robe
        [0,0,0,0,4,4,4,4,4,4,4,0,0,0,0,0,0,0],  // row 16: robe bottom hem
        [0,0,0,0,4,4,0,0,0,4,4,0,0,0,0,0,0,0],  // row 17: feet
    ]

    // MARK: - Menu Bar Icon (Notch-Blending)

    /// Width of the full status item image in points.
    /// The extra width beyond the wizard creates a black buffer that blends with the notch.
    static let statusItemWidth: CGFloat = 42

    /// Creates the menu bar icon: white wizard on a pure black background.
    /// NOT a template image — the black background is intentional for notch blending.
    /// The wizard is drawn on the left; the right side is solid black.
    static func createMenuBarIcon() -> NSImage {
        let wizardSize: CGFloat = 18
        let totalWidth = statusItemWidth
        let totalHeight: CGFloat = 22  // menu bar content height
        let pixelSize: CGFloat = 1.0
        let gridSize = 18

        let imageSize = NSSize(width: totalWidth, height: totalHeight)

        let image = NSImage(size: imageSize, flipped: false) { rect in
            // Fill entire rect with pure black — matches the notch
            NSColor.black.setFill()
            rect.fill()

            // Offset: center the 18px wizard vertically, place it on the left with small padding
            let offsetX: CGFloat = 4
            let offsetY: CGFloat = (totalHeight - wizardSize) / 2

            // Draw wizard pixels in white
            NSColor.white.setFill()

            for row in 0..<gridSize {
                for col in 0..<gridSize {
                    if pixelMap[row][col] > 0 {
                        let pixelRect = NSRect(
                            x: offsetX + CGFloat(col) * pixelSize,
                            y: offsetY + CGFloat(gridSize - 1 - row) * pixelSize,
                            width: pixelSize,
                            height: pixelSize
                        )
                        pixelRect.fill()
                    }
                }
            }
            return true
        }

        // NOT a template — we need the black background to stay black
        image.isTemplate = false
        return image
    }

    /// Creates a @2x retina version for crisp rendering
    static func createMenuBarIconRetina() -> NSImage {
        let totalWidth = statusItemWidth * 2
        let totalHeight: CGFloat = 44  // 22pt * 2
        let pixelSize: CGFloat = 2.0
        let gridSize = 18

        let imageSize = NSSize(width: totalWidth, height: totalHeight)

        let image = NSImage(size: imageSize, flipped: false) { rect in
            NSColor.black.setFill()
            rect.fill()

            let offsetX: CGFloat = 8  // 4pt * 2
            let offsetY: CGFloat = (totalHeight - CGFloat(gridSize) * pixelSize) / 2

            NSColor.white.setFill()

            for row in 0..<gridSize {
                for col in 0..<gridSize {
                    if pixelMap[row][col] > 0 {
                        let pixelRect = NSRect(
                            x: offsetX + CGFloat(col) * pixelSize,
                            y: offsetY + CGFloat(gridSize - 1 - row) * pixelSize,
                            width: pixelSize,
                            height: pixelSize
                        )
                        pixelRect.fill()
                    }
                }
            }
            return true
        }

        image.isTemplate = false

        // Create a multi-representation image for retina
        let finalImage = NSImage(size: NSSize(width: statusItemWidth, height: 22))
        finalImage.addRepresentation(image.representations.first!)
        finalImage.isTemplate = false
        return finalImage
    }

    /// Combined icon that includes both 1x and 2x representations
    static func createMenuBarIconMultiRes() -> NSImage {
        let logicalWidth = statusItemWidth
        let logicalHeight: CGFloat = 22
        let gridSize = 18

        // Create the image at logical size
        let image = NSImage(size: NSSize(width: logicalWidth, height: logicalHeight))

        // Add 2x bitmap representation for retina
        let bitmapRep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(logicalWidth * 2),
            pixelsHigh: Int(logicalHeight * 2),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        )!

        bitmapRep.size = NSSize(width: logicalWidth, height: logicalHeight)

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)

        let scale: CGFloat = 2.0

        // Black background
        NSColor.black.setFill()
        NSRect(x: 0, y: 0, width: logicalWidth * scale, height: logicalHeight * scale).fill()

        // Draw wizard in white at 2x
        NSColor.white.setFill()
        let pixelSize: CGFloat = scale
        let offsetX: CGFloat = 4 * scale
        let offsetY: CGFloat = (logicalHeight * scale - CGFloat(gridSize) * pixelSize) / 2

        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if pixelMap[row][col] > 0 {
                    let pixelRect = NSRect(
                        x: offsetX + CGFloat(col) * pixelSize,
                        y: offsetY + CGFloat(gridSize - 1 - row) * pixelSize,
                        width: pixelSize,
                        height: pixelSize
                    )
                    pixelRect.fill()
                }
            }
        }

        NSGraphicsContext.restoreGraphicsState()

        image.addRepresentation(bitmapRep)
        image.isTemplate = false
        return image
    }

    // MARK: - Large Colored Icon

    /// Creates a larger colored version for the app icon, about screen, and empty state.
    /// Gandalf-style coloring: grey hat, tan face, white/grey beard, grey robe, brown staff.
    static func createLargeIcon(size: CGFloat = 128) -> NSImage {
        let gridSize = 18
        let pixelSize = size / CGFloat(gridSize + 2)  // +2 for padding
        let imageSize = NSSize(width: size, height: size)

        // Color palette — muted Gandalf tones
        let colors: [UInt8: NSColor] = [
            1: NSColor(red: 0.40, green: 0.38, blue: 0.55, alpha: 1.0),  // hat: dusty grey-purple
            2: NSColor(red: 0.88, green: 0.73, blue: 0.58, alpha: 1.0),  // face: warm tan
            3: NSColor(red: 0.85, green: 0.83, blue: 0.80, alpha: 1.0),  // beard: silver-white
            4: NSColor(red: 0.45, green: 0.43, blue: 0.50, alpha: 1.0),  // robe: grey
            5: NSColor(red: 0.50, green: 0.35, blue: 0.20, alpha: 1.0),  // staff: brown
            6: NSColor(red: 0.70, green: 0.85, blue: 1.00, alpha: 1.0),  // crystal: pale blue glow
        ]

        let image = NSImage(size: imageSize, flipped: false) { rect in
            // Dark background
            NSColor(red: 0.05, green: 0.05, blue: 0.08, alpha: 1.0).setFill()
            rect.fill()

            let offsetX = (size - CGFloat(gridSize) * pixelSize) / 2
            let offsetY = (size - CGFloat(gridSize) * pixelSize) / 2

            for row in 0..<gridSize {
                for col in 0..<gridSize {
                    let val = pixelMap[row][col]
                    if val > 0, let color = colors[val] {
                        color.setFill()
                        let pixelRect = NSRect(
                            x: offsetX + CGFloat(col) * pixelSize,
                            y: offsetY + CGFloat(gridSize - 1 - row) * pixelSize,
                            width: pixelSize,
                            height: pixelSize
                        )
                        pixelRect.fill()
                    }
                }
            }
            return true
        }

        return image
    }
}
