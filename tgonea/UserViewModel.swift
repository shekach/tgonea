//
//  UserViewModel.swift
//  tgonea
//
//  Created by Soma Shekar on 26/12/25.
//

import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class UserViewModel: ObservableObject {
    
    struct Member: Identifiable, Equatable {
        let id: String
        let name: String
        let imageURL: URL?
    }

    @Published var members: [Member] = []
    @Published var errorMessage: String?
    private let db = Firestore.firestore()
    
    func loadUsers() async {
        do {
            let snapshot = try await db.collection("users").getDocuments()
            let fetched: [Member] = snapshot.documents.map { doc in
                let name = (doc.get("name") as? String) ?? ""
                
                // Try common keys for image url. Prefer `imageURL`, fall back to `photoURL` or `avatarURL`.
                let imageURLString = (doc.get("imageURL") as? String)
                    ?? (doc.get("photoURL") as? String)
                    ?? (doc.get("avatarURL") as? String)
                let url = imageURLString.flatMap { URL(string: $0) }
                return Member(id: doc.documentID, name: name, imageURL: url)
            }
            self.members = fetched
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    func realtimeUpdates() {
        db.collection("users").addSnapshotListener { [weak self] snapshot, error in
            guard let self else { return }
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            let fetched: [Member] = (snapshot?.documents ?? []).map { doc in
                let name = (doc.get("name") as? String) ?? ""
                let imageURLString = (doc.get("imageURL") as? String)
                    ?? (doc.get("photoURL") as? String)
                    ?? (doc.get("avatarURL") as? String)
                let url = imageURLString.flatMap { URL(string: $0) }
                return Member(id: doc.documentID, name: name, imageURL: url)
            }
            self.members = fetched
        }
    }
    
}

