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
        let phoneNumber: String
        let department: String
        let imageURL: URL?
        
    }

    @Published var members: [Member] = []
    @Published var department:[String] = []
    @Published var errorMessage: String?
    private let db = Firestore.firestore()
    
    func fetchDepartment() async {
        do {
            let snapshot = try await db.collection("department").getDocuments()
            let names = snapshot.documents.compactMap { doc -> String? in
                if let value = doc.get("department") as? String { return value }
                if let value = doc.get("name") as? String { return value }
                return nil
            }
            self.department = names
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    func loadUsers() async {
        do {
            let snapshot = try await db.collection("users").getDocuments()
            let fetched: [Member] = snapshot.documents.map { doc in
                let name = (doc.get("name") as? String) ?? ""
                let phoneNumber = (doc.get("phoneNumber") as? String) ?? ""
                let department = (doc.get("department") as? String) ?? ""
                // Try common keys for image url. Prefer `imageURL`, fall back to `photoURL` or `avatarURL`.
                let imageURLString = (doc.get("imageURL") as? String)
                    ?? (doc.get("photoURL") as? String)
                    ?? (doc.get("avatarURL") as? String)
                let url = imageURLString.flatMap { URL(string: $0) }
                return Member(id: doc.documentID, name: name, phoneNumber: phoneNumber,department: department, imageURL: url)
            }
            self.members = fetched
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
//    func realtimeUpdates() {
//        db.collection("users").addSnapshotListener { [weak self] snapshot, error in
//            guard let self else { return }
//            if let error = error {
//                self.errorMessage = error.localizedDescription
//                return
//            }
//            let fetched: [Member] = (snapshot?.documents ?? []).map { doc in
//                let name = (doc.get("name") as? String) ?? ""
//                let imageURLString = (doc.get("imageURL") as? String)
//                    ?? (doc.get("photoURL") as? String)
//                    ?? (doc.get("avatarURL") as? String)
//                let url = imageURLString.flatMap { URL(string: $0) }
//                return Member(id: doc.documentID, name: name, imageURL: url)
//            }
//            self.members = fetched
//        }
//    }
    
}
