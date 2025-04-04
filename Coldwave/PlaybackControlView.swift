/*
 Summary of Key Comments:

     Playback Control Buttons:
         Backward Button: Jumps to the previous track.
         Play/Pause Button: Switches between playing and paused states, showing the corresponding icon.
         Forward Button: Jumps to the next track.
 
     Playlist Menu:
        The Menu displays the current track name or "Album Tracks" if the playlist is empty. Users can select a track from the playlist to jump to.
 
     Slider:
        The Slider shows the playback position and allows the user to adjust it. It updates the position when dragged, and seeks to the selected position when the slider is released.
 
     mmss Function:
        A helper function that converts seconds into a formatted MM:SS string for easier display of track time.
 */

//
//  PlaybackControlView.swift
//  Coldwave
//
//  Created by Andrew Byrd on 3/10/2021.
//

import SwiftUI
import Foundation
import AVFoundation

// View for controlling playback, such as play, pause, skip, and track selection.
struct PlaybackControlView: View {
    
    @ObservedObject var state: ColdwaveState // Observed state for controlling playback and managing the current track.

    var body: some View {
        // Horizontal row of playback controls at the bottom of the window.
        // These controls could also be hidden in a menu, relying on hotkeys.
        // We use Image views with tap gesture listeners for simplicity and minimal chrome.
        HStack() {
            // Backward button to jump to the previous track.
            Button(action: { state.jumpToTrack(state.currentTrack - 1) }) {
                Image(systemName: "backward.end.fill") // Icon for the backward button.
            }

            // Play/Pause button: shows 'pause.fill' if playing, otherwise shows 'play.fill'.
            if state.playing {
                Button(action: { state.pause() }) {
                    Image(systemName: "pause.fill") // Pause icon when playing.
                }
            } else {
                Button(action: { state.play() }) {
                    Image(systemName: "play.fill") // Play icon when paused.
                }
            }

            // Forward button to jump to the next track.
            Button(action: { state.jumpToTrack(state.currentTrack + 1) }) {
                Image(systemName: "forward.end.fill") // Icon for the forward button.
            }
            
            // Playlist dropdown menu to select and jump to a specific track.
            let selectedItem = (state.playlist.isEmpty) ? "Album Tracks" : state.playlist[state.currentTrack].lastPathComponent
            Menu(selectedItem) {
                // Iterate over playlist items to display each track name in the menu.
                ForEach(state.playlist.indices, id: \.self) { trackIndex in
                    // Button to jump to the specific track when selected from the menu.
                    Button(state.playlist[trackIndex].lastPathComponent) {
                        state.jumpToTrack(trackIndex) // Jump to the selected track.
                    }.id(trackIndex)
                }
            }
        }
        .padding(PADDING) // Add padding around the controls for spacing.

        // Playback slider that shows and controls the current playback position.
        // It updates the position as the slider is dragged, with actions taken when the slider is released.
        Slider(value: $state.amountPlayed, in: 0...1) { editing in
            if (!editing) {
                // If editing has ended, seek to the new position in the track.
                if let d = state.player.currentItem?.duration {
                    let newPosition = (Double(d.value) * state.amountPlayed)
                    state.player.seek(to: CMTimeMake(value: Int64(newPosition), timescale: d.timescale)) // Seek to new position.
                }
            }
        }
        .padding(PADDING) // Add padding around the slider for spacing.

        // Text(String(state.amountPlayed)) // Optionally show the progress as text.
    }
    
    // Helper function to format seconds as MM:SS for display.
    private func mmss(seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds - minutes * 60
        return String(format: "%3i:%02i", minutes, seconds) // Format as MM:SS
    }
}
