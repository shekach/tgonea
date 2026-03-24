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
    @State private var animateHero = false

    var body: some View {
        ZStack {
            AppScreenBackground()

            ScrollView {
                VStack(spacing: 20) {
                    heroHeader
                        .padding(.top, 12)
                        .stagedAppear()

                    homeCard(
                        icon: "person.crop.circle.fill",
                        title: "Profile",
                        subtitle: "View & update details",
                        accent: AppTheme.accent,
                        secondary: AppTheme.gold,
                        destination: Profile()
                    )
                    .stagedAppear(0.05)

                    homeCard(
                        icon: "folder.fill",
                        title: "Circulars and G.O.s",
                        subtitle: "Latest circulars & updates",
                        accent: AppTheme.sky,
                        secondary: AppTheme.mint,
                        destination: Documents()
                    )
                    .stagedAppear(0.10)

                    homeCard(
                        icon: "person.3.fill",
                        title: "Members",
                        subtitle: "Association members list: (\(vm.members.count)) enrolled",
                        accent: AppTheme.mint,
                        secondary: AppTheme.sky,
                        destination: Members()
                    )
                    .stagedAppear(0.15)

                    homeCard(
                        icon: "phone.fill",
                        title: "Contact",
                        subtitle: "Reach the association",
                        accent: AppTheme.gold,
                        secondary: AppTheme.accent,
                        destination: Contact()
                    )
                    .stagedAppear(0.20)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            animateHero = true
            if vm.members.isEmpty {
                Task { await vm.loadUsers() }
            }
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .font(.system(.body, design: .rounded))
    }

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 10) {
                Text("TELANGANA GROUP-1 OFFICERS ASSOCIATION")
                    .font(.caption.weight(.bold))
                    .tracking(1.4)
                    .foregroundStyle(Color.white.opacity(0.82))

            }

            HStack(spacing: 10) {
                AppChip(icon: "sparkles", title: "Member First", isActive: true)
                AppChip(icon: "bell.badge.fill", title: "\(vm.members.count) members")
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(AppTheme.heroGradient)
                .overlay(
                    Circle()
                        .fill(AppTheme.gold.opacity(0.28))
                        .frame(width: 180, height: 180)
                        .blur(radius: 8)
                        .offset(x: 120, y: -70)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.16), lineWidth: 1)
        )
        .shadow(color: AppTheme.accent.opacity(0.24), radius: 22, y: 14)
        .scaleEffect(animateHero ? 1 : 0.97)
        .animation(.spring(response: 0.7, dampingFraction: 0.84), value: animateHero)
    }

    @ViewBuilder
    private func homeCard<Destination: View>(
        icon: String,
        title: String,
        subtitle: String,
        accent: Color,
        secondary: Color,
        destination: Destination
    ) -> some View {
        NavigationLink {
            destination
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [accent.opacity(0.92), secondary.opacity(0.72)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 72, height: 72)

                    Image(systemName: icon)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(AppTheme.ink)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.softText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(accent)
                    .padding(10)
                    .background(Circle().fill(accent.opacity(0.10)))
            }
            .padding(18)
            .appCardStyle()
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
