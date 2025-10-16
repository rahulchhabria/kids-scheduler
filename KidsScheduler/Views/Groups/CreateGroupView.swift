//
//  CreateGroupView.swift
//  KidsScheduler
//
//  Form for creating a new group
//

import SwiftUI

struct CreateGroupView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: GroupViewModel
    let selectedChild: Child?

    @State private var groupName = ""
    @State private var requiresApproval = true
    @State private var allowPlaydateCreation = true
    @State private var allowMemberInvites = true

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Group Information")) {
                    TextField("Group Name", text: $groupName)
                        .font(.body)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Group Icon")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        HStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Text(groupName.isEmpty ? "?" : groupName.prefix(1).uppercased())
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                )

                            Spacer()
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section(header: Text("Group Settings")) {
                    Toggle("Require Parent Approval", isOn: $requiresApproval)
                    Toggle("Allow Playdate Creation", isOn: $allowPlaydateCreation)
                    Toggle("Allow Member Invites", isOn: $allowMemberInvites)
                }

                Section(header: Text("About Group Settings")) {
                    VStack(alignment: .leading, spacing: 12) {
                        SettingExplanationRow(
                            icon: "checkmark.shield.fill",
                            title: "Parent Approval",
                            description: "New playdates require parent approval before confirmation"
                        )

                        SettingExplanationRow(
                            icon: "calendar.badge.plus",
                            title: "Playdate Creation",
                            description: "Members can create and invite others to playdates"
                        )

                        SettingExplanationRow(
                            icon: "person.badge.plus",
                            title: "Member Invites",
                            description: "Members can invite new friends to join the group"
                        )
                    }
                }

                Section {
                    Button(action: createGroup) {
                        HStack {
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Text("Create Group")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(groupName.isEmpty || viewModel.isLoading)
                }
            }
            .navigationTitle("Create Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func createGroup() {
        Task {
            // TODO: Get actual child ID from auth context
            let childId = selectedChild?.id ?? "mock-child-id"

            let settings = GroupSettings(
                requiresApproval: requiresApproval,
                allowPlaydateCreation: allowPlaydateCreation,
                allowMemberInvites: allowMemberInvites
            )

            await viewModel.createGroup(
                groupName: groupName,
                childId: childId,
                settings: settings
            )

            if viewModel.successMessage != nil {
                dismiss()
            }
        }
    }
}

// MARK: - Setting Explanation Row

struct SettingExplanationRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct CreateGroupView_Previews: PreviewProvider {
    static var previews: some View {
        CreateGroupView(viewModel: GroupViewModel(), selectedChild: nil)
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
