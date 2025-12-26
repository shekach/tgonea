//
//  Members.swift
//  tgonea
//
//  Created by Soma Shekar on 26/12/25.
//

import SwiftUI

struct Members: View {

    // ✅ Correct wrapper for ObservableObject
    @StateObject private var vm = UserViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if let error = vm.errorMessage {
                    VStack(spacing: 12) {
                        Text("Error: \(error)")
                            .foregroundStyle(.red)

                        Button("Retry") {
                            Task { await vm.loadUsers() }
                        }
                    }
                } else if vm.members.isEmpty {
                    ProgressView("Loading users…")
                } else {
                    List(vm.members) { member in
                        HStack(spacing: 12) {

                            // ✅ imageURL is already URL?
                            AsyncImage(url: member.imageURL) { phase in
                                switch phase {
                                case .empty:
                                    placeholder(icon: "person.crop.circle.fill")
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                case .failure:
                                    placeholder(icon: "person.crop.circle.badge.exclam")
                                @unknown default:
                                    Color.clear
                                }
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                            Text(member.name)
                                .font(.body)
                        }
                    }
                }
            }
            .navigationTitle("Users")
            .task {
                // Choose ONE:
                await vm.loadUsers()      // one-time fetch
                // vm.realtimeUpdates()   // live Firestore updates
            }
            .refreshable {
                await vm.loadUsers()
            }
        }
    }

    // MARK: - Placeholder
    private func placeholder(icon: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.15))
            Image(systemName: icon)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    Members()
}
