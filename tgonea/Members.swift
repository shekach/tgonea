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
    @State private var selectedBatch: String = ""
    @State private var initialAppointmentYear: String = ""
    @State private var expandedMember: UserViewModel.Member? = nil

    // MARK: - Filtered Members
    private var filteredMembers: [UserViewModel.Member] {
        vm.members.filter { member in
            let matchesDepartment = selectedDepartment.isEmpty || member.department == selectedDepartment
            let matchesInitialYear = initialAppointmentYear.isEmpty || member.initialAppointmentYear == initialAppointmentYear
            return matchesDepartment && matchesInitialYear
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
                    Menu {
                        Button("All Batches") { initialAppointmentYear = "" }
                        ForEach(Array(Set(vm.members.map { $0.initialAppointmentYear })).sorted(), id: \.self) { year in
                            Button(year) { initialAppointmentYear = year }
                        }
                    } label: {
                        HStack {
                            Text(initialAppointmentYear.isEmpty ? "Batch Year" : initialAppointmentYear)
                                .frame(width:100 ,height:50,alignment: .leading)
                        }
                        .padding(8)
                        .background(Color.gray.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    

                    

                    
                    // Clear filters
                    Button {
                        selectedDepartment = ""
                        initialAppointmentYear = ""
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
     
        .sheet(item: $expandedMember) { member in
            ScrollView {
                VStack(spacing: 16) {
                    AsyncImage(url: member.imageURL) { phase in
                        switch phase {
                        case .empty:
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.2))
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 48))
                                    .foregroundStyle(.secondary)
                            }
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                        case .failure:
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.2))
                                Image(systemName: "person.crop.circle.badge.exclam")
                                    .font(.system(size: 48))
                                    .foregroundStyle(.secondary)
                            }
                        @unknown default:
                            Color.clear
                        }
                    }
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 8) {
                        Text(member.name)
                            .font(.title2.bold())

                        Text(member.qualifications)
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        Divider()

                        Group {
                            Text("Phone: \(member.phoneNumber)")
                            Text("Age: \(calculateAge(from: member.dob)) years")
                            Text("Department: \(member.department)")
                            Text("Initial Appointment: \(member.initialAppointmentYear)")
                            Text("Present Post: \(member.presentPost)")
                            Text("Present Designation: \(member.presentDesignation)")
                            Text("PPH: \(member.pph)")
                        }
                        .font(.body)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Button {
                        expandedMember = nil
                    } label: {
                        Text("Close")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.secondary.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
            .presentationDetents([.large])
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
            .contentShape(Rectangle())
            .onTapGesture {
                expandedMember = member
            }

            VStack(alignment: .leading, spacing: 6) {

                Text(member.name)
                    .font(.headline)

                Text(member.qualifications)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Phone:\(member.phoneNumber)")
                    .font(.subheadline)

                Text("Age: \(calculateAge(from: member.dob)) years")
                    .font(.subheadline.bold())

                Text("Department \(member.department)")
                    .font(.subheadline)
                    
                let year = member.initialAppointmentYear.trimmingCharacters(in: .whitespacesAndNewlines)
                Text(year.isEmpty ? "Initial Appointment: N/A" : "Initial Appointment: \(year)")
                    .font(.subheadline)

                Text(" \(member.presentPost)")
//
//                 Text(" \(member.presentDesignation)")
//
//                 Text(" \(member.pph)")

                   
                    
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

