//
//  AuthenticationService.swift
//  KidsScheduler
//
//  Handles Google OAuth and Firebase Authentication
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import GoogleSignIn

class AuthenticationService: ObservableObject {
    @Published var currentUser: User?
    @Published var errorMessage: String?

    private let auth = Auth.auth()

    init() {
        checkAuthStatus()
    }

    func checkAuthStatus() {
        if let firebaseUser = auth.currentUser {
            // Fetch user from Firestore
            fetchUser(userId: firebaseUser.uid)
        }
    }

    func signInWithGoogle(presentingViewController: UIViewController) async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.missingClientID
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)

        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.missingIDToken
        }

        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )

        let authResult = try await auth.signIn(with: credential)

        // Create or fetch user profile
        try await createOrFetchUserProfile(firebaseUser: authResult.user)
    }

    func signOut() throws {
        try auth.signOut()
        GIDSignIn.sharedInstance.signOut()
        currentUser = nil
    }

    private func createOrFetchUserProfile(firebaseUser: FirebaseAuth.User) async throws {
        // Check if user exists in Firestore
        let userRef = Firestore.firestore().collection("users").document(firebaseUser.uid)
        let document = try await userRef.getDocument()

        if document.exists {
            // Fetch existing user
            let user = try document.data(as: User.self)
            await MainActor.run {
                self.currentUser = user
            }
        } else {
            // Create new user
            let newUser = User(
                id: firebaseUser.uid,
                email: firebaseUser.email ?? "",
                parentName: firebaseUser.displayName ?? "",
                linkedChildren: [],
                createdAt: Date(),
                updatedAt: Date()
            )

            try userRef.setData(from: newUser)

            await MainActor.run {
                self.currentUser = newUser
            }
        }
    }

    private func fetchUser(userId: String) {
        let userRef = Firestore.firestore().collection("users").document(userId)

        userRef.getDocument { document, error in
            if let error = error {
                // Handle offline mode gracefully - don't show error to user
                print("⚠️ Firestore offline or error: \(error.localizedDescription)")
                // User will remain unauthenticated, which is fine
                return
            }

            if let document = document, document.exists {
                do {
                    let user = try document.data(as: User.self)
                    DispatchQueue.main.async {
                        self.currentUser = user
                    }
                } catch {
                    self.errorMessage = "Failed to decode user: \(error.localizedDescription)"
                }
            } else {
                print("⚠️ User document doesn't exist for userId: \(userId)")
            }
        }
    }
}

enum AuthError: LocalizedError {
    case missingClientID
    case missingIDToken

    var errorDescription: String? {
        switch self {
        case .missingClientID:
            return "Missing Google Client ID"
        case .missingIDToken:
            return "Missing ID Token from Google Sign In"
        }
    }
}
