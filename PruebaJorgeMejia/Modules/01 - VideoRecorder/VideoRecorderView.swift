//
//  VideoRecorderView.swift
//  PruebaJorgeMejia
//
//  Created by Jorge Mulhia on 6/5/25.
//

import Foundation
import SwiftUI

struct VideoRecorderView: View {
    
    // MARK: - Variables
    
    // manager para los permisos de la cámara
    @StateObject private var cameraPermission = CameraPermissionViewModel()
    @State private var showCamera = false
    @State private var recordedVideoURL: URL?
    @State private var showVideo = false
    
    // MARK: - View
    
    var body: some View {
        ZStack {
            Color.background
            
            VStack {
                if cameraPermission.hasPermission {
                    recordVideoView()
                } else {
                    noPermissionsView()
                }
            }
            .padding(40)
        }
        .ignoresSafeArea()
        .navigationTitle("Grabar video")
        .task {
            // verificar los permisos de la càmara en caso de que el usuario quite los perimisos
            await cameraPermission.getPermission()
        }
        .sheet(isPresented: $showCamera) {
            VideoRecorder { url in
                recordedVideoURL = url
                print(url)
            }
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showVideo) {
            if let recordedVideoURL {
                VideoPlayerView(videoURL: recordedVideoURL)
                    .ignoresSafeArea()
            }
        }
    }
    
    // MARK: - Métodos privados
    
    // vista para grabar video
    private func recordVideoView() -> some View {
        VStack(spacing: 40) {
            VideoRecorderGenericView(
                icon: "camera",
                text: "Captura un breve video con audio en donde digas tu nombre.",
                buttonAction: { showCamera.toggle() },
                buttonText: recordedVideoURL == nil ? "Grabar video" : "Volver a grabar"
            )
            
            if recordedVideoURL != nil {
                Button {
                    showVideo.toggle()
                } label: {
                    Text("Reproducir video")
                        .font(.custom("FiraSans-Regular", size: 20))
                        .foregroundColor(Color.secondary)
                }
            }
        }
        .padding()
    }
    
    // vista cuando no hay permisos de cámara
    private func noPermissionsView() -> some View {
        VStack(spacing: 40) {
            VideoRecorderGenericView(
                icon: "arrow.triangle.2.circlepath.camera",
                text: "No puedes grabar videos\n Por favor habilita los permisos de la cámara.",
                buttonAction: { cameraPermission.gotoAppPrivacySettings() },
                buttonText: "Ir a Configuración"
            )
            .padding()
        }
    }
    
    // vista generica para el mensaje
    struct VideoRecorderGenericView: View {
        var icon: String
        var text: String
        var buttonAction: (() -> Void)
        var buttonText: String
        
        var body: some View {
            VStack(spacing: 40) {
                Image(systemName: icon)
                    .font(.system(size: 70))
                    .foregroundColor(.primary)
                    .opacity(0.4)
                
                Text(text)
                    .multilineTextAlignment(.center)
                    .font(.custom("FiraSans-Light", size: 20))
                    .foregroundColor(Color.primary)
                
                Button {
                    buttonAction()
                } label: {
                    Text(buttonText)
                }
                .padding(20)
                .font(.custom("FiraSans-Regular", size: 18))
                .foregroundColor(Color.primary)
                .background(Color.buttonBackground)
                .clipShape(Capsule())
            }
        }
    }
}

// MARK: - Preview

struct VideoRecorderView_Previews: PreviewProvider {
    static var previews: some View {
        VideoRecorderView()
    }
}
