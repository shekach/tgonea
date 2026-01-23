//  Created by Soma Shekar on 26/12/25.


import Foundation
import Combine
import FirebaseFirestore
import SwiftUI

@MainActor
final class UserViewModel: ObservableObject {
//model
    struct Member: Identifiable, Equatable {
        let id: String
        let name: String
        let phoneNumber: String
        let department: String
        let imageURL: URL?
        let dob: Date
        let qualifications: String
        let initialAppointmentYear: String
        let pph: String
    }

    @Published var members: [Member] = []
    @Published var department: [String] = []
    @Published var initialAppointmentYear: [String] = []
    @Published var errorMessage: String?

    private let db = Firestore.firestore()

    // MARK: - Retirement Logic
    private func isRetiringThisYear(dob: Date, retirementAge: Int = 61, calendar: Calendar = .current) -> Bool {
        let thisYear = calendar.component(.year, from: Date())
        let birthYear = calendar.component(.year, from: dob)
        // Person turns `retirementAge` this calendar year if:
        // (thisYear - birthYear) == retirementAge AND their birthday occurs this year.
        // We'll compute their birthday date this year and compare.
        var birthdayThisYear = calendar.dateComponents([.month, .day], from: dob)
        birthdayThisYear.year = thisYear
        guard let birthdayDateThisYear = calendar.date(from: birthdayThisYear) else { return false }

        let ageAtEndOfYear = thisYear - birthYear
        return ageAtEndOfYear == retirementAge && birthdayDateThisYear >= calendar.startOfDay(for: Date(timeIntervalSince1970: 0))
    }

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
// MARK: - Fetch intialAppointmentYear
    func fetchInitialAppointmentYear() async {
        do {
            let snapshot = try await db.collection("initialAppointmentYear").getDocuments()
            self.initialAppointmentYear = snapshot.documents.compactMap {
                $0.get("initialAppointmentYear") as? String ?? $0.get("year") as? String
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
                let initialAppointmentYear = doc.get("year") as? String ?? ""
                let pph = doc.get("pph") as? String ?? ""
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
                    qualifications: qualifications,
                    initialAppointmentYear: initialAppointmentYear,
                    pph: pph
                )
            }

            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    func loadRetiringThisYear(retirementAge: Int = 61) async {
        do {
            let snapshot = try await db.collection("users").getDocuments()

            let allMembers: [Member] = snapshot.documents.map { doc in
                let name = doc.get("name") as? String ?? ""
                let phoneNumber = doc.get("phoneNumber") as? String ?? ""
                let department = doc.get("department") as? String ?? ""
                let qualifications = doc.get("qualifications") as? String ?? ""
                let initialAppointmentYear = doc.get("year") as? String ?? ""
                let pph = doc.get("pph") as? String ?? ""

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
                    qualifications: qualifications,
                    initialAppointmentYear: initialAppointmentYear,
                    pph: pph
                )
            }

            self.members = allMembers.filter { isRetiringThisYear(dob: $0.dob, retirementAge: retirementAge) }
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
}
