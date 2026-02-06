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
        ZStack {
            LinearGradient(colors: [Color(.systemGroupedBackground), Color(.secondarySystemGroupedBackground)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {

                    // MARK: - Profile Header Card
                    VStack(spacing: 14) {
                        HStack(alignment: .center, spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(.thinMaterial)
                                    .frame(width: 86, height: 86)
                                    .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                                if let data = selectedImageData, let image = UIImage(data: data) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 82, height: 82)
                                        .clipShape(Circle())
                                        .transition(.scale.combined(with: .opacity))
                                } else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 82, height: 82)
                                        .foregroundStyle(.secondary)
                                        .opacity(0.9)
                                }
                            }
                            VStack(alignment: .leading, spacing: 6) {
                                Text(name.isEmpty ? "Your Name" : name)
                                    .font(.title3.weight(.semibold))
                                Text(department.isEmpty ? "Department" : department)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            Text("Change Photo")
                                .font(.callout.weight(.semibold))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(Color.accentColor.opacity(0.12)))
                                .overlay(Capsule().stroke(Color.accentColor.opacity(0.25)))
                        }
                        .onChange(of: selectedItem) { _, newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                        selectedImageData = data
                                    }
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black.opacity(0.06))
                    )
                    .shadow(color: .black.opacity(0.06), radius: 10, y: 6)
                    .padding(.horizontal)

                    // MARK: - Personal Information Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Personal Information")
                            .font(.headline)
                        Group {
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
                                    phoneNumber = String(newValue.filter { $0.isNumber }.prefix(10))
                                }
                            DatePicker(
                                "Date of Birth (as per service book)",
                                selection: $dob,
                                displayedComponents: [.date]
                            )
                            TextField("Qualifications", text: $qualifications)
                                .textFieldStyle(.roundedBorder)
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
                                .frame(maxWidth: .infinity, minHeight: 100)
                                .lineSpacing(6)
                                .padding(8)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.secondarySystemBackground)))
                            }
                        }
                    }
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black.opacity(0.06))
                    )
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                    .padding(.horizontal)

                    // MARK: - Submit Button Card
                    VStack(alignment: .center) {
                        Button(action: { submitProfile() }) {
                            HStack(spacing: 10) {
                                Image(systemName: "paperplane.fill")
                                Text("Submit Application")
                                    .fontWeight(.semibold)
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.accentColor)
                        .disabled(!isFormValid)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                    }
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black.opacity(0.06))
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
        }
        // ✅ ALERT ATTACHED TO FORM (CORRECT)
        .alert("Application Submitted", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your application has been submitted successfully.")
        }
        .navigationTitle("Profile")
        .font(.system(.body, design: .rounded))
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: name)
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: department)
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

