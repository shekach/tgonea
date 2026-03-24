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
                AppScreenBackground()

                VStack(spacing: 12) {
                    AppSectionHeader(
                        eyebrow: "Directory",
                        title: "Find members quickly",
                        subtitle: "Filter by department or batch year and open a polished profile sheet for details."
                    )
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .stagedAppear()

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            Menu {
                                Button("All Departments") { selectedDepartment = "" }
                                ForEach(Array(Set(vm.members.map { $0.department })).sorted(), id: \.self) { dept in
                                    Button(dept) { selectedDepartment = dept }
                                }
                            } label: {
                                AppChip(
                                    icon: "building.2.fill",
                                    title: selectedDepartment.isEmpty ? "Department" : selectedDepartment,
                                    isActive: !selectedDepartment.isEmpty
                                )
                            }

                            Menu {
                                Button("All Batches") { initialAppointmentYear = "" }
                                ForEach(Array(Set(vm.members.map { $0.initialAppointmentYear })).sorted(), id: \.self) { year in
                                    Button(year) { initialAppointmentYear = year }
                                }
                            } label: {
                                AppChip(
                                    icon: "calendar",
                                    title: initialAppointmentYear.isEmpty ? "Batch Year" : initialAppointmentYear,
                                    isActive: !initialAppointmentYear.isEmpty
                                )
                            }

                            Button {
                                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                                    selectedDepartment = ""
                                    initialAppointmentYear = ""
                                }
                            } label: {
                                AppChip(icon: "arrow.counterclockwise", title: "Reset")
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Clear Filters")
                        }
                        .padding(.horizontal)
                    }
                    .stagedAppear(0.06)

                    Group {
                        if let error = vm.errorMessage {
                            VStack(spacing: 12) {
                                Text(error)
                                    .foregroundStyle(.red)
                                Button("Retry") {
                                    Task { await vm.loadUsers() }
                                }
                                .buttonStyle(AppPrimaryButtonStyle())
                            }
                            .padding()
                            .appCardStyle()
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
                                    ForEach(Array(filteredMembers.enumerated()), id: \.element.id) { index, member in
                                        Button {
                                            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                                                expandedMember = member
                                            }
                                        } label: {
                                            memberCard(member)
                                        }
                                        .buttonStyle(.plain)
                                        .stagedAppear(Double(index) * 0.03 + 0.08)
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
            ZStack {
                AppScreenBackground()

                ScrollView {
                    VStack(spacing: 16) {
                        AsyncImage(url: member.imageURL) { phase in
                            switch phase {
                            case .empty:
                                ZStack {
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(AppTheme.sky.opacity(0.18))
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
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(AppTheme.sky.opacity(0.18))
                                    Image(systemName: "person.crop.circle.badge.exclam")
                                        .font(.system(size: 48))
                                        .foregroundStyle(.secondary)
                                }
                            @unknown default:
                                Color.clear
                            }
                        }
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .stagedAppear()

                        VStack(alignment: .leading, spacing: 12) {
                            Text(member.name)
                                .font(.title2.bold())
                                .foregroundStyle(AppTheme.ink)

                            Text(member.qualifications)
                                .font(.headline)
                                .foregroundStyle(AppTheme.softText)

                            Divider()

                            profileLine(title: "Phone", value: member.phoneNumber)
                            profileLine(title: "Age", value: "\(calculateAge(from: member.dob)) years")
                            profileLine(title: "Department", value: member.department)
                            profileLine(title: "Initial Appointment", value: member.initialAppointmentYear)
                            profileLine(title: "Present Post", value: member.presentPost)
                            profileLine(title: "Present Designation", value: member.presentDesignation)
                            profileLine(title: "PPH", value: member.pph)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .appCardStyle()
                        .stagedAppear(0.08)

                        Button {
                            expandedMember = nil
                        } label: {
                            Text("Close")
                        }
                        .buttonStyle(AppPrimaryButtonStyle())
                        .stagedAppear(0.12)
                    }
                    .padding()
                }
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
                    .foregroundStyle(AppTheme.ink)
                Text(member.qualifications)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.softText)
                HStack(spacing: 8) {
                    Label("\(calculateAge(from: member.dob)) yrs", systemImage: "birthday.cake.fill")
                    Label(member.department, systemImage: "building.2")
                }
                .font(.footnote)
                .foregroundStyle(AppTheme.accent)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(AppTheme.accent.opacity(0.65))
        }
        .padding(14)
        .appCardStyle()
        .contentShape(Rectangle())
    }

    private func profileLine(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.accent)
            Text(value.isEmpty ? "-" : value)
                .font(.body)
                .foregroundStyle(AppTheme.ink)
        }
    }
}

#Preview {
    Members()
}
