//
//  Profile.swift
//  tgonea
//
//  Created by Soma Shekar on 26/12/25.
//

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
                    "Date
