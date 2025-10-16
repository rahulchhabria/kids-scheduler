//
//  GroupService.swift
//  KidsScheduler
//
//  Handles group operations with Firestore
//

import Foundation
import FirebaseFirestore

class GroupService {
    private let db = Firestore.firestore()
    private let firestoreService = FirestoreService()

    // MARK: - Create Group

    func createGroup(
        groupName: String,
        createdBy: String,
        members: [String],
        settings: GroupSettings
    ) async throws -> String {
        let inviteCode = generateInviteCode()

        let group = FriendGroup(
            id: nil,
            groupName: groupName,
            createdBy: createdBy,
            members: members,
            inviteCode: inviteCode,
            settings: settings,
            createdAt: Date(),
            updatedAt: Date()
        )

        let groupId = try await firestoreService.create(collection: "groups", data: group)

        // Add group to all members' child profiles
        for memberId in members {
            try await addGroupToChild(childId: memberId, groupId: groupId)
        }

        return groupId
    }

    // MARK: - Join Group

    func joinGroup(inviteCode: String, childId: String) async throws -> FriendGroup {
        // Find group by invite code
        let groups: [FriendGroup] = try await firestoreService.query(
            collection: "groups",
            whereField: "inviteCode",
            isEqualTo: inviteCode,
            as: FriendGroup.self
        )

        guard let group = groups.first, let groupId = group.id else {
            throw GroupError.invalidInviteCode
        }

        // Check if child is already a member
        if group.members.contains(childId) {
            throw GroupError.alreadyMember
        }

        // Add child to group members
        var updatedGroup = group
        updatedGroup.members.append(childId)
        updatedGroup.updatedAt = Date()

        try await firestoreService.update(
            collection: "groups",
            documentId: groupId,
            data: updatedGroup
        )

        // Add group to child's profile
        try await addGroupToChild(childId: childId, groupId: groupId)

        return updatedGroup
    }

    // MARK: - Fetch Groups

    func fetchGroups(for childId: String) async throws -> [FriendGroup] {
        // Get all groups where child is a member
        let groups: [FriendGroup] = try await firestoreService.query(
            collection: "groups",
            whereField: "members",
            isEqualTo: childId,
            as: FriendGroup.self
        )

        return groups.sorted { $0.createdAt > $1.createdAt }
    }

    // MARK: - Fetch Group Details

    func fetchGroup(groupId: String) async throws -> FriendGroup {
        return try await firestoreService.read(
            collection: "groups",
            documentId: groupId,
            as: FriendGroup.self
        )
    }

    // MARK: - Update Group

    func updateGroup(groupId: String, group: FriendGroup) async throws {
        var updatedGroup = group
        updatedGroup.updatedAt = Date()

        try await firestoreService.update(
            collection: "groups",
            documentId: groupId,
            data: updatedGroup
        )
    }

    // MARK: - Leave Group

    func leaveGroup(groupId: String, childId: String) async throws {
        var group = try await fetchGroup(groupId: groupId)

        // Remove child from members
        group.members.removeAll { $0 == childId }
        group.updatedAt = Date()

        if group.members.isEmpty {
            // Delete group if no members left
            try await firestoreService.delete(collection: "groups", documentId: groupId)
        } else {
            // Update group
            try await firestoreService.update(
                collection: "groups",
                documentId: groupId,
                data: group
            )
        }

        // Remove group from child's profile
        try await removeGroupFromChild(childId: childId, groupId: groupId)
    }

    // MARK: - Helper Methods

    private func addGroupToChild(childId: String, groupId: String) async throws {
        let childRef = db.collection("children").document(childId)
        try await childRef.updateData([
            "groups": FieldValue.arrayUnion([groupId])
        ])
    }

    private func removeGroupFromChild(childId: String, groupId: String) async throws {
        let childRef = db.collection("children").document(childId)
        try await childRef.updateData([
            "groups": FieldValue.arrayRemove([groupId])
        ])
    }

    private func generateInviteCode() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in characters.randomElement()! })
    }
}

// MARK: - Errors

enum GroupError: LocalizedError {
    case invalidInviteCode
    case alreadyMember
    case notMember

    var errorDescription: String? {
        switch self {
        case .invalidInviteCode:
            return "Invalid invite code. Please check and try again."
        case .alreadyMember:
            return "You're already a member of this group!"
        case .notMember:
            return "You're not a member of this group."
        }
    }
}
