//
//  News.swift
//  tgonea
//
//  Created by Soma Shekar on 30/12/25.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore

// Gallery model
struct GalleryItem: Identifiable {
            let id: String
           let title: String
      let description: String
        let imageUrl: URL
}
//View mOdel
final class GalleryViewModel : ObservableObject {
    @Published var items:[GalleryItem] = []
    @Published var isLoading = false

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    func fetchGallery() {
        isLoading = true
        db.collection("gallery")
        .order(by: "createdAt" , descending: true)
        .getDocumnets { snapshot , error in
                       guard let documents = snapshot?.documents else {
                           self.isLoading = false
                           return
                       }
                       var loadedItems: [GalleryItem] = []
                       let group = DispatchGroup()
                       for doc in documents {
                           let data = doc.data()
                           guard
                           let title = data["title"] as? String,
                           let description = data["description"] as? String,
                           let imagePath = data["imagePath"] as? String

                           else { continue }
                           group.enter()
                           let ref = self.strorage.reference(withPath: imagePath)
                           ref.downloadURL {
                               loadedItems.append(
                                   GalleryItem(
                                       id:doc.documentId,
                                       title: title,
                                       description: description,
                                       imageURL :url
                                   )
                               )
                           }
                           group.leave()
                       }
                       
            
        }
        group.notify(queue:.main) {
            self.items = loadedItems
            self.isLopading = false
        }
    }
}


struct GalleryCard: View {
    let item: GalleryItem
   
    var body: some View {
      
        VStack(alignment: .leading, spacing:8) {
       AsyncImage(url: item.imageURL) { phase in
                                       switch phase {
                                           case .empty:
                                           ProgressView()
                                           .frame(height: 200)
                                           case .success(let image):
                                           image
                                           .resizable()
                                           .scaledToFill()
                                           .frame(height:200)
                                           .clipped()

                                           case .failure:
                                           Color.gray
                                           .frame(height:200)
                                           @unknown default:
                                           EmptyView()
                                       }
           
       }
            Text(item.title)
            .font(.headline)
             Text(item.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 6, y: 4)
    }
    import SwiftUI

struct Gallery: View {

    @StateObject private var vm = GalleryViewModel()

    var body: some View {
        ZStack {

            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            if vm.isLoading {
                ProgressView("Loading gallery...")
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(vm.items) { item in
                            GalleryCard(item: item)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Gallery")
        .task {
            vm.fetchGallery()
        }
    }
}

}

#Preview {
    Gallery()
}
