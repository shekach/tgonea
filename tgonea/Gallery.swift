//
//  News.swift
//  tgonea
//
//  Created by Soma Shekar on 30/12/25.
//

import SwiftUI
import FirebaseFirestore

struct Gallery: View {
    @StateObject private var vm = GalleryViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if let error = vm.errorMessage {
                    Text("Error: \(error)")
                        .foregroundStyle(.red)
                } else if vm.items.isEmpty {
                    ProgressView("Loading images…")
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(vm.items) { item in
                                VStack(alignment: .leading, spacing: 8) {
                                    AsyncImage(url: item.imageURL) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFit()
                                        case .failure:
                                            Color.gray
                                                .aspectRatio(1, contentMode: .fit)
                                                .overlay(Text("Failed to load"))
                                        default:
                                            ProgressView()
                                        }
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 300)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    
                                    Text(item.description)
                                        .font(.body)
                                        .padding(.bottom, 8)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Gallery")
            .task {
                await vm.fetchGalleryItems()
            }
        }
    }
}

#Preview {
    Gallery()
}
