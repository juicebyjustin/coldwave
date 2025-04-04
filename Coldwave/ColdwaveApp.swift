/*
 ✅ Key Features Covered:
     Custom keyboard shortcuts (⌘O, +, -)
     Native macOS file open panel integration
     Manual folder selection and immediate library scanning
     SwiftUI @StateObject to share state across the app
     Modular, extensible menu system using .commands
 */
import SwiftUI

// Entry point for the Coldwave app.
@main
struct ColdwaveApp: App {
    
    // Shared application state object, observed throughout the app.
    @StateObject var state: ColdwaveState = ColdwaveState()
    
    var body: some Scene {
        // Main application window
        WindowGroup {
            // Provide the state to the root ContentView
            ContentView(state: state)
        }
        .commands {
            // Add custom command before the "New" item in the menu
            CommandGroup(before: CommandGroupPlacement.newItem) {
                Button(
                    action: { openFolder() },
                    label: { Label("Open directory...", systemImage: "doc") }
                )
                .keyboardShortcut("o") // Cmd+O to open folder
            }

            // Custom "Utilities" menu with zoom controls
            CommandMenu("Utilities") {
                Button("Bigger") {
                    // Increase album cover size if not at max
                    if (state.coverSize < MAX_IMAGE_SIZE) {
                        state.coverSize += IMAGE_SIZE_STEP
                    }
                }
                .keyboardShortcut("+") // Cmd++

                Button("Smaller") {
                    // Decrease album cover size if not at min
                    if (state.coverSize > MIN_IMAGE_SIZE) {
                        state.coverSize -= IMAGE_SIZE_STEP
                    }
                }
                .keyboardShortcut("-") // Cmd+-
            }
        }
    }
    
    // Opens a folder picker dialog to select the music root directory
    private func openFolder () {
        let dialog = NSOpenPanel()
        dialog.title = "Choose root music directory | ABCD"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = true
        dialog.canChooseFiles = false

        // If the user clicks "Open"
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url
            if (result != nil) {
                // Update state with selected path
                state.path = result!.path

                // Immediately scan for albums in the selected directory
                // TODO: Consider moving this into a didSet on `state.path` for cleaner reactivity
                state.albums = Album.scanLibrary(at: state.path)
            }
        }
    }

}
