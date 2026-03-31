// FrameSequence.swift
// Value type holding a decoded animation: array of CGImages + per-frame delays.
// Used by GIF, APNG, and PNG sequence decoders.
// Immutable after creation — safe to pass across threads.

import CoreGraphics
import Foundation

struct FrameSequence {
    /// Decoded frames. Each is a CGImage ready to set as CALayer.contents.
    let frames: [CGImage]

    /// Per-frame display duration in seconds.
    /// Count always equals frames.count.
    let delays: [TimeInterval]

    /// Total animation duration (sum of all delays).
    var totalDuration: TimeInterval {
        delays.reduce(0, +)
    }

    /// Number of frames.
    var count: Int { frames.count }

    /// Returns the frame index that should be displayed at a given playback time.
    /// `time` is the elapsed time modulo totalDuration.
    func frameIndex(at time: TimeInterval) -> Int {
        guard count > 1, totalDuration > 0 else { return 0 }

        let looped = time.truncatingRemainder(dividingBy: totalDuration)
        var accumulated: TimeInterval = 0
        for (i, delay) in delays.enumerated() {
            accumulated += delay
            if looped < accumulated { return i }
        }
        return count - 1
    }
}
