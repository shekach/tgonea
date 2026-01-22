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

    @State private var selectedDepartment: String = ""
    @State private var minAge: String = ""
    @State private var maxAge: String = ""
    @State private var initialAppointmentYear: String = ""

    // MARK: - Filtered Members
    private var filteredMembers: [UserViewModel.Member] {
        vm.members.filter { member in
            // Department filter (if selected)
            let matchesDepartment = selectedDepartment.isEmpty || member.department == selectedDepartment
            let matchesInitialYear = self.initialAppointmentYear.isEmpty || member.initialAppointmentYear == self.initialAppointmentYear

            // Age calculation
            let age = calculateAge(from: member.dob)

            // Min age filter
            let minOk: Bool = {
                if let min = Int(minAge) { return age >= min }
                return true
            }()

            // Max age filter
            let maxOk: Bool = {
                if let max = Int(maxAge) { return age <= max }
                return true
            }()

            return matchesDepartment && matchesInitialYear && minOk && maxOk
        }
    }

    var body: some View {
        NavigationStack {

            VStack(spacing: 12) {
                // Filters
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    // Department menu
                    Menu {
                        Button("All Departments") { selectedDepartment = "" }
                        ForEach(Array(Set(vm.members.map { $0.department })).sorted(), id: \.self) { dept in
                            Button(dept) { selectedDepartment = dept }
                        }
                    } label: {
                        HStack {
                            //Image(systemName: "building.2")
                            Text(selectedDepartment.isEmpty ? "Department" : selectedDepartment)
                                .frame(width:100 ,height:50,alignment: .leading)
                        }
                        .padding(8)
                        .background(Color.gray.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    // Min age
                    TextField("Min Age", text: $minAge)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 120)
                        .onChange(of: minAge) { _, newValue in
                            minAge = String(newValue.filter { $0.isNumber }.prefix(3))
                        }

                    // Max age
                    TextField("Max Age", text: $maxAge)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 120)
                        .onChange(of: maxAge) { _, newValue in
                            maxAge = String(newValue.filter { $0.isNumber }.prefix(3))
                        }

                    // Clear filters
                    Button {
                        selectedDepartment = ""
                        minAge = ""
                        maxAge = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityLabel("Clear Filters")
                }
                .padding(.horizontal)
                .padding(.top, 8)

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
                    else if filteredMembers.isEmpty {
                        ContentUnavailableView(
                            "No Users",
                            systemImage: "person.3",
                            description: Text("No members found")
                        )
                    }
                    else {
                        List(filteredMembers) { member in
                            memberRow(member)
                        }
                    }
                }
            }
            .navigationTitle("Members")
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
                 Text("🗓️ Initial Appointment: \(member.initialAppointmentYear)")
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
