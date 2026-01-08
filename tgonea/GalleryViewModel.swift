//  GalleryViewModel.swift
//  tgonea
//
//  Created to manage gallery image data from Firestore.

import Foundation
import FirebaseFirestore
import SwiftUI
import Combine

struct GalleryItem: Identifiable, Equatable {
    let id: String
    let imageURL: URL
    let description: String
}

@MainActor
final class GalleryViewModel: ObservableObject {
    @Published var items: [GalleryItem] = []
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    func fetchGalleryItems() async {
        do {
            let snapshot = try await db.collection("gallery").getDocuments()
            self.items = snapshot.documents.compactMap { doc in
                guard let urlString = doc.get("imageURL") as? String,
                      let url = URL(string: urlString),
                      let description = doc.get("description") as? String else {
                          return nil
                      }
                return GalleryItem(id: doc.documentID, imageURL: url, description: description)
            }
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}

