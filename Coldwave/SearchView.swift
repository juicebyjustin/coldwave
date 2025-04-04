/*
 Key Points Covered in Comments:
 
 Purpose of the View:
    This view provides a user interface for searching content. It includes a search input field, a magnifying glass icon, and a clear button for resetting the search text.
 
 State Binding:
    The TextField is bound to the state.searchText, meaning that whenever the user types into the search field, the searchText property in ColdwaveState will be updated.
 
 Clear Button:
 T  he "X" icon is conditionally shown based on whether the searchText is empty. When tapped, it clears the search field.
 
 Styling:
    The search view has padding, uses secondary colors for text and icons, and features rounded corners for a modern look.
 */
import Foundation
import SwiftUI

// SearchView is a SwiftUI view component that allows users to search through the application’s content.
// It includes a text field for input, an icon representing search functionality, and a clear button to reset the search.
struct SearchView: View {
    
    // Observes the `ColdwaveState` object to react to changes in the app state, such as the search text.
    @ObservedObject var state: ColdwaveState

    var body: some View {
        HStack {
            // Magnifying glass icon representing the search function.
            Image(systemName: "magnifyingglass")
            
            // A TextField for the user to enter their search query.
            // The text field is bound to `state.searchText`, which will update as the user types.
            TextField("Search", text: $state.searchText)
                .foregroundColor(.primary) // Set the text color to primary (default system color).
            
            // "X" button for clearing the search text.
            // It appears only when the search text is not empty.
            Image(systemName: "xmark.circle.fill")
                .opacity(state.searchText == "" ? 0 : 1) // Hides the button if the search text is empty.
                .onTapGesture { state.searchText = "" } // Clears the search text when tapped.
        }
        .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6)) // Adds padding around the search bar.
        .foregroundColor(.secondary) // Set the color of text and icons to a secondary system color.
        .cornerRadius(10.0) // Rounds the corners of the search bar to give it a smoother look.
    }

}
