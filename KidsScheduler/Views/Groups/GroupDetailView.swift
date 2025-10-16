//
//  GroupDetailView.swift
//  KidsScheduler
//
//  Detailed view of a single group with members and settings
//

import SwiftUI

struct GroupDetailView: View {
    let group: FriendGroup
    @ObservedObject var viewModel: GroupViewModel

    @State private var showShareSheet = false
    @State private var showLeaveConfirmation = false
    @State private var members: [Child] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Group Header
                GroupHeaderSection(group: group, onShare: { showShareSheet = true })

                // Members Section
                MembersSection(members: members, memberCount: group.members.count)

                // Settings Section
                SettingsSection(settings: group.settings)

                // Leave Group Button
                Button(action: { showLeaveConfirmation = true }) {
                    Label("Leave Group", systemImage: "rectangle.portrait.and.arrow.right")
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                }
                .padding(.top, 20)
            }
            .padding()
        }
        .navigationTitle(group.groupName)
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showShareSheet) {
            ShareInviteView(inviteCode: group.inviteCode, groupName: group.groupName)
        }
        .alert("Leave Group?", isPresented: $showLeaveConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Leave", role: .destructive) {
                leaveGroup()
            }
        } message: {
            Text("Are you sure you want to leave \(group.groupName)? You'll need an invite code to rejoin.")
        }
        .task {
            // Load members when view appears
            if let groupId = group.id {
                members = await viewModel.fetchGroupMembers(groupId: groupId)
            }
        }
    }

    private func leaveGroup() {
        Task {
            // TODO: Get actual child ID from auth context
            let childId = "mock-child-id"

            if let groupId = group.id {
                await viewModel.leaveGroup(groupId: groupId, childId: childId)
            }
        }
    }
}

// MARK: - Group Header Section

struct GroupHeaderSection: View {
    let group: FriendGroup
    let onShare: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Group Icon
            Circle()
                .fill(groupColor.opacity(0.2))
                .frame(width: 120, height: 120)
                .overlay(
                    Text(group.groupName.prefix(1).uppercased())
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(groupColor)
                )

            // Group Name
            Text(group.groupName)
                .font(.title)
                .fontWeight(.bold)

            // Invite Code
            VStack(spacing: 8) {
                HStack {
                    Text("Invite Code:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(group.inviteCode)
                        .font(.system(.title3, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }

                Button(action: onShare) {
                    Label("Share Invite Code", systemImage: "square.and.arrow.up")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .padding(.vertical)
    }

    private var groupColor: Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .red]
        let index = abs(group.groupName.hashValue) % colors.count
        return colors[index]
    }
}

// MARK: - Members Section

struct MembersSection: View {
    let members: [Child]
    let memberCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Members")
                    .font(.headline)

                Spacer()

                Text("\(memberCount)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            if members.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                    Text("Loading members...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.vertical)
            } else {
                VStack(spacing: 12) {
                    ForEach(members) { member in
                        MemberRow(member: member)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct MemberRow: View {
    let member: Child

    var body: some View {
        HStack(spacing: 12) {
            Text(member.avatarEmoji)
                .font(.system(size: 40))

            VStack(alignment: .leading, spacing: 4) {
                Text(member.childName)
                    .font(.headline)

                Text("Age \(member.age)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
}

// MARK: - Settings Section

struct SettingsSection: View {
    let settings: GroupSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Group Settings")
                .font(.headline)

            VStack(spacing: 16) {
                SettingRow(
                    icon: "checkmark.shield.fill",
                    title: "Parent Approval",
                    isEnabled: settings.requiresApproval,
                    description: "Playdates require parent approval"
                )

                SettingRow(
                    icon: "calendar.badge.plus",
                    title: "Playdate Creation",
                    isEnabled: settings.allowPlaydateCreation,
                    description: "Members can create playdates"
                )

                SettingRow(
                    icon: "person.badge.plus",
                    title: "Member Invites",
                    isEnabled: settings.allowMemberInvites,
                    description: "Members can invite new friends"
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    let isEnabled: Bool
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(isEnabled ? .blue : .gray)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: isEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.title3)
                .foregroundColor(isEnabled ? .green : .gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
}

// MARK: - Share Invite View

struct ShareInviteView: View {
    @Environment(\.dismiss) var dismiss
    let inviteCode: String
    let groupName: String

    @State private var copied = false

    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Spacer()

                Image(systemName: "square.and.arrow.up.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)

                VStack(spacing: 12) {
                    Text("Share Invite Code")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Share this code with friends to invite them to \(groupName)")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                // Invite Code Display
                VStack(spacing: 16) {
                    Text(inviteCode)
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)

                    Button(action: copyToClipboard) {
                        Label(copied ? "Copied!" : "Copy Code", systemImage: copied ? "checkmark" : "doc.on.doc")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: 400)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func copyToClipboard() {
        UIPasteboard.general.string = inviteCode
        copied = true

        // Reset after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            copied = false
        }
    }
}

struct GroupDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GroupDetailView(
                group: FriendGroup.mockGroups[0],
                viewModel: GroupViewModel()
            )
        }
        .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
