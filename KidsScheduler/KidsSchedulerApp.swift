//
//  KidsSchedulerApp.swift
//  KidsScheduler
//
//  Main app entry point for Kids Scheduler
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

// DEBUG MODE: Set to true to skip authentication and test UI
let DEBUG_MODE = true

@main
struct KidsSchedulerApp: App {

    init() {
        // Configure Firebase
        FirebaseApp.configure()

        // Enable offline persistence for Firestore
        let settings = Firestore.firestore().settings
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        Firestore.firestore().settings = settings
    }

    @StateObject private var authViewModel = AuthenticationViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}
