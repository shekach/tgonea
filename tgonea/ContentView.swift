//
//  ContentView.swift
//  tgonea
//
//  Created by Soma Shekar on 26/12/25.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        NavigationStack {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                Association()
                    .tabItem {
                        Label("Association", systemImage: "person.3.fill")
                    }
                Events()
                    .tabItem {
                        Label("Events", systemImage: "calendar")
                    }
                Gallery()
                    .tabItem {
                        Label("Gallery", systemImage: "photo.fill")
                    }
                
            }
           
        }
        
    }
}
    


#Preview {
    ContentView()
}
