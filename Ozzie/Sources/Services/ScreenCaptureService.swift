import AppKit
import Vision

class ScreenCaptureService {
    static let shared = ScreenCaptureService()

    private init() {}

    /// Captures a user-selected screen region and returns (imageData, ocrText)
    func captureSelection(completion: @escaping (Data?, String?) -> Void) {
        let tempPath = NSTemporaryDirectory() + "ozzie_capture_\(UUID().uuidString).png"

        // Use macOS screencapture tool with -i for interactive selection
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        process.arguments = ["-i", "-x", tempPath] // -i interactive, -x no sound

        process.terminationHandler = { _ in
            DispatchQueue.main.async {
                let fileManager = FileManager.default
                guard fileManager.fileExists(atPath: tempPath),
                      let imageData = try? Data(contentsOf: URL(fileURLWithPath: tempPath)) else {
                    // User cancelled the selection
                    completion(nil, nil)
                    return
                }

                // Clean up temp file
                try? fileManager.removeItem(atPath: tempPath)

                // Run OCR on the image
                self.performOCR(on: imageData) { text in
                    completion(imageData, text)
                }
            }
        }

        do {
            try process.run()
        } catch {
            print("Ozzie: Failed to launch screencapture: \(error)")
            completion(nil, nil)
        }
    }

    /// Performs OCR on image data using Vision framework
    private func performOCR(on imageData: Data, completion: @escaping (String?) -> Void) {
        guard let image = NSImage(data: imageData),
              let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            completion(nil)
            return
        }

        let request = VNRecognizeTextRequest { request, error in
            guard error == nil,
                  let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(nil)
                return
            }

            let recognizedText = observations
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: "\n")

            completion(recognizedText.isEmpty ? nil : recognizedText)
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("Ozzie: OCR failed: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}
