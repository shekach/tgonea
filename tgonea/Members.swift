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
            ZStack {
                LinearGradient(colors: [Color(.systemGroupedBackground), Color(.secondarySystemGroupedBackground)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack(spacing: 12) {
                    // Filters
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Menu {
                            Button("All Departments") { selectedDepartment = "" }
                            ForEach(Array(Set(vm.members.map { $0.department })).sorted(), id: \.self) { dept in
                                Button(dept) { selectedDepartment = dept }
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "building.2.fill")
                                Text(selectedDepartment.isEmpty ? "Department" : selectedDepartment)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color(.secondarySystemBackground)))
                        }

                        Menu {
                            Button("All Batches") { initialAppointmentYear = "" }
                            ForEach(Array(Set(vm.members.map { $0.initialAppointmentYear })).sorted(), id: \.self) { year in
                                Button(year) { initialAppointmentYear = year }
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "calendar")
                                Text(initialAppointmentYear.isEmpty ? "Batch Year" : initialAppointmentYear)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color(.secondarySystemBackground)))
                        }

                        Button {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                                selectedDepartment = ""
                                initialAppointmentYear = ""
                            }
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
                                .buttonStyle(.bordered)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
                            .padding(.horizontal)
                        } else if filteredMembers.isEmpty {
                            ContentUnavailableView(
                                "No Users",
                                systemImage: "person.3",
                                description: Text("No members found")
                            )
                            .padding(.top, 40)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(filteredMembers) { member in
                                        Button {
                                            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                                                expandedMember = member
                                            }
                                        } label: {
                                            memberCard(member)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 16)
                            }
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
        .font(.system(.body, design: .rounded))
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
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemBackground)))

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

    // MARK: - Member Card
    private func memberCard(_ member: UserViewModel.Member) -> some View {
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
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 6) {
                Text(member.name)
                    .font(.headline)
                Text(member.qualifications)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    Label("\(calculateAge(from: member.dob)) yrs", systemImage: "birthday.cake.fill")
                    Label(member.department, systemImage: "building.2")
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black.opacity(0.06))
        )
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        .contentShape(Rectangle())
    }
}

#Preview {
    Members()
}

