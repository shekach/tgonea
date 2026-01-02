//
//  UserViewModel.swift
//  tgonea
//
//  Created by Soma Shekar on 26/12/25.
//

//
//  UserViewModel.swift
//  tgonea
//
//  Created by Soma Shekar on 26/12/25.
//

import Foundation
import FirebaseFirestore

@MainActor
final class UserViewModel: ObservableObject {

    struct Member: Identifiable, Equatable {
        let id: String
        let name: String
        let phoneNumber: String
        let department: String
        let imageURL: URL?
        let dob: Date
        let qualifications: String
    }

    @Published var members: [Member] = []
    @Published var department: [String] = []
    @Published var errorMessage: String?

    private let db = Firestore.firestore()

    // MARK: - Fetch Departments
    func fetchDepartment() async {
        do {
            let snapshot = try await db.collection("department").getDocuments()
            self.department = snapshot.documents.compactMap {
                $0.get("department") as? String ?? $0.get("name") as? String
            }
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - Load Users
    func loadUsers() async {
        do {
            let snapshot = try await db.collection("users").getDocuments()

            self.members = snapshot.documents.map { doc in

                let name = doc.get("name") as? String ?? ""
                let phoneNumber = doc.get("phoneNumber") as? String ?? ""
                let department = doc.get("department") as? String ?? ""
                let qualifications = doc.get("qualifications") as? String ?? ""

                // DOB as Date (IMPORTANT FOR AGE)
                let dob: Date
                if let ts = doc.get("dob") as? Timestamp {
                    dob = ts.dateValue()
                } else if let date = doc.get("dob") as? Date {
                    dob = date
                } else {
                    dob = Date()
                }

                let imageURLString =
                    doc.get("imageURL") as? String ??
                    doc.get("photoURL") as? String ??
                    doc.get("avatarURL") as? String

                let url = imageURLString.flatMap { URL(string: $0) }

                return Member(
                    id: doc.documentID,
                    name: name,
                    phoneNumber: phoneNumber,
                    department: department,
                    imageURL: url,
                    dob: dob,
                    qualifications: qualifications
                )
            }

        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
