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
                    Gallery()
                        .tabItem {
                            Label("Gallery", systemImage: "photo.fill")
                        }
                    Profile()
                        .tabItem {
                            Label("Profile", systemImage: "person.fill")
                        }
                }
               .background(
                   Image("bg")
                       .resizable()
                       .scaledToFill()
                       .ignoresSafeArea()
               )
            }
            
        }
    
    


#Preview {
    ContentView()
}
