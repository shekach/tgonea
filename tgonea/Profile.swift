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

    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
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
