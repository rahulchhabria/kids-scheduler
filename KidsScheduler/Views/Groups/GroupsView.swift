//
//  GroupsView.swift
//  KidsScheduler
//
//  Main groups view showing all groups for current child
//

import SwiftUI

struct GroupsView: View {
    @StateObject private var viewModel = GroupViewModel()
    @State private var showCreateGroup = false
    @State private var showJoinGroup = false
    @State private var showInviteFriend = false
    @State private var selectedChild: Child?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.groups.isEmpty {
                    EmptyGroupsView(
                        onCreateGroup: { showCreateGroup = true },
                        onJoinGroup: { showJoinGroup = true }
                    )
                } else {
                    GroupsListView(
                        groups: viewModel.groups,
                        viewModel: viewModel
                    )
                }
            }
            .navigationTitle("My Groups")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showInviteFriend = true }) {
                        Label("Invite Friend", systemImage: "person.badge.plus")
                            .font(.headline)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showCreateGroup = true }) {
                            Label("Create Group", systemImage: "plus.circle")
                        }
                        Button(action: { showJoinGroup = true }) {
                            Label("Join with Code", systemImage: "number.square")
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showCreateGroup) {
                CreateGroupView(viewModel: viewModel, selectedChild: selectedChild)
            }
            .sheet(isPresented: $showJoinGroup) {
                JoinGroupView(viewModel: viewModel, selectedChild: selectedChild)
            }
            .sheet(isPresented: $showInviteFriend) {
                InviteFriendView()
            }
            .alert("Success", isPresented: .constant(viewModel.successMessage != nil)) {
                Button("OK") {
                    viewModel.successMessage = nil
                }
            } message: {
                if let message = viewModel.successMessage {
                    Text(message)
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let message = viewModel.errorMessage {
                    Text(message)
                }
            }
        }
        .onAppear {
            // TODO: Get current child from auth context
            // For now, using mock data in debug mode
            if DEBUG_MODE {
                viewModel.groups = FriendGroup.mockGroups
            }
        }
    }
}

// MARK: - Empty State

struct EmptyGroupsView: View {
    let onCreateGroup: () -> Void
    let onJoinGroup: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.5))

            VStack(spacing: 8) {
                Text("No Groups Yet")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Create a group or join one with an invite code")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            VStack(spacing: 12) {
                Button(action: onCreateGroup) {
                    Label("Create a Group", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: 300)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }

                Button(action: onJoinGroup) {
                    Label("Join with Code", systemImage: "number.square.fill")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: 300)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
}

// MARK: - Groups List

struct GroupsListView: View {
    let groups: [FriendGroup]
    @ObservedObject var viewModel: GroupViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(groups) { group in
                    NavigationLink(destination: GroupDetailView(group: group, viewModel: viewModel)) {
                        GroupCardView(group: group)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
    }
}

// MARK: - Group Card

struct GroupCardView: View {
    let group: FriendGroup

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Group Icon
                Circle()
                    .fill(groupColor.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text(group.groupName.prefix(1).uppercased())
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(groupColor)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(group.groupName)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .font(.caption)
                        Text("\(group.members.count) members")
                            .font(.subheadline)
                    }
                    .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }

            Divider()

            HStack {
                Label("Invite Code: \(group.inviteCode)", systemImage: "number.square")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                if group.settings.requiresApproval {
                    Label("Approval Required", systemImage: "checkmark.shield")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }

    private var groupColor: Color {
        // Generate a color based on group name
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .red]
        let index = abs(group.groupName.hashValue) % colors.count
        return colors[index]
    }
}

// MARK: - Mock Data

extension FriendGroup {
    static var mockGroups: [FriendGroup] {
        [
            FriendGroup(
                id: "group1",
                groupName: "Soccer Team",
                createdBy: "child1",
                members: ["child1", "child2", "child3", "child4"],
                inviteCode: "SOCCER",
                settings: GroupSettings(
                    requiresApproval: true,
                    allowPlaydateCreation: true,
                    allowMemberInvites: true
                ),
                createdAt: Date(),
                updatedAt: Date()
            ),
            FriendGroup(
                id: "group2",
                groupName: "Art Class Friends",
                createdBy: "child1",
                members: ["child1", "child2"],
                inviteCode: "ART123",
                settings: GroupSettings(
                    requiresApproval: false,
                    allowPlaydateCreation: true,
                    allowMemberInvites: true
                ),
                createdAt: Date().addingTimeInterval(-86400 * 7),
                updatedAt: Date()
            ),
            FriendGroup(
                id: "group3",
                groupName: "Gaming Squad",
                createdBy: "child2",
                members: ["child1", "child2", "child3", "child4", "child5"],
                inviteCode: "GAME99",
                settings: GroupSettings(
                    requiresApproval: true,
                    allowPlaydateCreation: true,
                    allowMemberInvites: false
                ),
                createdAt: Date().addingTimeInterval(-86400 * 14),
                updatedAt: Date()
            )
        ]
    }
}

struct GroupsView_Previews: PreviewProvider {
    static var previews: some View {
        GroupsView()
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
