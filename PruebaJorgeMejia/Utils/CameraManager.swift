//
//  CameraManager.swift
//  PruebaJorgeMejia
//
//  Created by Jorge Mulhia on 6/5/25.
//

import Foundation
import SwiftUI

// MARK: - UIViewControllerRepresentable para grabar el video
struct VideoRecorder: UIViewControllerRepresentable {
    
    // MARK: - Variables
    
    @Environment(\.presentationMode) var presentationMode
    var onVideoRecorded: (URL) -> Void
    
    // MARK: - Coordinator

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        
        // check para validar si es simulador y evitar que truene la app
#if targetEnvironment(simulator)
        print("En simulador no es posible grabar video :(")
#else
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.mediaTypes = ["public.movie"]
        picker.cameraCaptureMode = .video
        picker.cameraDevice = .front
#endif
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: VideoRecorder

        init(_ parent: VideoRecorder) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let videoURL = info[.mediaURL] as? URL {
                
                // tratar de guardar el video en la carpeta de documentos
                let fileManager = FileManager.default
                let url = fileManager.temporaryDirectory.appendingPathComponent("recordedVideo.mov")
                
                // sobreescribe el archivo si existe uno anterior
                try? fileManager.removeItem(at: url)
                do {
                    try fileManager.copyItem(at: videoURL, to: url)
                    parent.onVideoRecorded(url)
                } catch {
                    print("Error saving video: \(error)")
                }
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
