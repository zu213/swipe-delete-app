//
//  ContentView.swift
//  swipe-photo-delete
//
//  Created by Zachary Upstone on 29/03/2026.
//

import SwiftUI
import Photos

struct ContentView: View {
  @StateObject private var photoManager = PhotoManager()
  @State private var currentIndex = 0
  @State private var showingCompletionAlert = false
  @State private var photosDeleted = 0
  @State private var pendingDeletes: [PHAsset] = []
  @State private var showingGallery = false

  var body: some View {
    ZStack {
      Color.black.edgesIgnoringSafeArea(.all)

      VStack {
        // Header with progress
        HStack {
          VStack(alignment: .leading, spacing: 4) {
            Text("Photo Cleanup")
              .font(.title)
              .fontWeight(.bold)
              .foregroundColor(.white)

            if !photoManager.photos.isEmpty {
              Text("\(photoManager.photos.count - currentIndex) photos remaining")
                .font(.subheadline)
                .foregroundColor(.gray)
            }
          }

          Spacer()

          // Gallery button
          if !photoManager.photos.isEmpty && currentIndex < photoManager.photos.count {
            Button(action: {
              showingGallery = true
            }) {
              Image(systemName: "square.grid.3x3")
                .font(.system(size: 24))
                .foregroundColor(.white)
            }
            .padding(.trailing, 12)
          }

          // Trash button in top right
          if !pendingDeletes.isEmpty {
            Button(action: {
              processPendingDeletes()
            }) {
              ZStack {
                Circle()
                  .fill(Color.red)
                  .frame(width: 60, height: 60)

                VStack(spacing: 2) {
                  Image(systemName: "trash.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white)

                  Text("\(pendingDeletes.count)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                }
              }
            }
            .shadow(radius: 5)
          }
        }
        .padding()

        // Main content area
        if photoManager.authorizationStatus == .notDetermined {
          VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle.angled")
              .font(.system(size: 80))
              .foregroundColor(.white)

            Text("Access Your Photos")
              .font(.title)
              .fontWeight(.bold)
              .foregroundColor(.white)

            Text("This app needs FULL access to your photos to help you quickly review and delete unwanted images. Please select 'Allow Access to All Photos' when prompted.")
              .multilineTextAlignment(.center)
              .foregroundColor(.gray)
              .padding(.horizontal, 40)

            Button(action: {
              photoManager.requestAuthorization()
            }) {
              Text("Grant Access")
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
          }
        } else if photoManager.authorizationStatus == .denied || photoManager.authorizationStatus == .restricted {
          VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
              .font(.system(size: 80))
              .foregroundColor(.orange)

            Text("Access Denied")
              .font(.title)
              .fontWeight(.bold)
              .foregroundColor(.white)

            Text("Please enable photo access in Settings to use this app.")
              .multilineTextAlignment(.center)
              .foregroundColor(.gray)
              .padding(.horizontal, 40)

            Button(action: {
              if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
              }
            }) {
              Text("Open Settings")
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
          }
        } else if photoManager.photos.isEmpty {
          VStack(spacing: 20) {
            ProgressView()
              .scaleEffect(2)
              .tint(.white)

            Text("Loading photos...")
              .foregroundColor(.gray)
              .padding(.top, 20)
          }
        } else if currentIndex >= photoManager.photos.count {
          VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
              .font(.system(size: 80))
              .foregroundColor(.green)

            Text("All Done!")
              .font(.title)
              .fontWeight(.bold)
              .foregroundColor(.white)

            Text("You've reviewed all your photos.")
              .foregroundColor(.gray)

            if photosDeleted > 0 {
              Text("Deleted \(photosDeleted) photo\(photosDeleted == 1 ? "" : "s")")
                .foregroundColor(.red)
                .padding(.top, 10)
            }

            if !pendingDeletes.isEmpty {
              Text("\(pendingDeletes.count) pending deletion\(pendingDeletes.count == 1 ? "" : "s")")
                .foregroundColor(.orange)
                .font(.caption)
            }

            Button(action: {
              // Process any remaining pending deletes before restarting
              if !pendingDeletes.isEmpty {
                processPendingDeletes()
              }
              currentIndex = 0
              photosDeleted = 0
              photoManager.fetchPhotos()
            }) {
              Text("Start Over")
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
          }
        } else {
          SwipeablePhotoCard(
            asset: photoManager.photos[currentIndex],
            onSwipeLeft: {
              // Queue photo for deletion
              let assetToDelete = photoManager.photos[currentIndex]
              pendingDeletes.append(assetToDelete)

              moveToNextPhoto()
            },
            onSwipeRight: {
              // Keep photo - just move to next
              moveToNextPhoto()
            }
          )
          .id(photoManager.photos[currentIndex].localIdentifier)
        }

        Spacer()
      }
    }
    .alert("All Done!", isPresented: $showingCompletionAlert) {
      Button("OK", role: .cancel) { }
    } message: {
      Text("You've reviewed all your photos!")
    }
    .sheet(isPresented: $showingGallery) {
      PhotoGridView(
        photos: photoManager.photos,
        currentIndex: currentIndex,
        selectedIndex: $currentIndex
      )
    }
  }

  private func moveToNextPhoto() {
    withAnimation {
      currentIndex += 1
    }

    if currentIndex >= photoManager.photos.count {
      // Process any remaining pending deletes
      if !pendingDeletes.isEmpty {
        processPendingDeletes()
      }
      showingCompletionAlert = true
    }
  }

  private func processPendingDeletes() {
    let assetsToDelete = pendingDeletes

    // Count how many deleted photos are before the current index
    let deletedBeforeCurrent = assetsToDelete.filter { asset in
      if let index = photoManager.photos.firstIndex(of: asset) {
        return index < currentIndex
      }
      return false
    }.count

    pendingDeletes.removeAll()

    photoManager.batchDeletePhotos(assetsToDelete) { successCount in
      photosDeleted += successCount

      // Remove deleted photos from the photos array
      photoManager.photos.removeAll { asset in
        assetsToDelete.contains(asset)
      }

      // Adjust current index to account for deleted photos before current position
      currentIndex -= deletedBeforeCurrent
      if currentIndex < 0 {
        currentIndex = 0
      }
    }
  }
}

#Preview {
  ContentView()
}
