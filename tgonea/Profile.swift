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
            HStack{
                Text("Department:")
                if vm.department.isEmpty{
                    ProgressView("Loading..")
                } else {
                    Picker("Select department",selection:$department) {
                        Text("Select").tag("")
                        
                        ForEach(vm.department,id:\.self) { name in
                            Text(department).tag(department)
                            
                        }
                    }
                    .pickerStyle(.menu)
                }
                if !selectedName.isEmpty {
                               Text("Selected: \(selectedName)")
                                   .font(.subheadline.bold())
                           }
                if let error = vm.errorMessage {
                                Text(error)
                                    .foregroundStyle(.red)
                            }
            }
            .padding()
                    .task {
                        await vm.fetchDepartment()
                    }

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

            Button("Submit"){
                let db = Firestore.firestore()
                
                if let imageData = selectedImageData {
                    let storage = Storage.storage()
                    let storageRef = storage.reference()
                    let fileName = UUID().uuidString + ".jpg"
                    let imagesRef = storageRef.child("profileImages/\(fileName)")
                    
                    let metadata = StorageMetadata()
                    metadata.contentType = "image/jpeg"
                    
                    imagesRef.putData(imageData, metadata: metadata) { _, error in
                        if error == nil {
                            imagesRef.downloadURL { url, _ in
                                let urlString = url?.absoluteString ?? ""
                                db.collection("users").addDocument(data: [
                                    "name": name,
                                    "photoURL": urlString
                                ])
                            }
                        } else {
                            // If upload fails, still save the name
                            db.collection("users").addDocument(data: ["name": name])
                        }
                    }
                } else {
                    // No image selected, just save the name
                    db.collection("users").addDocument(data: ["name": name])
                    db.collection("users").addDocument(data: ["Phone Number": phoneNumber])
                    db.collection("users").addDocument(data: ["department": department])
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
    }
}

#Preview {
    Profile()
}
