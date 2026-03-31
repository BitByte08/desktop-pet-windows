// VideoPlayer.swift
// AVFoundation-based player for MP4, MOV, and other standard video formats.
// Uses AVPlayerLayer for hardware-accelerated decode on Apple Silicon.
//
// ⚠️  ALPHA TRANSPARENCY LIMITATION:
// Standard MP4 (H.264/H.265) does NOT support alpha channels.
// The video will render with a black or white background — it cannot float
// transparently over the desktop.
//
// For transparent video on macOS, use:
//   - ProRes 4444 (.mov) — supports alpha, hardware-decoded on Apple Silicon
//   - HEVC with Alpha (.mov, hvc1 + alpha) — macOS 13+, smaller file size
//
// evernight.mp4 is used here for general playback/import/loop testing only.
// It will NOT appear transparent.

import AVFoundation
import QuartzCore
import AppKit
import Foundation

final class VideoPlayer {

    // MARK: - Public
    let playerLayer: AVPlayerLayer

    var isPlaying: Bool {
        return player.rate != 0
    }

    var speed: Float = 1.0 {
        didSet {
            player.rate = isPlaying ? speed : 0
        }
    }

    // MARK: - Private
    private let player: AVPlayer
    private var loopObserver: NSObjectProtocol?

    // MARK: - Init

    init?(url: URL) {
        let asset = AVURLAsset(url: url, options: [
            AVURLAssetPreferPreciseDurationAndTimingKey: false
        ])
        let item = AVPlayerItem(asset: asset)

        // Buffer ahead 2 seconds — enough for smooth loop, not wasteful
        item.preferredForwardBufferDuration = 2.0

        let avPlayer = AVPlayer(playerItem: item)
        avPlayer.actionAtItemEnd = .none // We handle looping manually

        self.player = avPlayer
        self.playerLayer = AVPlayerLayer(player: avPlayer)
        self.playerLayer.videoGravity = .resizeAspect

        // Transparent background for the layer itself
        // (video content will still have its own background unless ProRes 4444)
        self.playerLayer.backgroundColor = CGColor.clear

        setupLooping()
    }

    // MARK: - Playback Control

    func play() {
        player.rate = speed
    }

    func pause() {
        player.pause()
    }

    func togglePlayPause() {
        isPlaying ? pause() : play()
    }

    // MARK: - Looping

    private func setupLooping() {
        loopObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { [weak self] _ in
            self?.player.seek(to: .zero)
            self?.player.rate = self?.speed ?? 1.0
        }
    }

    // MARK: - Deinit

    deinit {
        if let obs = loopObserver {
            NotificationCenter.default.removeObserver(obs)
        }
    }
}
