//
//  ContentView.swift
//  tgonea
//
//  Created by Soma Shekar on 26/12/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
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
                Gallery()
                    .tabItem {
                        Label("Gallery", systemImage: "photo.fill")
                    }
                    .tag(2)
                
            }
            .tint(.blue)
           
        }
        
    }
}
    


#Preview {
    ContentView()
}
