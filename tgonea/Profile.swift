//
//  Profile.swift
//  tgonea
//
//  Created by Soma Shekar on 26/12/25.
//

import SwiftUI
import UIKit
import FirebaseFirestore
import FirebaseStorage
import PhotosUI
 


struct Profile: View {
    @State var name: String = ""
    @FocusState private var isFocused: Bool
    @State var phoneNumber: String = ""
    @State var department: String = ""
    @State private var dob = Date()
    @State var qualifications: String = ""

    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @StateObject private var vm = UserViewModel()
    @State private var selectedName: String = ""
    var body: some View {
        VStack(spacing:20){
            HStack{
                Text("Name:")
                TextField("Name",text:$name)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .accessibilityLabel("name")
                    .foregroundStyle(.cyan)
                    .focused($isFocused)
                    .background(.ultraThinMaterial)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.gray.opacity(0.3)))
            }
            HStack{
                Text("Phone Number:")
                TextField("Phone Number",text:$phoneNumber)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .accessibilityLabel("phone number")
                    .foregroundStyle(.cyan)
                    .keyboardType(.phonePad)
                    .onChange(of: phoneNumber) { _, newValue in
                        phoneNumber = newValue.filter { $0.isNumber }
                            .prefix(10)
                            .description
                    }

            }
        HStack {
    Text("Date of Birth as per service book")
        .font(.subheadline)

    DatePicker(
        "",
        selection: $dob,
        displayedComponents: [.date]
    )
    .labelsHidden()
}
HStack {
 Text("Qualifications:")
 TextField("Qualifications",text:$qualifications)
}
            HStack{
                Text("Department:")
                if vm.department.isEmpty{
                    ProgressView("Loading..")
                } else {
                    Picker("Select department",selection:$department) {
                        Text("Select").tag("")
                        
                        ForEach(vm.department, id: \.self) { name in
                            Text(name).tag(name)
                            
                        }
                    }
                    .pickerStyle(.wheel)
                }
                if !department.isEmpty {
                    Text("Selected: \(department)")
                        .font(.subheadline.bold())
                }
                if let error = vm.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                }
            }
            .padding()

            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                HStack(spacing: 12) {
                    if let data = selectedImageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 64, height: 64)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(.gray.opacity(0.3)))
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 64, height: 64)
                            .foregroundStyle(.secondary)
                    }
                    Text("Choose Photo")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .onChange(of: selectedItem) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                    }
                }
            }
Button("Submit") {
    let db = Firestore.firestore()

    func saveUser(photoURL: String? = nil) {
        var data: [String: Any] = [
            "name": name,
            "phoneNumber": phoneNumber,
            "department": department,
            "dob": dob,
            "createdAt": Timestamp(),
         "qualifications":qualifications
        ]

        if let photoURL {
            data["photoURL"] = photoURL
        }

        db.collection("users").addDocument(data: data)
    }

    if let imageData = selectedImageData {
        let storage = Storage.storage()
        let fileName = UUID().uuidString + ".jpg"
        let imagesRef = storage.reference().child("profileImages/\(fileName)")

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        imagesRef.putData(imageData, metadata: metadata) { _, error in
            if error == nil {
                imagesRef.downloadURL { url, _ in
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
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .controlSize(.large)
            .font(.headline)
            .foregroundStyle(.white)
            .accessibilityLabel("Submit")
        }
        .padding()
        .task {
            await vm.fetchDepartment()
        }
    }
 

}

#Preview {
    Profile()
}
