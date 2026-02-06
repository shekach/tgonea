//
//  News.swift
//  tgonea
//
//  Created by Soma Shekar on 30/12/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct Gallery: View {
    @StateObject private var vm = GalleryViewModel()
    @State private var expandedItem: GalleryItem? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color(.systemGroupedBackground), Color(.secondarySystemGroupedBackground)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                Group {
                    if let error = vm.errorMessage {
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.largeTitle)
                                .foregroundStyle(.yellow)
                            Text("Error: \(error)")
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.red)
                            Button("Retry") {
                                Task { await vm.fetchGalleryItems() }
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding()
                    } else if vm.items.isEmpty {
                        VStack(spacing: 12) {
                            ProgressView()
                            Text("Loading images…")
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(vm.items) { item in
                                    Button {
                                        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                                            expandedItem = item
                                        }
                                    } label: {
                                        galleryCard(for: item)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                        }
                    }
                }
            }
            .navigationTitle("Gallery")
            .task {
                await vm.fetchGalleryItems()
            }
            .sheet(item: $expandedItem) { item in
                ZStack {
                    Color.black.ignoresSafeArea()
                    VStack(spacing: 12) {
                        AsyncImage(url: item.imageURL) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                            case .failure:
                                Color.gray
                                    .aspectRatio(1, contentMode: .fit)
                                    .overlay(Text("Failed to load").foregroundStyle(.white))
                            default:
                                ProgressView()
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding()

                        Text(item.description)
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(.horizontal)

                        Button {
                            expandedItem = nil
                        } label: {
                            Label("Close", systemImage: "xmark.circle.fill")
                                .font(.headline)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                                .background(.ultraThinMaterial, in: Capsule())
                        }
                        .tint(.white)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .font(.system(.body, design: .rounded))
    }

    // MARK: - Gallery Card
    @ViewBuilder
    private func galleryCard(for item: GalleryItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            AsyncImage(url: item.imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    ZStack {
                        Color.gray.opacity(0.2)
                        Text("Failed to load")
                            .foregroundStyle(.secondary)
                    }
                default:
                    ZStack {
                        Color.gray.opacity(0.15)
                        ProgressView()
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.black.opacity(0.06))
            )

            Text(item.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 18).fill(Color(.systemBackground)))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.black.opacity(0.06))
        )
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        .contentShape(Rectangle())
    }
}

#Preview {
    Gallery()
}
