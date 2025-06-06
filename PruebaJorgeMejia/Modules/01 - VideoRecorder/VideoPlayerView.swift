//
//  VideoPlayerView.swift
//  PruebaJorgeMejia
//
//  Created by Jorge Mulhia on 6/5/25.
//

import UIKit
import SwiftUI
import AVKit

struct VideoPlayerView: View {
    
    // MARK: - Variables
    
    let videoURL: URL
    @State private var player: AVPlayer
    @State private var isPlaying = false
    @Environment(\.dismiss) private var dismiss
    
    init(videoURL: URL) {
        self.videoURL = videoURL
        _player = State(initialValue: AVPlayer(url: videoURL))
    }
    
    // MARK: - View

    var body: some View {
        ZStack {
            Color.background

            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 25))
                            .foregroundColor(.primary)
                    }
                }
                
                VideoPlayer(player: player)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.vertical, 20)
                
                Button {
                    if isPlaying {
                        player.pause()
                    } else {
                        player.play()
                    }
                    isPlaying.toggle()
                } label: {
                    Image(systemName: isPlaying ? "pause" : "play")
                        .font(.system(size: 40))
                        .foregroundColor(.primary)
                }
                .padding(.bottom, 20)
            }
            .padding(25)
        }
        .onDisappear {
            player.pause()
        }
        .ignoresSafeArea()
    }
}

// MARK: - Preview

struct VideoPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayerView(videoURL: URL(fileURLWithPath: ""))
    }
}
