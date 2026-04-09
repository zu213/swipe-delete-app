//
//  SwipeablePhotoCard.swift
//  swipe-photo-delete
//
//  Created by Zachary Upstone on 29/03/2026.
//

import SwiftUI
import Photos

struct SwipeablePhotoCard: View {
  let asset: PHAsset
  let onSwipeLeft: () -> Void
  let onSwipeRight: () -> Void

  @State private var image: UIImage?
  @State private var offset: CGSize = .zero
  @State private var isDragging = false

  private let swipeThreshold: CGFloat = 100

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        if let image = image {
          Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.8)
            .cornerRadius(20)
            .shadow(radius: 10)
            .offset(offset)
            .rotationEffect(.degrees(Double(offset.width / 20)))
            .gesture(
              DragGesture()
                .onChanged { gesture in
                  isDragging = true
                  offset = gesture.translation
                }
                .onEnded { gesture in
                  isDragging = false
                  let horizontalSwipe = gesture.translation.width

                  if horizontalSwipe < -swipeThreshold {
                    // Swipe left - Delete
                    withAnimation(.spring()) {
                      offset = CGSize(width: -1000, height: 0)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                      onSwipeLeft()
                      offset = .zero
                    }
                  } else if horizontalSwipe > swipeThreshold {
                    // Swipe right - Keep
                    withAnimation(.spring()) {
                      offset = CGSize(width: 1000, height: 0)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                      onSwipeRight()
                      offset = .zero
                    }
                  } else {
                    // Return to center
                    withAnimation(.spring()) {
                      offset = .zero
                    }
                  }
                }
            )
            .overlay(
              Group {
                if isDragging {
                  if offset.width < -50 {
                    Text("DELETE")
                      .font(Font.system(size: 48, weight: .bold))
                      .foregroundColor(.red)
                  } else if offset.width > 50 {
                    Text("KEEP")
                      .font(Font.system(size: 48, weight: .bold))
                      .foregroundColor(.green)
                  }
                }
              }
            )
        } else {
          ProgressView()
            .scaleEffect(2)
        }

        // Swipe indicators at bottom
        VStack {
          Spacer()

          HStack(spacing: 60) {
            VStack {
              Image(systemName: "arrow.left.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.red)
              Text("Delete")
                .font(.caption)
                .foregroundColor(.red)
            }

            VStack {
              Image(systemName: "arrow.right.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.green)
              Text("Keep")
                .font(.caption)
                .foregroundColor(.green)
            }
          }
          .padding(.bottom, 50)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .onAppear {
      loadImage()
    }
    .onChange(of: asset.localIdentifier) { _ in
      image = nil
      offset = .zero
      loadImage()
    }
  }

  private func loadImage() {
    let manager = PHImageManager.default()
    let options = PHImageRequestOptions()
    options.isSynchronous = false
    options.deliveryMode = .highQualityFormat

    let targetSize = CGSize(width: UIScreen.main.bounds.width * 2, height: UIScreen.main.bounds.height * 2)

    manager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { img, _ in
      if let img = img {
        DispatchQueue.main.async {
          self.image = img
        }
      }
    }
  }
}
