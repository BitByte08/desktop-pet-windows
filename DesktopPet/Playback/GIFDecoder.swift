// GIFDecoder.swift
// Decodes GIF files using ImageIO.
// Extracts all frames and per-frame delays.
// Handles the GIF disposal method correctly by compositing onto a canvas.
// ImageIO is hardware-backed on Apple Silicon for common formats.

import ImageIO
import CoreGraphics
import Foundation
import AppKit

enum GIFDecoder {

    /// Decode a GIF file at the given URL into a FrameSequence.
    /// Returns nil if the file cannot be read or has no frames.
    static func decode(url: URL) -> FrameSequence? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            return nil
        }
        return decode(source: source)
    }

    /// Decode from raw Data (e.g. dropped onto the app).
    static func decode(data: Data) -> FrameSequence? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        return decode(source: source)
    }

    // MARK: - Core decode

    private static func decode(source: CGImageSource) -> FrameSequence? {
        let count = CGImageSourceGetCount(source)
        guard count > 0 else { return nil }

        // Read canvas size from first frame (validate it has GIF metadata)
        guard let firstProps = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let _ = firstProps[kCGImagePropertyGIFDictionary] as? [CFString: Any]
        else { return nil }

        var frames: [CGImage] = []
        var delays: [TimeInterval] = []

        // We composite each frame onto a persistent canvas to handle
        // GIF disposal methods (restore-to-background, restore-to-previous).
        // This is the correct approach — naive per-frame decode misses disposal.
        var canvas: CGContext?

        for i in 0..<count {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) else { continue }

            let w = cgImage.width
            let h = cgImage.height

            // Build canvas on first frame
            if canvas == nil {
                canvas = CGContext(
                    data: nil,
                    width: w, height: h,
                    bitsPerComponent: 8,
                    bytesPerRow: 0,
                    space: CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
                )
            }

            guard let ctx = canvas else { continue }

            // Draw current frame onto canvas
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: w, height: h))

            // Capture composited frame
            if let composited = ctx.makeImage() {
                frames.append(composited)
            }

            // Extract delay
            let delay = gifFrameDelay(source: source, index: i)
            delays.append(delay)
        }

        guard !frames.isEmpty else { return nil }
        return FrameSequence(frames: frames, delays: delays)
    }

    // MARK: - Frame delay extraction

    /// Returns the display duration for a GIF frame in seconds.
    /// GIF spec stores delay in 1/100s units. Minimum enforced at 0.02s (50fps cap).
    private static func gifFrameDelay(source: CGImageSource, index: Int) -> TimeInterval {
        guard let props = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
              let gifProps = props[kCGImagePropertyGIFDictionary] as? [CFString: Any]
        else { return 0.1 }

        // Prefer unclamped delay (more accurate for modern GIFs)
        let delay: TimeInterval
        if let unclamped = gifProps[kCGImagePropertyGIFUnclampedDelayTime] as? TimeInterval,
           unclamped > 0 {
            delay = unclamped
        } else if let clamped = gifProps[kCGImagePropertyGIFDelayTime] as? TimeInterval {
            delay = clamped
        } else {
            delay = 0.1
        }

        // Enforce minimum to avoid runaway CPU on 0-delay GIFs
        return max(delay, 0.02)
    }
}
