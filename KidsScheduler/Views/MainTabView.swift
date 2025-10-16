//
//  MainTabView.swift
//  KidsScheduler
//
//  Main tab navigation for the app
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

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

            CreatePlaydateView()
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
    }
}

// Placeholder views - to be implemented
struct CalendarView: View {
    var body: some View {
        NavigationView {
            Text("Calendar View")
                .navigationTitle("My Calendar")
        }
    }
}

struct GroupsView: View {
    var body: some View {
        NavigationView {
            Text("Groups View")
                .navigationTitle("My Groups")
        }
    }
}

struct CreatePlaydateView: View {
    var body: some View {
        NavigationView {
            Text("Create Playdate View")
                .navigationTitle("Create Playdate")
        }
    }
}

struct NotificationsView: View {
    var body: some View {
        NavigationView {
            Text("Notifications View")
                .navigationTitle("Invites")
        }
    }
}

struct ProfileView: View {
    var body: some View {
        NavigationView {
            Text("Profile View")
                .navigationTitle("Profile")
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
