/*
 Summary of Key Concepts:
     The Album class represents a single album folder.
     It automatically loads its cover image and parses its name from the directory structure (Artist/Album/).
     It provides static methods to scan an entire music folder structure and create Album objects.
     It includes a playlist generator (getPlaylist) that finds music files inside its folder.
     It conforms to Identifiable so SwiftUI can efficiently update views.
     It supports basic search matching against artist/title.
 
 If you want to modify or improve this, for example:
     Switching from String paths to URL (which is safer and more flexible).
     Making image loading lazy to improve performance.
     Adding metadata parsing (e.g., FLAC tags via AVFoundation or another library).
 */
import Foundation
import Quartz // Used here likely for NSImage support (via macOS QuartzCore frameworks)

// Represents a single album, which is basically a directory containing audio and image files.
class Album: Identifiable, Equatable {
    
    // Implements the Equatable protocol, using identity comparison (same object in memory)
    static func == (lhs: Album, rhs: Album) -> Bool {
        lhs === rhs
    }
    
    let albumPath: String         // Full path to the album's folder
    let artist: String            // Name of the artist (taken from folder structure)
    let title: String             // Album title (also from folder structure)
    var coverImagePath: String = "" // Path to the album cover image file, if found
    let cover: NSImage            // The cover image itself

    // Initialize an Album from a given folder path
    init (_ albumFullPath: String) {
        albumPath = albumFullPath
        let fileManager = FileManager.default
        let contents = try! fileManager.contentsOfDirectory(atPath: albumFullPath)

        // Look through all the files in the folder to find a suitable cover image
        for file in contents as [String] {
            var isDir: ObjCBool = false
            let lcFile = file.lowercased()
            let fullFilePath = NSString.path(withComponents: [albumFullPath, file])
            
            // If the file exists and is NOT a directory...
            if fileManager.fileExists(atPath: fullFilePath, isDirectory: &isDir) && !isDir.boolValue {
                // Look for files with common image extensions
                if lcFile.hasSuffix(".jpg") || lcFile.hasSuffix(".jpeg") || lcFile.hasSuffix(".png") {
                    self.coverImagePath = fullFilePath
                    // Prefer files that start with "cover" or "600x600"
                    if lcFile.hasPrefix("cover") || lcFile.hasPrefix("600x600") {
                        break
                    }
                }
            }
        }

        // Extract album title and artist name from the folder path structure
        var pathComponents = (albumFullPath as NSString).pathComponents
        title = pathComponents.removeLast()
        artist = pathComponents.removeLast()
        // Cache cover images so they're not reloaded on every SwiftUI update cycle.
        // We could defer this until the image is actually used/displayed with a lazy-initializing property.
        // We could also reuse the NSImages for the placeholder "missing cover" images.
        
        // Load the image itself
        if coverImagePath == "" {
            // Use a default placeholder image if no cover was found
            cover = NSImage(named: "record-sleeve-\(abs(title.hashValue % 2)).png")!
        } else {
            // Load the image from disk
            cover = NSImage(contentsOfFile: coverImagePath)!
        }
    }

    // Make the album uniquely identifiable using its folder path
    var id: String { albumPath }

    // MARK: - Static Methods

    // Scans a given artist folder and returns all album subdirectories as Album objects
    static func scanArtist (_ artistBasePath: String) -> [Album] {
        var albums: [Album] = []
        let fileManager = FileManager.default
        let contents = try! fileManager.contentsOfDirectory(atPath: artistBasePath)
        for file in contents as [String] {
            var isDir: ObjCBool = false
            let albumFullPath = NSString.path(withComponents: [artistBasePath, file])
            if fileManager.fileExists(atPath: albumFullPath, isDirectory: &isDir) && isDir.boolValue {
                albums.append(Album(albumFullPath))
            }
        }
        return albums
    }

    // Scans an entire music library folder and returns all albums (organized by artist folders)
    static func scanLibrary (at basePath: String) -> [Album] {
        var albums: [Album] = []
        let fileManager = FileManager.default
        let contents = try! fileManager.contentsOfDirectory(atPath: basePath)
        for file in contents as [String] {
            var isDir: ObjCBool = false
            let artistBasePath = NSString.path(withComponents: [basePath, file])
            if fileManager.fileExists(atPath: artistBasePath, isDirectory: &isDir) && isDir.boolValue {
                albums += scanArtist(artistBasePath)
            }
        }
        return albums
    }

    // Returns an array of file URLs to music files inside the album folder
    func getPlaylist () -> [URL] {
        let fileManager = FileManager.default
        let contents = try! fileManager.contentsOfDirectory(atPath: albumPath)
        var musicFileURLs: [URL] = []
        for file in contents as [String] {
            let lcFile = file.lowercased()
            let fullFilePath = NSString.path(withComponents: [albumPath, file])
            var isDir: ObjCBool = false
            if fileManager.fileExists(atPath: fullFilePath, isDirectory: &isDir) && !isDir.boolValue {
                // Add supported audio formats
                if lcFile.hasSuffix(".flac") || lcFile.hasSuffix(".mp3") || lcFile.hasSuffix(".m4a") {
                    musicFileURLs.append(URL(fileURLWithPath: fullFilePath))
                }
            }
        }
        return musicFileURLs
    }

    // Checks if the album's artist or title matches the user's search term
    func matchesSearchTerm (_ searchTerm: String) -> Bool {
        // Also returns true if search term is empty
        searchTerm.isEmpty || artist.localizedStandardContains(searchTerm) || title.localizedStandardContains(searchTerm)
    }

    // Potential future features hinted at:
    // class func findMusicFiles
    // class func findCoverImages
    // class func findMetadataInDir
}
