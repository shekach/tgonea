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
    private struct SubmittedProfile {
        let name: String
        let phoneNumber: String
        let department: String
        let dob: Date
        let qualifications: String
        let initialAppointmentYear: String
        let pph: String
        let presentDesignation: String
        let presentPost: String
        let imageData: Data?
    }

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
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var submittedProfile: SubmittedProfile?

    @StateObject private var vm = UserViewModel()
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            AppScreenBackground()
            ScrollView {
                VStack(spacing: 16) {
                    AppSectionHeader(
                        eyebrow: "Profile",
                        title: "Create and review your member profile",
                        subtitle: "Fill in your details, submit once, and instantly review the saved information below."
                    )
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .stagedAppear()

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
                            AppChip(icon: "camera.fill", title: "Change Photo", isActive: true)
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
                    .padding(20)
                    .appGlassCardStyle()
                    .padding(.horizontal)
                    .stagedAppear(0.05)

                    // MARK: - Personal Information Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Personal Information")
                            .font(.headline)
                            .foregroundStyle(AppTheme.ink)
                        Group {
                            TextField("Name", text: $name)
                                .textInputAutocapitalization(.characters)
                                .focused($isFocused)
                                .appFieldStyle()
                            TextField("Present Designation in the Departmnet", text: $presentDesignation)
                                .textInputAutocapitalization(.characters)
                                .focused($isFocused)
                                .appFieldStyle()
                            TextField("Present Post held", text: $presentPost)
                                .textInputAutocapitalization(.characters)
                                .focused($isFocused)
                                .appFieldStyle()
                            TextField("Phone Number", text: $phoneNumber)
                                .keyboardType(.numberPad)
                                .onChange(of: phoneNumber) { _, newValue in
                                    phoneNumber = String(newValue.filter { $0.isNumber }.prefix(10))
                                }
                                .appFieldStyle()
                            DatePicker(
                                "Date of Birth (as per service book)",
                                selection: $dob,
                                displayedComponents: [.date]
                            )
                            .appFieldStyle()
                            TextField("Qualifications", text: $qualifications)
                                .appFieldStyle()
                            if vm.department.isEmpty {
                                ProgressView("Loading departments…")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .appFieldStyle()
                            } else {
                                Picker("Department", selection: $department) {
                                    Text("Select").tag("")
                                    ForEach(vm.department, id: \.self) { dept in
                                        Text(dept).tag(dept)
                                    }
                                }
                                .pickerStyle(.menu)
                                .appFieldStyle()
                            }
                            if vm.initialAppointmentYear.isEmpty {
                                ProgressView("Loading…")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .appFieldStyle()
                            } else {
                                Picker("Intial year of appoinment in Group-1 service", selection: $initialAppointmentYear) {
                                    Text("Select").tag("")
                                    ForEach(vm.initialAppointmentYear, id: \.self) { initialAppointmentYear in
                                        Text(initialAppointmentYear).tag(initialAppointmentYear)
                                    }
                                }
                                .pickerStyle(.menu)
                                .appFieldStyle()
                                ZStack(alignment: .topLeading) {
                                    if pph.isEmpty {
                                        Text("Previous Posts held")
                                            .foregroundColor(AppTheme.softText)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 14)
                                    }
                                    TextEditor(text: $pph)
                                        .textInputAutocapitalization(.sentences)
                                        .scrollContentBackground(.hidden)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 8)
                                }
                                .font(.custom("HelveticaNeue", size: 13))
                                .foregroundColor(AppTheme.ink)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, minHeight: 100)
                                .lineSpacing(6)
                                .background(Color.clear)
                                .appFieldStyle()
                            }
                        }
                    }
                    .padding(20)
                    .appCardStyle()
                    .padding(.horizontal)
                    .stagedAppear(0.10)

                    // MARK: - Submit Button Card
                    VStack(alignment: .center) {
                        Button(action: { submitProfile() }) {
                            HStack(spacing: 10) {
                                Image(systemName: "paperplane.fill")
                                Text("Submit Application")
                                    .fontWeight(.semibold)
                            }
                        }
                        .buttonStyle(AppPrimaryButtonStyle())
                    }
                    .padding(20)
                    .appGlassCardStyle()
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                    .stagedAppear(0.15)

                    if let submittedProfile {
                        submittedInfoCard(for: submittedProfile)
                            .padding(.horizontal)
                            .padding(.bottom, 24)
                            .stagedAppear(0.20)
                    }
                }
            }
        }
        // ✅ ALERT ATTACHED TO FORM (CORRECT)
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
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

    @ViewBuilder
    private func submittedInfoCard(for profile: SubmittedProfile) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Submitted Information")
                .font(.headline)

            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(.thinMaterial)
                        .frame(width: 76, height: 76)

                    if let data = profile.imageData, let image = UIImage(data: data) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 72, height: 72)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 72, height: 72)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.name)
                        .font(.title3.weight(.semibold))
                    Text(profile.department)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            submittedInfoRow(title: "Present Designation", value: profile.presentDesignation)
            submittedInfoRow(title: "Present Post", value: profile.presentPost)
            submittedInfoRow(title: "Phone Number", value: profile.phoneNumber)
            submittedInfoRow(title: "Date of Birth", value: Self.displayDateFormatter.string(from: profile.dob))
            submittedInfoRow(title: "Qualifications", value: profile.qualifications)
            submittedInfoRow(title: "Initial Appointment Year", value: profile.initialAppointmentYear)
            submittedInfoRow(title: "Previous Posts Held", value: profile.pph)
        }
        .padding(20)
        .appCardStyle()
    }

    @ViewBuilder
    private func submittedInfoRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.accent)
            Text(value.isEmpty ? "-" : value)
                .font(.body)
                .foregroundStyle(AppTheme.ink)
        }
    }

    // MARK: - Form Validation
    private var firstValidationMessage: String? {
        if selectedImageData == nil {
            return "Please add a profile photo."
        }
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Please enter your name."
        }
        if presentDesignation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Please enter your present designation."
        }
        if presentPost.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Please enter your present post."
        }
        if phoneNumber.isEmpty {
            return "Please enter your phone number."
        }
        if phoneNumber.count != 10 {
            return "Phone number must be exactly 10 digits."
        }
        if qualifications.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Please enter your qualifications."
        }
        if department.isEmpty {
            return "Please select your department."
        }
        if initialAppointmentYear.isEmpty {
            return "Please select your initial appointment year."
        }
        if pph.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Please enter your previous posts held."
        }
        return nil
    }

    // MARK: - Submit Profile
    private func submitProfile() {
        if let firstValidationMessage {
            alertTitle = "Incomplete Form"
            alertMessage = firstValidationMessage
            showAlert = true
            return
        }

        let submittedSnapshot = SubmittedProfile(
            name: name,
            phoneNumber: phoneNumber,
            department: department,
            dob: dob,
            qualifications: qualifications,
            initialAppointmentYear: initialAppointmentYear,
            pph: pph,
            presentDesignation: presentDesignation,
            presentPost: presentPost,
            imageData: selectedImageData
        )

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
                if let error = error {
                    print("Failed to add user document: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        alertTitle = "Submission Failed"
                        alertMessage = "We couldn't submit your application right now. Please try again."
                        showAlert = true
                    }
                    return
                }
                DispatchQueue.main.async {
                    submittedProfile = submittedSnapshot
                    resetForm()
                    alertTitle = "Application Submitted"
                    alertMessage = "Your application has been submitted successfully."
                    showAlert = true
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

    private static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

#Preview {
    NavigationStack {
        Profile()
    }
}
