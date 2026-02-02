import AppKit

/// Generates an 8-bit pixel art wizard icon for the menu bar
/// Designed as a template image so macOS handles light/dark mode tinting
/// The wizard has a pointed hat, simple face, and robe — fits in 22x22pt
struct WizardIcon {

    /// 18x18 pixel grid defining the wizard shape
    /// 1 = filled pixel, 0 = transparent
    static let pixelMap: [[UInt8]] = [
        // Row 0: Hat tip
        [0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0],
        // Row 1
        [0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0],
        // Row 2: Hat upper
        [0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0],
        // Row 3
        [0,0,0,0,0,0,1,1,0,1,1,0,0,0,0,0,0,0],
        // Row 4: Hat star area
        [0,0,0,0,0,1,1,0,1,0,1,1,0,0,0,0,0,0],
        // Row 5
        [0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0],
        // Row 6: Hat brim
        [0,0,0,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0],
        // Row 7: Face top — eyes
        [0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0],
        // Row 8: Eyes
        [0,0,0,0,1,0,1,1,1,0,1,1,0,0,0,0,0,0],
        // Row 9: Nose/mouth area
        [0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0],
        // Row 10: Beard top
        [0,0,0,0,0,1,1,0,0,1,1,0,0,0,0,0,0,0],
        // Row 11: Beard / robe top
        [0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0],
        // Row 12: Robe with arms
        [0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0],
        // Row 13: Robe + staff
        [0,0,1,0,1,1,1,1,1,1,1,1,0,1,0,0,0,0],
        // Row 14: Robe body
        [0,0,1,0,0,1,1,1,1,1,1,0,0,1,0,0,0,0],
        // Row 15: Robe lower
        [0,0,1,0,0,1,1,1,1,1,1,0,0,1,0,0,0,0],
        // Row 16: Robe bottom
        [0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0],
        // Row 17: Feet
        [0,0,0,1,1,1,0,0,0,0,1,1,1,0,0,0,0,0],
    ]

    /// Creates a menu bar icon (template image) from pixel art
    static func createMenuBarIcon() -> NSImage {
        let pixelSize: CGFloat = 1.0
        let width = 18
        let height = 18
        let imageSize = NSSize(width: CGFloat(width) * pixelSize, height: CGFloat(height) * pixelSize)

        let image = NSImage(size: imageSize, flipped: false) { rect in
            NSColor.black.setFill()

            for row in 0..<height {
                for col in 0..<width {
                    if pixelMap[row][col] == 1 {
                        let pixelRect = NSRect(
                            x: CGFloat(col) * pixelSize,
                            y: CGFloat(height - 1 - row) * pixelSize, // Flip Y for correct orientation
                            width: pixelSize,
                            height: pixelSize
                        )
                        pixelRect.fill()
                    }
                }
            }
            return true
        }

        image.isTemplate = true // Lets macOS handle light/dark mode
        return image
    }

    /// Creates a larger version of the icon for the app icon / about screen
    static func createLargeIcon(size: CGFloat = 128) -> NSImage {
        let width = 18
        let height = 18
        let pixelSize = size / CGFloat(max(width, height))
        let imageSize = NSSize(width: size, height: size)

        let image = NSImage(size: imageSize, flipped: false) { rect in
            // Dark background
            NSColor(red: 0.1, green: 0.08, blue: 0.15, alpha: 1.0).setFill()
            rect.fill()

            // Wizard in purple/blue tones
            let hatColor = NSColor(red: 0.45, green: 0.2, blue: 0.8, alpha: 1.0)
            let faceColor = NSColor(red: 0.9, green: 0.75, blue: 0.6, alpha: 1.0)
            let robeColor = NSColor(red: 0.3, green: 0.15, blue: 0.65, alpha: 1.0)
            let staffColor = NSColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0)

            for row in 0..<height {
                for col in 0..<width {
                    if pixelMap[row][col] == 1 {
                        // Choose color based on row region
                        if row <= 6 {
                            hatColor.setFill()
                        } else if row <= 10 {
                            faceColor.setFill()
                        } else if col == 2 || col == 13 {
                            staffColor.setFill()
                        } else {
                            robeColor.setFill()
                        }

                        let pixelRect = NSRect(
                            x: CGFloat(col) * pixelSize + (size - CGFloat(width) * pixelSize) / 2,
                            y: CGFloat(height - 1 - row) * pixelSize + (size - CGFloat(height) * pixelSize) / 2,
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
