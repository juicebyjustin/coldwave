/*
 Key Points Covered in Comments:
 
 Purpose of the View:
    This view is responsible for displaying a single album, including the album cover, artist name, and title.
 
 Image Handling:
    The album cover is displayed with a specific size. The aspectRatio(1, contentMode: .fit) ensures that the image maintains its aspect ratio and fits within the specified frame. The image also has a black border and a shadow for styling.
 
 Text Display:
    The artist's name is displayed in bold, and the album title is italicized.
 
 Equatable Conformance:
    The == function allows instances of SingleAlbumView to be compared. It checks if the album reference and size are the same between two views.
 */
import Foundation
import SwiftUI

// SingleAlbumView displays the album cover, artist name, and album title.
// It is used to represent a single album in the album grid view.
struct SingleAlbumView : View, Equatable {
   
    // The album being displayed, and the size of the album cover.
    let album: Album
    let size: CGFloat

    var body: some View {
        VStack {
            // Display the album cover as an image.
            // The image is resized to the provided size and aspect ratio is maintained.
            // It is displayed as a square frame with a black border and a shadow.
            Image(nsImage: album.cover)
                .resizable() // Make the image resizable.
                .frame(width: size, height: size, alignment: .center) // Set the frame size.
                .aspectRatio(1, contentMode: .fit) // Maintain the aspect ratio of the image.
                .border(Color.black, width: 1) // Add a black border around the image.
                .shadow(radius: 5) // Apply a shadow effect to the image.
            
            // Display the artist's name and album title.
            // The artist name is bold, and the album title is italicized.
            Text(album.artist).bold()
            Text(album.title).italic()
        }
    }

    // Equatable conformance to check if two SingleAlbumView instances are equal.
    // This is based on the album object and the size.
    static func == (lhs: SingleAlbumView, rhs: SingleAlbumView) -> Bool {
        lhs.album === rhs.album && lhs.size == rhs.size
    }

}
