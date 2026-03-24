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
        ZStack {
            AppScreenBackground()

            VStack(spacing: 12) {
                AppSectionHeader(
                    eyebrow: "Milestones",
                    title: "Persons retiring this year",
                    subtitle: "Recognising members as they step into their next chapter."
                )
                .padding(.horizontal)
                .padding(.top, 16)
                .stagedAppear()

                if vm.members.isEmpty {
                    VStack(spacing: 10) {
                        ContentUnavailableView("No retirements", systemImage: "person.crop.rectangle.stack.fill", description: Text("No retirements found this year."))
                    }
                    .padding(.top, 40)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(Array(vm.members.enumerated()), id: \.element.id) { index, member in
                                eventCard(member)
                                    .stagedAppear(Double(index) * 0.04 + 0.08)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                    }
                }
            }
        }
        .font(.system(.body, design: .rounded))
        .navigationTitle("Events")
        .task {
            await vm.loadRetiringThisYear()
        }
        .overlay(alignment: .bottom) {
            if let error = vm.errorMessage {
                Text(error)
                    .font(.footnote)
                    .padding(10)
                    .background(.red.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding()
            }
        }
    }

    // MARK: - Event Card
    @ViewBuilder
    private func eventCard(_ member: UserViewModel.Member) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Group {
                if let url = member.imageURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(AppTheme.sky.opacity(0.16))
                                ProgressView()
                            }
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(AppTheme.sky.opacity(0.16))
                                Image(systemName: "person.crop.rectangle")
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                            }
                        @unknown default:
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(AppTheme.sky.opacity(0.16))
                                Image(systemName: "photo")
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(AppTheme.sky.opacity(0.16))
                        Image(systemName: "person.crop.rectangle")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(width: 120, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 6) {
                Text(member.name)
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)
                Text(member.department)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.softText)
                Label("Retiring soon", systemImage: "sparkles")
                    .font(.footnote)
                    .foregroundStyle(AppTheme.accent)
            }
            Spacer()
        }
        .padding(12)
        .appCardStyle()
        .contentShape(Rectangle())
    }
}

#Preview {
    NavigationStack {
        Events()
    }
}
