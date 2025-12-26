//
//  Members.swift
//  tgonea
//
//  Created by Soma Shekar on 26/12/25.
//

import SwiftUI

struct Members: View {
    @StateObject private var vm = UserViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if let error = vm.errorMessage {
                    VStack(spacing: 12) {
                        Text("Error: \(error)")
                            .foregroundStyle(.red)
                        Button("Retry") {
                            Task { await vm.loadUsers() }
                        }
                    }
                } else {
                    List(vm.names, id: \.self) { name in
                        Text(name)
                    }
                }
            }
            .navigationTitle("Users")
            .task {
                // Choose one:
                await vm.loadUsers()         // One-time fetch
                 //vm.startRealtimeUpdates()  // Or live updates
            }
            .refreshable {
                await vm.loadUsers()
            }
        }
    }
}

#Preview {
    Members()
}
