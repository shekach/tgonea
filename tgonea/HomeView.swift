//
//  HomeView.swift
//  tgonea
//
//  Created by Soma Shekar on 30/12/25.
//

import SwiftUI

struct HomeView: View {

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
                        subtitle: "View & update details"
                    )

                    homeCard(
                        icon: "megaphone.fill",
                        title: "Announcements",
                        subtitle: "Latest circulars & updates"
                    )

                    homeCard(
                        icon: "person.3.fill",
                        title: "Members",
                        subtitle: "Association members list"
                    )

                    homeCard(
                        icon: "phone.fill",
                        title: "Contact",
                        subtitle: "Reach the association"
                    )

                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            showCards = true
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Reusable Home Card
    @ViewBuilder
    private func homeCard(
        icon: String,
        title: String,
        subtitle: String
    ) -> some View {

        RoundedRectangle(cornerRadius: 18)
            .fill(Color.white)
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
                        .foregroundColor(.secondary)
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
}

#Preview {
    NavigationStack {
        HomeView()
    }
}

