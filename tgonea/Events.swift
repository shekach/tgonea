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
            LinearGradient(colors: [Color(.systemGroupedBackground), Color(.secondarySystemGroupedBackground)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                // Header
                HStack(spacing: 10) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.title2)
                        .foregroundStyle(.tint)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Persons Retiring This Year")
                            .font(.headline)
                        Text("Wishing them the best in their next chapter")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)

                if vm.members.isEmpty {
                    VStack(spacing: 10) {
                        ContentUnavailableView("No retirements", systemImage: "person.crop.rectangle.stack.fill", description: Text("No retirements found this year."))
                    }
                    .padding(.top, 40)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(vm.members) { member in
                                eventCard(member)
                                    .transition(.opacity.combined(with: .move(edge: .bottom)))
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
            // Image
            Group {
                if let url = member.imageURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.2))
                                ProgressView()
                            }
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.2))
                                Image(systemName: "person.crop.rectangle")
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                            }
                        @unknown default:
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.2))
                                Image(systemName: "photo")
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                        Image(systemName: "person.crop.rectangle")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(width: 120, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            // Text content
            VStack(alignment: .leading, spacing: 6) {
                Text(member.name)
                    .font(.headline)
                Text(member.department)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Label("Retiring soon", systemImage: "sparkles")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black.opacity(0.06))
        )
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        .contentShape(Rectangle())
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) { }
        }
    }
}

#Preview {
    NavigationStack {
        Events()
    }
}
