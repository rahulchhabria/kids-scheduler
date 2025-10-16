//
//  ContentView.swift
//  KidsScheduler
//
//  Root view that determines which screen to show based on auth state
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var debugScreen: DebugScreen = .welcome

    var body: some View {
        if DEBUG_MODE {
            // Debug mode: Show screen picker
            NavigationView {
                VStack(spacing: 20) {
                    Text("🐛 DEBUG MODE")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Select a screen to preview:")
                        .font(.headline)

                    ScrollView {
                        VStack(spacing: 12) {
                            debugButton("Welcome Screen", screen: .welcome)
                            debugButton("Child Profile Setup", screen: .childSetup)
                            debugButton("Main Tab View (Calendar)", screen: .mainTabs)
                        }
                        .padding()
                    }

                    Spacer()
                }
                .padding()
            }
            .sheet(isPresented: .constant(debugScreen != .none)) {
                debugScreenView
            }
        } else {
            // Production mode: Normal authentication flow
            Group {
                if authViewModel.isAuthenticated {
                    if authViewModel.hasChildProfiles {
                        MainTabView()
                    } else {
                        ChildProfileSetupView()
                    }
                } else {
                    WelcomeView()
                }
            }
        }
    }

    private func debugButton(_ title: String, screen: DebugScreen) -> some View {
        Button(action: {
            debugScreen = screen
        }) {
            HStack {
                Text(title)
                    .font(.title3)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
        }
        .foregroundColor(.primary)
    }

    @ViewBuilder
    private var debugScreenView: some View {
        switch debugScreen {
        case .welcome:
            WelcomeView()
        case .childSetup:
            ChildProfileSetupView()
        case .mainTabs:
            MainTabView()
        case .none:
            EmptyView()
        }
    }
}

enum DebugScreen {
    case none
    case welcome
    case childSetup
    case mainTabs
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthenticationViewModel())
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
