// PNGSequenceDecoder.swift
// Loads a folder of PNG files as an animation.
// Supports filenames like: frame_0001.png, frame_0002.png ...
// or any naming scheme that sorts correctly alphabetically.
// Default frame rate: 24fps. Can be overridden.

import ImageIO
import CoreGraphics
import Foundation

enum PNGSequenceDecoder {

    /// Load all PNG files from a directory, sorted by filename.
    /// - Parameters:
    ///   - directory: URL of the folder containing PNG frames.
    ///   - fps: Playback frame rate. Default 24fps.
    static func decode(directory: URL, fps: Double = 24.0) -> FrameSequence? {
        let fm = FileManager.default
        guard let contents = try? fm.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.nameKey],
            options: [.skipsHiddenFiles]
        ) else { return nil }

        // Filter to PNG files and sort by filename
        let pngURLs = contents
            .filter { $0.pathExtension.lowercased() == "png" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }

        guard !pngURLs.isEmpty else { return nil }

        var frames: [CGImage] = []
        let delay = 1.0 / max(fps, 1.0)

        for url in pngURLs {
            guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
                  let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
            else { continue }
            frames.append(image)
        }

        guard !frames.isEmpty else { return nil }

        let delays = Array(repeating: delay, count: frames.count)
        return FrameSequence(frames: frames, delays: delays)
    }
}
