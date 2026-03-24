//
//  Association.swift
//  tgonea
//
//  Created by Soma Shekar on 16/01/26.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct Association: View {
    @StateObject private var vm = AssociationViewModel()
    @State private var expandedItem: AssociationItem? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppScreenBackground()

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
                                Task { await vm.fetchAssociationItems() }
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
                            VStack(spacing: 18) {
                                AppSectionHeader(
                                    eyebrow: "Association",
                                    title: "Moments and messages from the association",
                                    subtitle: "Browse featured updates with a richer, gallery-style presentation."
                                )
                                .padding(.top, 16)
                                .stagedAppear()

                                LazyVStack(spacing: 14) {
                                    ForEach(Array(vm.items.enumerated()), id: \.element.id) { index, item in
                                        Button {
                                            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                                                expandedItem = item
                                            }
                                        } label: {
                                            associationCard(for: item)
                                        }
                                        .buttonStyle(.plain)
                                        .stagedAppear(Double(index) * 0.04 + 0.08)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                        }
                    }
                }
            }
            .navigationTitle("Association")
            .task {
                await vm.fetchAssociationItems()
            }
            .sheet(item: $expandedItem) { item in
                ZStack {
                    AppTheme.accentDeep.ignoresSafeArea()
                    VStack(spacing: 12) {
                        CachedAsyncImage(url: item.imageURL, contentMode: .fit, cornerRadius: 16)
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.4), radius: 16, y: 8)
                            .padding()

                        Text(item.description)
                            .font(.body)
                            .foregroundStyle(.white)
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
    
    // MARK: - Association Card
    @ViewBuilder
    private func associationCard(for item: AssociationItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            CachedAsyncImage(url: item.imageURL, contentMode: .fill, cornerRadius: 16)
                .frame(maxWidth: .infinity ,maxHeight: .infinity)
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .scaledToFit()
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black.opacity(0.06))
                )
            Text(item.description)
                .font(.subheadline)
                .foregroundStyle(AppTheme.softText)
                .lineLimit(3)
        }
        .padding(12)
        .appCardStyle()
        .contentShape(Rectangle())
    }
}

#Preview {
    Association()
}
