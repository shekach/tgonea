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
                        }
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
