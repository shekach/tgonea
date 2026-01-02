//
//  Members.swift
//  tgonea
//
//  Created by Soma Shekar on 26/12/25.
//

//
//  Members.swift
//  tgonea
//
//  Created by Soma Shekar on 26/12/25.
//

import SwiftUI

struct Members: View {

    @StateObject private var vm = UserViewModel()

    var body: some View {
        NavigationStack {

            Group {
                if let error = vm.errorMessage {
                    VStack(spacing: 12) {
                        Text(error)
                            .foregroundStyle(.red)
                        Button("Retry") {
                            Task { await vm.loadUsers() }
                        }
                    }
                }
                else if vm.members.isEmpty {
                    ContentUnavailableView(
                        "No Users",
                        systemImage: "person.3",
                        description: Text("No members found")
                    )
                }
                else {
                    List(vm.members) { member in
                        memberRow(member)
                    }
                }
            }
            .navigationTitle("Users")
            .task {
                if vm.members.isEmpty {
                    await vm.loadUsers()
                }
            }
            .refreshable {
                await vm.loadUsers()
            }
        }
    }

    // MARK: - Member Row
    private func memberRow(_ member: UserViewModel.Member) -> some View {
        HStack(spacing: 12) {

            AsyncImage(url: member.imageURL) { phase in
                switch phase {
                case .empty:
                    placeholder(icon: "person.crop.circle.fill")
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    placeholder(icon: "person.crop.circle.badge.exclam")
                @unknown default:
                    Color.clear
                }
            }
            .frame(width: 72, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 6) {

                Text(member.name)
                    .font(.headline)

                Text(member.qualifications)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("📞 \(member.phoneNumber)")
                    .font(.subheadline)

                Text("🎂 Age: \(calculateAge(from: member.dob)) years")
                    .font(.subheadline.bold())

                Text("🏢 \(member.department)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }

    // MARK: - Age Calculation
    private func calculateAge(from dob: Date) -> Int {
        let calendar = Calendar.current
        let now = Date()
        return calendar.dateComponents([.year], from: dob, to: now).year ?? 0
    }

    // MARK: - Placeholder Image
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
