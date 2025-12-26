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
    
    @Published var names: [String] = []
    @Published var errorMessage: String?
   private  let db = Firestore.firestore()
    
    func loadUsers() async {
        do {
            let snapshot = try await db.collection("users").getDocuments()
            let fetched = snapshot.documents.compactMap { doc in
                doc.get("name") as? String
                
            }
            self.names = fetched
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
            let fetched = snapshot?.documents.compactMap { $0.get("name") as? String } ?? []
            self.names = fetched
        }
    }
    
}
