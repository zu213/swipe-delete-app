//
//  PhotoGridView.swift
//  swipe-photo-delete
//
//  Created by Zachary Upstone on 09/04/2026.
//

import SwiftUI
import Photos

struct PhotoGridView: View {
  let photos: [PHAsset]
  let currentIndex: Int
  @Binding var selectedIndex: Int
  @Environment(\.dismiss) var dismiss

  let columns = [
    GridItem(.adaptive(minimum: 100), spacing: 2)
  ]

  var body: some View {
    NavigationView {
      ScrollViewReader { proxy in
        ScrollView {
          LazyVGrid(columns: columns, spacing: 2) {
            ForEach(Array(photos.enumerated()), id: \.element.localIdentifier) { index, asset in
              ThumbnailView(asset: asset, isCurrentPhoto: index == currentIndex)
                .id(index)
                .onTapGesture {
                  selectedIndex = index
                  dismiss()
                }
            }
          }
        }
        .background(Color(red: 0.11, green: 0.11, blue: 0.12))
        .onAppear {
          proxy.scrollTo(currentIndex, anchor: .center)
        }
      }
      .navigationTitle("Jump to Photo")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Done") {
            dismiss()
          }
        }
      }
      .toolbarBackground(.visible, for: .navigationBar)
      .toolbarBackground(Color(red: 0.11, green: 0.11, blue: 0.12), for: .navigationBar)
      .toolbarColorScheme(.dark, for: .navigationBar)
    }
  }
}

struct ThumbnailView: View {
  let asset: PHAsset
  let isCurrentPhoto: Bool
  @State private var image: UIImage?

  var body: some View {
    ZStack {
      if let image = image {
        Image(uiImage: image)
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: 100, height: 100)
          .clipped()
      } else {
        Rectangle()
          .fill(Color.gray.opacity(0.3))
          .frame(width: 100, height: 100)
        ProgressView()
          .tint(.white)
      }

      if isCurrentPhoto {
        Rectangle()
          .stroke(Color.blue, lineWidth: 4)
          .frame(width: 100, height: 100)
      }
    }
    .onAppear {
      loadThumbnail()
    }
  }

  private func loadThumbnail() {
    let manager = PHImageManager.default()
    let options = PHImageRequestOptions()
    options.isSynchronous = false
    options.deliveryMode = .opportunistic

    let targetSize = CGSize(width: 200, height: 200)

    manager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { img, _ in
      if let img = img {
        DispatchQueue.main.async {
          self.image = img
        }
      }
    }
  }
}
