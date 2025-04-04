/*
 ✨ Optional Enhancements You Might Consider:
     Move the AVPlayer handling into its own class (PlayerManager or similar), and expose playback state via bindings or @Published properties.
     Add playNext(), playPrevious(), or shuffle/repeat logic if you plan to grow this app.
     Implement persistence for user settings like coverSize or last played album/track.
 */

import Foundation
import AVFoundation

// The main state object for the Coldwave app.
// This holds and manages the app's playback state, album list, and user interactions.
class ColdwaveState: ObservableObject {
    
    // MARK: - Published Properties (bound to UI)

    @Published var albums: [Album] = []          // All scanned albums in the selected directory
    @Published var path: String = ""             // Root path of the scanned music directory
    @Published var currentAlbum: Album?          // Currently selected album
    @Published var currentTrack = 0              // Index of the currently playing track
    @Published var coverSize: CGFloat = DEFAULT_IMAGE_SIZE // Size of album artwork in the UI
    @Published var playlist: [URL]  = []         // URLs of the tracks to play (current album)
    @Published var amountPlayed: Double = 0.0    // Track progress (0.0 to 1.0)
    @Published var playing: Bool = false         // Whether the player is currently playing
    @Published var searchText: String = ""       // User's current search input for filtering albums

    // AVPlayer handles audio playback
    let player: AVPlayer = AVPlayer()

    // MARK: - Initializer

    init() {
        // Add a periodic observer to update the progress slider in the UI
        player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
            queue: .main
        ) { t in
            // Safely get the current item's duration in the same timescale as the current time
            if let duration = self.player.currentItem?.duration.convertScale(t.timescale, method: CMTimeRoundingMethod.default) {
                // Calculate progress as a fraction (0.0 to 1.0)
                self.amountPlayed = Double(t.value) / Double(duration.value)
            }
        }
    }

    // MARK: - Track Playback & Navigation

    // Called when the current track finishes playing
    // Automatically advances to the next track
    @objc func playerDidFinishPlaying(sender: Notification) {
        print("End of track \(currentTrack), advancing.")
        jumpToTrack(currentTrack + 1)
    }

    // Start playback at a specific track within a specific album
    func jumpToTrack(album: Album, trackNumber: Int) {
        currentAlbum = album                  // Set the new current album
        playlist = album.getPlaylist()        // Get the album's playlist
        jumpToTrack(trackNumber)              // Start playing the desired track
    }

    // Core method to jump to a track by index and start playback
    func jumpToTrack(_ trackNumber: Int) {
        if (trackNumber >= 0 && trackNumber < playlist.count) {
            let track = AVPlayerItem(asset: AVAsset(url: playlist[trackNumber]))

            player.replaceCurrentItem(with: track) // Replace with the selected track
            currentTrack = trackNumber
            player.play()                          // Start playback
            playing = true

            // Clean up any previous observer to avoid memory leaks or double triggers
            NotificationCenter.default.removeObserver(self)
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(playerDidFinishPlaying(sender:)),
                name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                object: track
            )
        } else {
            // Out-of-bounds track index: stop playback
            player.pause()
            playing = false
        }
    }

    // Pause the current playback
    func pause() {
        player.pause()
        playing = false
    }

    // Resume playback if a track is loaded
    func play() {
        if (player.currentItem != nil) {
            player.play()
            playing = true
        }
    }

}
