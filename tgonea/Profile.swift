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

    // MARK: - Form Fields
    @State private var name: String = ""
    @State private var phoneNumber: String = ""
    @State private var department: String = ""
    @State private var dob: Date = Date()
    @State private var qualifications: String = ""
    @State private var initialAppointmentYear: String = ""
    @State private  var pph: String = ""
    @State private var presentDesignation:String = ""
    @State private var presentPost:String = ""
    // MARK: - UI State
    @State private var showAlert = false
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
                TextField("Present Designation in the Departmnet", text: $presentDesignation)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.characters)
                    .focused($isFocused)
                TextField("Present Post held", text: $presentPost)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.characters)
                    .focused($isFocused)

                TextField("Phone Number", text: $phoneNumber)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: phoneNumber) { _, newValue in
                        phoneNumber = String(
                            newValue.filter { $0.isNumber }.prefix(10)
                        )
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

                // MARK: - Appointment Year Picker
                if vm.initialAppointmentYear.isEmpty {
                    ProgressView("Loading…")
                } else {
                    Picker("Intial year of appoinment in Group-1 service", selection: $initialAppointmentYear) {
                        Text("Select").tag("")
                        ForEach(vm.initialAppointmentYear, id: \.self) { initialAppointmentYear in
                            Text(initialAppointmentYear).tag(initialAppointmentYear)
                        }
                    }
                    .pickerStyle(.menu)

                    ZStack(alignment: .topLeading) {
                        if pph.isEmpty {
                            Text("Previous Posts held")
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 8)
                        }
                        TextEditor(text: $pph)
                            .textInputAutocapitalization(.sentences)
                    }
                    .font(.custom("HelveticaNeue", size: 13))
                    .foregroundColor(Color.gray)
                    .multilineTextAlignment(.leading)
                    .frame(width:300 , height:50)
                    .lineSpacing(10)
                    .padding()
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
                        if let data = try? await newItem?
                            .loadTransferable(type: Data.self) {
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
        // ✅ ALERT ATTACHED TO FORM (CORRECT)
        .alert("Application Submitted", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your application has been submitted successfully.")
        }
        .navigationTitle("Profile")
        .task {
            await vm.fetchDepartment()
            await vm.fetchInitialAppointmentYear()   
            
        }
        
    }

    // MARK: - Form Validation
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        phoneNumber.count == 10 &&
        !department.isEmpty &&
        !initialAppointmentYear.isEmpty &&
        !qualifications.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Submit Profile
    private func submitProfile() {

        let db = Firestore.firestore()

        let retirementDate = Calendar.current.date(
            byAdding: .year,
            value: 61,
            to: dob
        ) ?? dob

        func saveUser(photoURL: String? = nil) {

            var data: [String: Any] = [
                "name": name,
                "phoneNumber": phoneNumber,
                "department": department,
                "qualifications": qualifications,
                "dob": Timestamp(date: dob),
                "retirementDate": Timestamp(date: retirementDate),
                "createdAt": Timestamp(),
                "initialAppointmentYear": initialAppointmentYear,
                "pph":pph,
                "presentDesignation":presentDesignation,
                "presentPost":presentPost
            ]

            if let photoURL {
                data["photoURL"] = photoURL
            }

            db.collection("users").addDocument(data: data) { error in
                // Log error if any (optional)
                if let error = error {
                    print("Failed to add user document: \(error.localizedDescription)")
                }
                DispatchQueue.main.async {
                    resetForm()
                    showAlert = true   // ✅ ALERT FIRES HERE
                }
            }
        }

        // MARK: - Upload Photo if Selected
        if let imageData = selectedImageData {

            let ref = Storage.storage()
                .reference()
                .child("profileImages/\(UUID().uuidString).jpg")

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

    // MARK: - Reset Form
    private func resetForm() {
        name = ""
        phoneNumber = ""
        department = ""
        dob = Date()
        qualifications = ""
        selectedItem = nil
        selectedImageData = nil
        isFocused = false
        presentDesignation = ""
        pph = ""
        presentPost = ""
        initialAppointmentYear = ""
    }
}

#Preview {
    NavigationStack {
        Profile()
    }
}

