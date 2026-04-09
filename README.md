# Swipe Photo Delete

A SwiftUI iOS app for quickly reviewing and deleting photos from your photo library using intuitive swipe gestures.

## Features

- **Swipe Left**: Mark photo for deletion
- **Swipe Right**: Keep photo
- **Batch Deletion**: Photos are deleted in batches of 10 for better performance
- **Progress Tracking**: See how many photos remain and how many you've deleted
- **Dark UI**: Clean, distraction-free interface with a dark theme
- **Full Photo Access**: Requires full photo library access to manage your images

## Requirements

- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

1. Clone the repository
2. Open `swipe-photo-delete.xcodeproj` in Xcode
3. Build and run on your iOS device or simulator

## Usage

1. Launch the app
2. Grant full photo library access when prompted
3. Swipe left to delete unwanted photos
4. Swipe right to keep photos
5. Photos are batched and deleted every 10 swipes for efficiency

## Project Structure

```
swipe-photo-delete/
├── swipe_photo_deleteApp.swift    # App entry point
├── ContentView.swift              # Main view with photo management logic
├── SwipeablePhotoCard.swift       # Photo card with swipe gesture handling
├── PhotoManager.swift             # Photo library management and authorization
└── Item.swift                     # SwiftData model (legacy/template)
```

## Code Style

This project uses 2-space indentation for all Swift files.

## License

This project is open source and available for personal use.
