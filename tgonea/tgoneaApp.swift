//
//  tgoneaApp.swift
//  tgonea
//
//  Created by Soma Shekar on 26/12/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    //FirebaseApp.configure()

    return true
  }
}

@main
struct tgoneaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    init() {
        FirebaseApp.configure()
        let settings = Firestore.firestore().settings
        settings.isPersistenceEnabled = true
        Firestore.firestore().settings = settings
        configureAppearance()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    private func configureAppearance() {
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithTransparentBackground()
        tabAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        tabAppearance.backgroundColor = UIColor.white.withAlphaComponent(0.72)
        tabAppearance.shadowColor = UIColor.black.withAlphaComponent(0.08)

        let selectedColor = UIColor(AppTheme.accent)
        let normalColor = UIColor(AppTheme.softText)

        [tabAppearance.stackedLayoutAppearance,
         tabAppearance.inlineLayoutAppearance,
         tabAppearance.compactInlineLayoutAppearance].forEach { layout in
            layout.selected.iconColor = selectedColor
            layout.selected.titleTextAttributes = [.foregroundColor: selectedColor]
            layout.normal.iconColor = normalColor
            layout.normal.titleTextAttributes = [.foregroundColor: normalColor]
        }

        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithTransparentBackground()
        navAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        navAppearance.backgroundColor = UIColor.white.withAlphaComponent(0.42)
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor(AppTheme.ink)]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(AppTheme.ink)]

        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().tintColor = selectedColor
    }
}
