/*
 Summary of Key Comments:
     LazyVGrid Usage: The LazyVGrid is used for displaying album covers efficiently and is factored out into an Equatable struct to avoid unnecessary recomputation on every interaction.
     ScrollView: Used for scrolling through album covers, with ScrollViewReader allowing programmatic scrolling back to the selected album.
     Album Filtering: The album list is filtered by a search term.
     Selected Album: The selected album is highlighted with the accentColor.
     Double Tap Gesture: A double-tap gesture is set to jump to the first track of the selected album.
     Equatable Conformance: The struct conforms to Equatable to ensure it only re-renders when relevant properties change, like the path, coverSize, or currentAlbum.
 */
import SwiftUI
import Foundation

// LazyVGrid is too big to recompute at every interaction
// It has been factored out into an Equatable struct for more efficient updates.
struct AlbumCoverView : View, Equatable {

    // Properties to store path, cover size, current album, and search text
    let path: String
    let coverSize: CGFloat
    let currentAlbum: Album?
    let state: ColdwaveState // State object, may eventually be replaced with a separate ColdwavePlayer class for play methods.
    let searchText: String
    
    // Initializer that sets up state and relevant properties.
    init(state: ColdwaveState) {
        self.state = state
        path = state.path
        coverSize = state.coverSize
        currentAlbum = state.currentAlbum
        searchText = state.searchText
    }
    
    // Body of the view containing a scrollable grid of album covers
    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                // LazyVGrid efficiently lays out album covers with an adaptive grid based on the cover size.
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: coverSize))], // Columns adapt based on cover size
                    spacing: GRID_SPACING // Grid spacing constant
                ) {
                    // Iterate through the filtered albums based on the search term.
                    // ForEach with an initial capital F is a SwiftUI view, not the language construct.
                    // Identify albums by their filesystem path, which is hashable (String).
                    // Alternatively, we could make a struct for a single album cover conforming to Identifiable.
                    ForEach(state.albums.filter({ a in a.matchesSearchTerm(searchText) })) { album in
                        let selected = (state.currentAlbum === album) // Determine if the current album is selected.
                        
                        SingleAlbumView(album: album, size: coverSize) // Display the album cover.
                            // Set the background color of the selected album to accentColor, otherwise clear.
                            .background(selected ? Color.accentColor : Color.clear)
                            .onTapGesture(count: 2) {
                                // On double tap, jump to the first track of the selected album.
                                state.jumpToTrack(album: album, trackNumber: 0)
                            }
                    }
                }
                .padding(PADDING) // Add padding around the grid
                .onAppear {
                    // Scroll back to the selected album if it's available when the view appears.
                    // This still doesn't handle the case of losing one's position by resizing.
                    if let ca = currentAlbum {
                        scrollView.scrollTo(ca.albumPath) // Scroll to the album path if the album is selected.
                    }
                }
            }
        }
    }

    // Equatable conformance to ensure the view only re-renders if the path, cover size, search filter,
    // or selected album change.
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.path == rhs.path &&
            lhs.coverSize == rhs.coverSize &&
            lhs.currentAlbum === rhs.currentAlbum &&
            lhs.searchText == rhs.searchText
    }

}
