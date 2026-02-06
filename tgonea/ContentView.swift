//
//  ContentView.swift
//  tgonea
//
//  Created by Soma Shekar on 26/12/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    private var tabTitle: String {
        switch selectedTab {
        case 0: return "Home"
        case 1: return "Association"
        case 2: return "Gallery"
        case 3: return "Events"
        default: return ""
        }
    }
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)
                Association()
                    .tabItem {
                        Label("Association", systemImage: "person.3.fill")
                    }
                    .tag(1)
                Events()
                    .tabItem {
                        Label("Events", systemImage: "calendar")
                    }
                    .tag(3)
                Gallery()
                    .tabItem {
                        Label("Gallery", systemImage: "photo.fill")
                    }
                    .tag(2)
                
            }
            .font(.system(.body, design: .rounded))
            .tabViewStyle(.automatic)
            .tint(Color.accentColor)
            .animation(.spring(response: 0.45, dampingFraction: 0.85), value: selectedTab)
            .background(
                LinearGradient(colors: [Color(.systemBackground), Color(.secondarySystemBackground)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
            .navigationTitle(tabTitle)
            .navigationBarTitleDisplayMode(.inline)
           
        }
        
    }
}
    


#Preview {
    ContentView()
}
