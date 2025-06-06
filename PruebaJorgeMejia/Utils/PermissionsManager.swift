//
//  PermissionsManager.swift
//  PruebaJorgeMejia
//
//  Created by Jorge Mulhia on 6/5/25.
//

import Foundation
import SwiftUI
import AVFoundation

// MARK: - Protocolo para los permisos (Cámara y Ubicación)
protocol PermissionManager {
    var hasPermission: Bool { get }
    func getPermission() async
    func gotoAppPrivacySettings()
}
extension PermissionManager {
    
    // Ir a los settings para habilitar/deshabilitar los permisos de la cámara y ubicación
    func gotoAppPrivacySettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(url) else {
                assertionFailure("Not able to open privacy settings")
                return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

// MARK: - Manager para la cámara
// @MainActor porque necesita ejecutarse en el hilo principal
// @preconcurrency es para conformar el protocolo con el modificador @MainActor
@MainActor
final class CameraPermissionViewModel: ObservableObject, @preconcurrency PermissionManager {

    @Published var hasPermission: Bool = false

    // Verifica los permisos de la cámara
    func getPermission() async {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            hasPermission = true
        case .notDetermined:
            let isPermissionGranted = await AVCaptureDevice.requestAccess(for: .video)
            if isPermissionGranted {
                hasPermission = true
            } else {
                fallthrough
            }
        case .denied:
            fallthrough
        case .restricted:
            fallthrough
        @unknown default:
            hasPermission = false
        }
    }
}
