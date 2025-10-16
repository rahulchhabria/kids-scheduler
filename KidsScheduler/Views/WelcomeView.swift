//
//  WelcomeView.swift
//  KidsScheduler
//
//  Initial welcome/login screen
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Logo and title
                VStack(spacing: 20) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 100))
                        .foregroundColor(.blue)

                    Text("Kids Scheduler")
                        .font(.system(size: 48, weight: .bold))

                    Text("Plan playdates with friends!")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Sign in button
                VStack(spacing: 20) {
                    Button(action: {
                        Task {
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let rootViewController = windowScene.windows.first?.rootViewController {
                                await authViewModel.signIn(presentingViewController: rootViewController)
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.title2)
                            Text("Sign in with Google")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: 400)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                    }

                    Text("Parents sign in to create profiles for kids")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 60)
            }
            .padding()
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .environmentObject(AuthenticationViewModel())
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
