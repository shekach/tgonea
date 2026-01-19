//
//  AssociationViewModel.swift
//  tgonea
//
//  Created by Soma Shekar on 19/01/26.
//

import Foundation
import FirebaseFirestore
import SwiftUI
import Combine
import FirebaseStorage

struct AssociationItem: Identifiable, Equatable {
    let id: String
    let imageURL: URL
    let description: String
}

@MainActor
final class AssociationViewModel: ObservableObject {
    @Published var items: [AssociationItem] = []
    @Published var errorMessage: String?
    
    private var hasLoaded = false
    
    private let db = Firestore.firestore()
    
    func fetchAssociationItems() async {
        if hasLoaded { return }
        do {
            let snapshot = try await db.collection("Association").getDocuments()
            self.items = snapshot.documents.compactMap { doc in
                guard let urlString = doc.get("imageURL") as? String,
                      let url = URL(string: urlString),
                      let description = doc.get("description") as? String else {
                          return nil
                      }
                return AssociationItem(id: doc.documentID, imageURL: url, description: description)
            }
            self.errorMessage = nil
            self.hasLoaded = true
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}

