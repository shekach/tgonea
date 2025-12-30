//
//  ContentView.swift
//  tgonea
//
//  Created by Soma Shekar on 26/12/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
           HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
               }
           Members()
               .tabItem {
                    Label("Members", systemImage: "person.2.fill")
                }
            Events()
                .tabItem {
                            Label("Events", systemImage: "calendar")
                        }
            News()
                .tabItem {
                            Label("News", systemImage: "newspaper.fill")
                        }
            Profile()
                .tabItem {
                            Label("Profile", systemImage: "person.fill")
                        }
                }
        }
    }


#Preview {
    ContentView()
}
