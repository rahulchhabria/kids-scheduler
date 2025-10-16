//
//  GroupViewModel.swift
//  KidsScheduler
//
//  Manages group data and operations
//

import Foundation
import SwiftUI

@MainActor
class GroupViewModel: ObservableObject {
    @Published var groups: [FriendGroup] = []
    @Published var selectedGroup: FriendGroup?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let groupService = GroupService()
    private let firestoreService = FirestoreService()

    // MARK: - Fetch Groups

    func fetchGroups(for childId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            groups = try await groupService.fetchGroups(for: childId)
            isLoading = false
        } catch {
            errorMessage = "Failed to load groups: \(error.localizedDescription)"
            isLoading = false
        }
    }

    // MARK: - Create Group

    func createGroup(
        groupName: String,
        childId: String,
        settings: GroupSettings = GroupSettings()
    ) async {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            let groupId = try await groupService.createGroup(
                groupName: groupName,
                createdBy: childId,
                members: [childId],
                settings: settings
            )

            // Fetch updated groups
            await fetchGroups(for: childId)

            successMessage = "Group created successfully!"
            isLoading = false
        } catch {
            errorMessage = "Failed to create group: \(error.localizedDescription)"
            isLoading = false
        }
    }

    // MARK: - Join Group

    func joinGroup(inviteCode: String, childId: String) async {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            let group = try await groupService.joinGroup(
                inviteCode: inviteCode.uppercased(),
                childId: childId
            )

            // Fetch updated groups
            await fetchGroups(for: childId)

            successMessage = "Joined \(group.groupName) successfully!"
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    // MARK: - Leave Group

    func leaveGroup(groupId: String, childId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            try await groupService.leaveGroup(groupId: groupId, childId: childId)

            // Remove from local list
            groups.removeAll { $0.id == groupId }

            successMessage = "Left group successfully"
            isLoading = false
        } catch {
            errorMessage = "Failed to leave group: \(error.localizedDescription)"
            isLoading = false
        }
    }

    // MARK: - Fetch Group Members

    func fetchGroupMembers(groupId: String) async -> [Child] {
        do {
            guard let group = groups.first(where: { $0.id == groupId }) else {
                return []
            }

            var members: [Child] = []
            for memberId in group.members {
                let child = try await firestoreService.read(
                    collection: "children",
                    documentId: memberId,
                    as: Child.self
                )
                members.append(child)
            }

            return members
        } catch {
            errorMessage = "Failed to fetch members: \(error.localizedDescription)"
            return []
        }
    }
}
