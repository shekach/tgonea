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
                                    Button(action: { expandedItem = item }) {
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
                                        .frame(maxWidth: 400, maxHeight: 200)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    .buttonStyle(.plain)
                                    
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
            .navigationTitle("Association")
            .task {
                await vm.fetchAssociationItems()
            }
            .sheet(item: $expandedItem) { item in
                ZStack {
                    Color.black.ignoresSafeArea()
                    VStack {
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
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black)
                        .padding()

                        Text(item.description)
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()

                        Button("Close") {
                            expandedItem = nil
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .clipShape(Capsule())
                        .foregroundColor(.white)
                    }
                }
            }
        }
    }
}



#Preview {
    Association()
}
