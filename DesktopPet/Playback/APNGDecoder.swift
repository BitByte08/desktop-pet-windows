// APNGDecoder.swift
// Decodes APNG files using ImageIO.
// macOS 14+ has native APNG support in ImageIO — no third-party library needed.
// Falls back to a single static frame if the PNG is not animated.

import ImageIO
import CoreGraphics
import Foundation

enum APNGDecoder {

    static func decode(url: URL) -> FrameSequence? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        return decode(source: source)
    }

    static func decode(data: Data) -> FrameSequence? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        return decode(source: source)
    }

    // MARK: - Core decode

    private static func decode(source: CGImageSource) -> FrameSequence? {
        let count = CGImageSourceGetCount(source)
        guard count > 0 else { return nil }

        var frames: [CGImage] = []
        var delays: [TimeInterval] = []

        for i in 0..<count {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) else { continue }
            frames.append(cgImage)

            let delay = apngFrameDelay(source: source, index: i)
            delays.append(delay)
        }

        guard !frames.isEmpty else { return nil }

        // Single-frame PNG — treat as static with a long delay
        if frames.count == 1 {
            return FrameSequence(frames: frames, delays: [1.0])
        }

        return FrameSequence(frames: frames, delays: delays)
    }

    // MARK: - Frame delay extraction

    private static func apngFrameDelay(source: CGImageSource, index: Int) -> TimeInterval {
        guard let props = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
              let pngProps = props[kCGImagePropertyPNGDictionary] as? [CFString: Any]
        else { return 1.0 / 24.0 }

        // Prefer unclamped delay time (same pattern as GIF decoder).
        // kCGImagePropertyAPNGUnclampedDelayTime / kCGImagePropertyAPNGDelayTime
        // are available since macOS 10.10 and present in all relevant SDKs.
        let delay = (pngProps[kCGImagePropertyAPNGUnclampedDelayTime] as? TimeInterval)
            ?? (pngProps[kCGImagePropertyAPNGDelayTime] as? TimeInterval)
            ?? (1.0 / 24.0)
        return max(delay, 0.02)
    }
}
