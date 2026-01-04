//
//  Profile.swift
//  tgonea
//
//  Created by Soma Shekar on 26/12/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import PhotosUI
import UIKit

struct Profile: View {

    @State private var name: String = ""
    @State private var phoneNumber: String = ""
    @State private var department: String = ""
    @State private var dob: Date = Date()
    @State private var qualifications: String = ""

    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?

    @StateObject private var vm = UserViewModel()
    @FocusState private var isFocused: Bool

    var body: some View {
        Form {

            // MARK: - Personal Information
            Section("Personal Information") {

                TextField("Name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.characters)
                    .focused($isFocused)

                TextField("Phone Number", text: $phoneNumber)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: phoneNumber) { _, newValue in
                        phoneNumber = String(newValue.filter { $0.isNumber }.prefix(10))
                    }

                DatePicker(
                    "Date of Birth (as per service book)",
                    selection: $dob,
                    displayedComponents: [.date]
                )

                TextField("Qualifications", text: $qualifications)
                    .textFieldStyle(.roundedBorder)

                // MARK: - Department Picker
                if vm.department.isEmpty {
                    ProgressView("Loading departments…")
                } else {
                    Picker("Department", selection: $department) {
                        Text("Select").tag("")
                        ForEach(vm.department, id: \.self) { dept in
                            Text(dept).tag(dept)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }

            // MARK: - Photo Picker
            Section("Profile Photo") {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    HStack(spacing: 12) {
                        if let data = selectedImageData,
                           let image = UIImage(data: data) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 64, height: 64)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 64, height: 64)
                                .foregroundStyle(.secondary)
                        }

                        Text("Choose Photo")
                            .font(.headline)
                    }
                }
                .onChange(of: selectedItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            selectedImageData = data
                        }
                    }
                }
            }

            // MARK: - Submit Button
            Section {
                Button("Submit") {
                    submitProfile()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isFormValid)
            }
        }
        .navigationTitle("Profile")
        .task {
            await vm.fetchDepartment()
        }
    }

    // MARK: - Form Validation
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        phoneNumber.count == 10 &&
        !department.isEmpty &&
        !qualifications.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Submit Profile
    private func submitProfile() {
        let db = Firestore.firestore()
        
        // Retirement at 61 years from DOB
        let retirementDate: Date = Calendar.current.date(byAdding: DateComponents(year: 61), to: dob) ?? dob

        func saveUser(photoURL: String? = nil) {
            var data: [String: Any] = [
                "name": name,
                "phoneNumber": phoneNumber,
                "department": department,
                "qualifications": qualifications,
                "dob": Timestamp(date: dob),
                "retirementDate": Timestamp(date: retirementDate),
                "createdAt": Timestamp()
            ]

            if let photoURL {
                data["photoURL"] = photoURL
            }

            db.collection("users").addDocument(data: data)
        }

        if let imageData = selectedImageData {
            let storage = Storage.storage()
            let fileName = UUID().uuidString + ".jpg"
            let ref = storage.reference().child("profileImages/\(fileName)")

            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"

            ref.putData(imageData, metadata: metadata) { _, error in
                if error == nil {
                    ref.downloadURL { url, _ in
                        saveUser(photoURL: url?.absoluteString)
                    }
                } else {
                    saveUser()
                }
            }
        } else {
            saveUser()
        }
    }
}

#Preview {
    NavigationStack {
        Profile()
    }
}
