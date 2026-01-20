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
                        LazyVStack(spacing: 10) {
                            ForEach(vm.items) { item in
                                VStack(alignment: .leading, spacing: 8) {
                                    ScrollView(.vertical, showsIndicators: false) {
                                        
                                        
                                        Button(action: { expandedItem = item }) {
                                            CachedAsyncImage(url: item.imageURL, contentMode: .fit, cornerRadius: 12)
                                                .frame(width: 200, height: 200, alignment: .center)
                                        }
                                        .buttonStyle(.plain)
                                        
                                        Text(item.description)
                                            .font(.title)
                                            .padding(.trailing, 8)
                                            .frame(width:100,height:100,alignment: .center)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
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
                        CachedAsyncImage(url: item.imageURL, contentMode: .fit, cornerRadius: 12)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black)
                            .padding()

                        Text(item.description)
                            .font(.title)
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

