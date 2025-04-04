/*
 What's happening overall:
 This is your app's main view.
 It takes a ColdwaveState object (likely a @Published model class) and passes it to three subviews: SearchView, AlbumCoverView, and PlaybackControlView.
 It switches between showing a currently-playing album cover or a grid/list of albums depending on whether something is playing.
 Constants for image sizing and layout are declared globally for easy tweaking.
 */

import SwiftUI
import AVFoundation // Likely used elsewhere in the app to handle audio playback

// Constants used for sizing UI elements
let MIN_IMAGE_SIZE: CGFloat = 100
let MAX_IMAGE_SIZE: CGFloat = 800
let IMAGE_SIZE_STEP: CGFloat = 50
let DEFAULT_IMAGE_SIZE: CGFloat = 400
let GRID_SPACING: CGFloat = 20
let PADDING: CGFloat = 10

// Main content view of the app
struct ContentView: View {
    
    // The app’s shared state object, passed down to child views
    @ObservedObject var state: ColdwaveState
    
    var body: some View {
        VStack {
            // Top section: search bar for artist and album title
            SearchView(state: state)
            
            // Middle section: if music is playing, show the album art
            if (state.playing) {
                Image(nsImage: state.currentAlbum!.cover) // Show album cover image
                    .resizable()                         // Allow it to scale
                    .border(Color.black)                 // Add a border around the image
                    .aspectRatio(contentMode: .fit)      // Preserve aspect ratio when resizing
                    .padding(PADDING)                    // Add some padding around the image
            } else {
                // If nothing is playing, show a grid or scrollable list of album covers
                AlbumCoverView(state: state)
            }
            
            // Bottom section: playback controls and track selection
            PlaybackControlView(state: state)
        }
    }
    
}

// Preview provider for Xcode's canvas preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(state: ColdwaveState())
        }
    }
}
