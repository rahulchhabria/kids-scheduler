//
//  MainTabView.swift
//  KidsScheduler
//
//  Main tab navigation for the app
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showCreatePlaydate = false

    var body: some View {
        TabView(selection: $selectedTab) {
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(0)

            GroupsView()
                .tabItem {
                    Label("Groups", systemImage: "person.3.fill")
                }
                .tag(1)

            // Create button - opens sheet instead of navigation
            Color.clear
                .tabItem {
                    Label("Create", systemImage: "plus.circle.fill")
                }
                .tag(2)

            NotificationsView()
                .tabItem {
                    Label("Invites", systemImage: "bell.fill")
                }
                .tag(3)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle.fill")
                }
                .tag(4)
        }
        .accentColor(.blue)
        .onChange(of: selectedTab) { newValue in
            if newValue == 2 {
                showCreatePlaydate = true
                // Reset to previous tab after opening sheet
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    selectedTab = 0
                }
            }
        }
        .sheet(isPresented: $showCreatePlaydate) {
            CreatePlaydateView()
        }
    }
}

// Placeholder views - to be implemented later
struct NotificationsView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.gray.opacity(0.5))

                Text("No New Invites")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text("Playdate invitations will appear here")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Invites")
        }
    }
}

struct ProfileView: View {
    @StateObject private var badgeViewModel = BadgeCountViewModel()

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account")) {
                    HStack {
                        Text("👤")
                            .font(.system(size: 40))
                        VStack(alignment: .leading) {
                            Text("Current Child")
                                .font(.headline)
                            Text("DEBUG MODE")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Parent Dashboard Section
                Section(header: Text("For Parents")) {
                    NavigationLink(destination: ParentApprovalDashboardView()) {
                        HStack {
                            Label("Parent Dashboard", systemImage: "shield.checkered")
                                .font(.body)

                            Spacer()

                            if badgeViewModel.pendingCount > 0 {
                                Text("\(badgeViewModel.pendingCount)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.red)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }

                Section(header: Text("Settings")) {
                    NavigationLink(destination: Text("Notifications Settings")) {
                        Label("Notifications", systemImage: "bell")
                    }
                    NavigationLink(destination: Text("Privacy Settings")) {
                        Label("Privacy", systemImage: "hand.raised")
                    }
                    NavigationLink(destination: Text("About")) {
                        Label("About", systemImage: "info.circle")
                    }
                }

                Section {
                    Button(action: {}) {
                        Label("Sign Out", systemImage: "arrow.right.square")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Profile")
            .task {
                await badgeViewModel.loadPendingCount()
            }
            .refreshable {
                await badgeViewModel.loadPendingCount()
            }
        }
    }
}

// MARK: - Badge Count ViewModel

@MainActor
class BadgeCountViewModel: ObservableObject {
    @Published var pendingCount = 0

    private let invitationService = FriendInvitationService()

    func loadPendingCount() async {
        do {
            // TODO: Get actual parent ID from auth context
            let parentId = "mock-parent-id"

            let requests = try await invitationService.fetchPendingApprovalRequests(for: parentId)
            pendingCount = requests.count
        } catch {
            print("Failed to load pending count: \(error)")
            pendingCount = 0
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
