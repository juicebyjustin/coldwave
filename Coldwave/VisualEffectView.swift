/*
 Key Points Covered in Comments:
 
     Purpose of the Custom View:
        This custom SwiftUI view (VisualEffectView) applies visual effects (like blur) using NSVisualEffectView from AppKit, making it useful for creating macOS-style visual effects in SwiftUI views, such as blur effects over other content.
 
     Properties:
         material: Defines the visual effect's material, such as light, dark, or popover.
         blendingMode: Defines how the visual effect blends with its background content.
 
     Functions:
         makeNSView: Creates and returns the NSVisualEffectView and sets its initial material, blending mode, and state.
         updateNSView: Updates the effect's properties when the view's state changes in SwiftUI.
 
     UIKit Alternative (Commented Out):
        There is an alternative version for iOS using UIViewRepresentable (commented out). It provides similar functionality with UIVisualEffectView for iOS platforms.
 */
//
//  VisualEffectView.swift
//  Coldwave
//
//  Created by Andrew Byrd on 4/10/2021.
//

import Foundation
import SwiftUI

// Custom view for adding a visual effect (blur effect) to the UI, typically used in ZStacks.
// This is an implementation using AppKit's NSVisualEffectView to create macOS-style visual effects.
// In newer versions of SwiftUI, this effect might be available natively, but this custom implementation provides flexibility.
struct VisualEffectView: NSViewRepresentable {
    
    // Define the material (e.g., light, dark, or popover) to apply to the effect.
    let material: NSVisualEffectView.Material
    
    // Define the blending mode of the effect. This affects how the visual effect interacts with the surrounding content.
    let blendingMode: NSVisualEffectView.BlendingMode
    
    // Creates the NSVisualEffectView that will be used in the SwiftUI view hierarchy.
    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView() // Create a new NSVisualEffectView instance.
        visualEffectView.material = material // Set the material for the effect (e.g., popover, light, dark).
        visualEffectView.blendingMode = blendingMode // Set the blending mode to control the visual interaction.
        visualEffectView.state = NSVisualEffectView.State.active // Ensure the effect is active (enabled).
        return visualEffectView // Return the configured view.
    }

    // Updates the NSVisualEffectView when the SwiftUI state changes.
    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        // Update the material and blending mode of the effect based on any changes.
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}

// An alternative commented-out implementation for UIKit (for iOS) using UIViewRepresentable.
// struct VisualEffectView: UIViewRepresentable {
//     var effect: UIVisualEffect? // Effect to be applied (e.g., UIBlurEffect).
//     func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
//     func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
// }
