//
//  AuthenticationViewModel.swift
//  KidsScheduler
//
//  View model for authentication state
//

import Foundation
import SwiftUI
import Combine

class AuthenticationViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var hasChildProfiles = false
    @Published var currentUser: User?
    @Published var children: [Child] = []

    private let authService = AuthenticationService()
    private let firestoreService = FirestoreService()

    init() {
        // Listen to auth service changes
        authService.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.currentUser = user
                self?.isAuthenticated = user != nil

                if let user = user {
                    Task {
                        await self?.fetchChildren(for: user)
                    }
                }
            }
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()

    func signIn(presentingViewController: UIViewController) async {
        do {
            try await authService.signInWithGoogle(presentingViewController: presentingViewController)
        } catch {
            print("Sign in error: \(error.localizedDescription)")
        }
    }

    func signOut() {
        do {
            try authService.signOut()
        } catch {
            print("Sign out error: \(error.localizedDescription)")
        }
    }

    private func fetchChildren(for user: User) async {
        do {
            let fetchedChildren = try await firestoreService.query(
                collection: "children",
                whereField: "parentId",
                isEqualTo: user.id ?? "",
                as: Child.self
            )

            await MainActor.run {
                self.children = fetchedChildren
                self.hasChildProfiles = !fetchedChildren.isEmpty
            }
        } catch {
            print("Error fetching children: \(error.localizedDescription)")
        }
    }
}
