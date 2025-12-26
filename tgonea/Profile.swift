//
//  Profile.swift
//  tgonea
//
//  Created by Soma Shekar on 26/12/25.
//

import SwiftUI
import FirebaseFirestore

struct Profile: View {
    @State var name: String = ""
    @FocusState private var isFocused: Bool
    
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
            Button("Submit"){
                let db = Firestore.firestore()
                db.collection("users").addDocument(data: ["name":name])
               
                
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
