//
//  Events.swift
//  tgonea
//
//  Created by Soma Shekar on 30/12/25.
//

import SwiftUI

struct Events: View {
    @StateObject private var vm = UserViewModel()
    
    var body: some View {
        
        List {
            Section("Persons Retiring This Year") {
                if vm.members.isEmpty {
                    Text("No retirements found this year.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(vm.members) { member in
<<<<<<< Updated upstream
<<<<<<< Updated upstream
                                         HStack(alignment: .top, spacing: 10) {
                                             if let url = member.imageURL {
                                                 AsyncImage(url: url) { phase in
                                                     switch phase {
                                                     case .empty:
                                                         ProgressView()
                                                             .frame(width: 200, height: 100, alignment: .leading)
                                                     case .success(let image):
                                                         image
                                                             .resizable()
                                                             .scaledToFill()
                                                             .frame(width: 200, height: 100, alignment: .leading)
                                                             .clipped()
                                                     case .failure:
                                                         Image(systemName: "person.crop.rectangle")
                                                             .resizable()
                                                             .scaledToFit()
                                                             .frame(width: 200, height: 100, alignment: .leading)
                                                             .foregroundStyle(.secondary)
                                                     @unknown default:
                                                         Image(systemName: "photo")
                                                             .resizable()
                                                             .scaledToFit()
                                                             .frame(width: 200, height: 100, alignment: .leading)
                                                             .foregroundStyle(.secondary)
                                                     }
                                                 }
                                             } else {
                                                 Image(systemName: "person.crop.rectangle")
                                                     .resizable()
                                                     .scaledToFit()
                                                     .frame(width: 200, height: 100, alignment: .leading)
                                                     .foregroundStyle(.secondary)
                                             }
                        VStack(alignment: .leading) {
                            Text(member.name)
                                .font(.headline)
                            Text(member.department)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
=======
=======
>>>>>>> Stashed changes
                        HStack(alignment: .top, spacing: 10) {

                            AsyncImage(url: member.imageURL) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 200, height: 100)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                case .failure:
                                    Image(systemName: "person.crop.rectangle")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundStyle(.secondary)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: 200, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(member.name)
                                    .font(.headline)
                                Text(member.department)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
                        }
                    }

                }
            }
            
        }
        
        .navigationTitle("Events")
        .task {
            await vm.loadRetiringThisYear()
        }
        .overlay(alignment: .bottom) {
            if let error = vm.errorMessage {
                Text(error)
                    .padding()
                    .background(.red.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding()
            }
        }
    }
}

#Preview {
    NavigationStack {
        Events()
    }
}
