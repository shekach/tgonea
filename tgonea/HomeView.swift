//
//  HomeView.swift
//  tgonea
//
//  Created by Soma Shekar on 30/12/25.
//

import SwiftUI
import Combine

struct HomeView: View {

    @StateObject private var vm = UserViewModel()

    // MARK: - Animation State
    @State private var showCards = false

    var body: some View {
        ZStack {

            // MARK: - Background
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            // MARK: - Content
            ScrollView {
                VStack(spacing: 20) {

                    // MARK: - Header
                    VStack(spacing: 6) {
                        Text("Telangana Group-1 Officers Association")
                            .font(.title3)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)

                        Text("Service • Integrity • Leadership")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)

                    // MARK: - Home Cards

                    homeCard(
                        icon: "person.crop.circle.fill",
                        title: "Profile",
                        subtitle: "View & update details",
                        background: RadialGradient(gradient: Gradient(colors: [Color.pink.opacity(0.55), Color.red.opacity(0.30)]), center: .center, startRadius: 10, endRadius: 220),
                        destination: Profile()
                    )

                    homeCard(
                        icon: "megaphone.fill",
                        title: "Announcements",
                        subtitle: "Latest circulars & updates",
                        background: RadialGradient(gradient: Gradient(colors: [Color.cyan.opacity(0.55), Color.blue.opacity(0.30)]), center: .center, startRadius: 10, endRadius: 220),
                        destination: Documents()
                    )

                    homeCard(
                        icon: "person.3.fill",
                        title: "Members",
                        subtitle: "Association members list: (\(vm.members.count)) enrolled",
                        background: RadialGradient(gradient: Gradient(colors: [Color.green.opacity(0.55), Color.teal.opacity(0.30)]), center: .center, startRadius: 10, endRadius: 220),
                        destination: Members()
                    )

                    homeCard(
                        icon: "phone.fill",
                        title: "Contact",
                        subtitle: "Reach the association",
                        background: RadialGradient(gradient: Gradient(colors: [Color.orange.opacity(0.55), Color.yellow.opacity(0.30)]), center: .center, startRadius: 10, endRadius: 220),
                        destination:Association()
                    )

                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            showCards = true
            if vm.members.isEmpty {
                Task { await vm.loadUsers() }
            }
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Reusable Home Card
    @ViewBuilder
    private func homeCard<Destination: View> (
        icon: String,
        title: String,
        subtitle: String,
        background: RadialGradient,
        destination: Destination
    ) -> some View {
       NavigationLink {
           destination
       } label:{
        RoundedRectangle(cornerRadius: 18)
            .fill(background)
            .overlay(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.78)))
            .frame(height: 140)
            .shadow(color: .black.opacity(0.12), radius: 8, y: 6)
            .overlay(
                VStack(spacing: 10) {

                    Image(systemName: icon)
                        .font(.title)
                        .foregroundColor(
                            Color(red: 88/255, green: 16/255, blue: 16/255) // Telangana maroon
                        )

                    Text(title)
                        .font(.headline)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.cyan)
                }
            )

            // MARK: - Animation
            .opacity(showCards ? 1 : 0)
            .offset(y: showCards ? 0 : 30)
            .scaleEffect(showCards ? 1 : 0.97)
            .animation(
                .easeOut(duration: 0.6),
                value: showCards
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
