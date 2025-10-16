//
//  FriendInvitationService.swift
//  KidsScheduler
//
//  Handles friend invitations with parent approval workflow
//

import Foundation
import FirebaseFirestore

class FriendInvitationService {
    private let db = Firestore.firestore()
    private let firestoreService = FirestoreService()

    // MARK: - Kid Actions

    /// Step 1: Kid initiates friend request (creates pending invitation)
    func createFriendInvitation(
        fromChildId: String,
        fromChildName: String,
        fromParentId: String,
        fromParentName: String,
        fromParentEmail: String,
        toEmail: String,
        toPhoneNumber: String? = nil,
        message: String? = nil
    ) async throws -> String {
        // Create invitation
        let invitation = FriendInvitation(
            id: nil,
            fromChildId: fromChildId,
            fromChildName: fromChildName,
            fromParentId: fromParentId,
            fromParentName: fromParentName,
            fromParentEmail: fromParentEmail,
            toEmail: toEmail,
            toPhoneNumber: toPhoneNumber,
            toChildId: nil,
            toChildName: nil,
            toParentId: nil,
            toParentName: nil,
            status: .pendingFromParentApproval,
            message: message,
            fromParentApproved: false,
            toParentApproved: false,
            fromParentApprovedAt: nil,
            toParentApprovedAt: nil,
            createdAt: Date(),
            expiresAt: Date().addingTimeInterval(30 * 24 * 60 * 60), // 30 days
            respondedAt: nil
        )

        let invitationId = try await firestoreService.create(
            collection: "friendInvitations",
            data: invitation
        )

        // Create parent approval request
        try await createParentApprovalRequest(
            parentId: fromParentId,
            childId: fromChildId,
            childName: fromChildName,
            invitationId: invitationId,
            requestType: .outgoingFriendRequest,
            otherChildName: "New Friend",
            otherParentName: "Parent",
            otherParentEmail: toEmail,
            message: message
        )

        // TODO: Send push notification to parent
        print("📧 Notification sent to parent \(fromParentId) for approval")

        return invitationId
    }

    /// Step 2a: Recipient accepts invitation (kid response)
    func acceptInvitationAsRecipient(
        invitationId: String,
        childId: String,
        childName: String,
        parentId: String,
        parentName: String
    ) async throws {
        var invitation = try await firestoreService.read(
            collection: "friendInvitations",
            documentId: invitationId,
            as: FriendInvitation.self
        )

        // Update invitation with recipient info
        invitation.toChildId = childId
        invitation.toChildName = childName
        invitation.toParentId = parentId
        invitation.toParentName = parentName
        invitation.status = .pendingToParentApproval
        invitation.respondedAt = Date()

        try await firestoreService.update(
            collection: "friendInvitations",
            documentId: invitationId,
            data: invitation
        )

        // Create parent approval request for recipient's parent
        try await createParentApprovalRequest(
            parentId: parentId,
            childId: childId,
            childName: childName,
            invitationId: invitationId,
            requestType: .incomingFriendRequest,
            otherChildName: invitation.fromChildName,
            otherParentName: invitation.fromParentName,
            otherParentEmail: invitation.fromParentEmail,
            message: invitation.message
        )

        // TODO: Send notification to recipient's parent
        print("📧 Notification sent to parent \(parentId) for approval")
    }

    // MARK: - Parent Actions

    /// Parent approves or denies a friend request
    func respondToApprovalRequest(
        approvalRequestId: String,
        approved: Bool
    ) async throws {
        var request = try await firestoreService.read(
            collection: "parentApprovalRequests",
            documentId: approvalRequestId,
            as: ParentApprovalRequest.self
        )

        request.status = approved ? .approved : .denied
        request.respondedAt = Date()

        try await firestoreService.update(
            collection: "parentApprovalRequests",
            documentId: approvalRequestId,
            data: request
        )

        // Update the invitation
        var invitation = try await firestoreService.read(
            collection: "friendInvitations",
            documentId: request.invitationId,
            as: FriendInvitation.self
        )

        switch request.requestType {
        case .outgoingFriendRequest:
            // Sender's parent responded
            if approved {
                invitation.fromParentApproved = true
                invitation.fromParentApprovedAt = Date()
                invitation.status = .pendingRecipient

                // TODO: Send email invitation to recipient
                try await sendEmailInvitation(invitation: invitation)
            } else {
                invitation.status = .deniedByFromParent
            }

        case .incomingFriendRequest:
            // Recipient's parent responded
            if approved {
                invitation.toParentApproved = true
                invitation.toParentApprovedAt = Date()

                // Check if sender's parent also approved
                if invitation.fromParentApproved {
                    invitation.status = .accepted
                    // Create friendship
                    try await createFriendship(from: invitation)
                }
            } else {
                invitation.status = .deniedByToParent
            }
        }

        try await firestoreService.update(
            collection: "friendInvitations",
            documentId: request.invitationId,
            data: invitation
        )
    }

    /// Parent pauses a friendship
    func pauseFriendship(
        friendshipId: String,
        parentId: String
    ) async throws {
        var friendship = try await firestoreService.read(
            collection: "friendships",
            documentId: friendshipId,
            as: Friendship.self
        )

        if friendship.parent1Id == parentId {
            friendship.isPausedByParent1 = true
        } else if friendship.parent2Id == parentId {
            friendship.isPausedByParent2 = true
        }

        friendship.updatedAt = Date()

        try await firestoreService.update(
            collection: "friendships",
            documentId: friendshipId,
            data: friendship
        )
    }

    /// Parent resumes a friendship
    func resumeFriendship(
        friendshipId: String,
        parentId: String
    ) async throws {
        var friendship = try await firestoreService.read(
            collection: "friendships",
            documentId: friendshipId,
            as: Friendship.self
        )

        if friendship.parent1Id == parentId {
            friendship.isPausedByParent1 = false
        } else if friendship.parent2Id == parentId {
            friendship.isPausedByParent2 = false
        }

        friendship.updatedAt = Date()

        try await firestoreService.update(
            collection: "friendships",
            documentId: friendshipId,
            data: friendship
        )
    }

    /// Parent blocks a friendship
    func blockFriendship(
        friendshipId: String,
        parentId: String
    ) async throws {
        var friendship = try await firestoreService.read(
            collection: "friendships",
            documentId: friendshipId,
            as: Friendship.self
        )

        friendship.status = .blocked
        friendship.updatedAt = Date()

        try await firestoreService.update(
            collection: "friendships",
            documentId: friendshipId,
            data: friendship
        )
    }

    // MARK: - Fetch Methods

    /// Get pending approval requests for a parent
    func fetchPendingApprovalRequests(for parentId: String) async throws -> [ParentApprovalRequest] {
        let requests: [ParentApprovalRequest] = try await firestoreService.query(
            collection: "parentApprovalRequests",
            whereField: "parentId",
            isEqualTo: parentId,
            as: ParentApprovalRequest.self
        )

        return requests.filter { $0.status == .pending && $0.expiresAt > Date() }
            .sorted { $0.createdAt > $1.createdAt }
    }

    /// Get all friendships for a child
    func fetchFriendships(for childId: String) async throws -> [Friendship] {
        // Query where child is child1
        let friendships1: [Friendship] = try await firestoreService.query(
            collection: "friendships",
            whereField: "child1Id",
            isEqualTo: childId,
            as: Friendship.self
        )

        // Query where child is child2
        let friendships2: [Friendship] = try await firestoreService.query(
            collection: "friendships",
            whereField: "child2Id",
            isEqualTo: childId,
            as: Friendship.self
        )

        return (friendships1 + friendships2).sorted { $0.createdAt > $1.createdAt }
    }

    /// Get friends list for a child (only active friendships)
    func fetchFriends(for childId: String) async throws -> [Child] {
        let friendships = try await fetchFriendships(for: childId)

        var friends: [Child] = []
        for friendship in friendships where friendship.isActive {
            let friendId = friendship.child1Id == childId ? friendship.child2Id : friendship.child1Id
            let friend = try await firestoreService.read(
                collection: "children",
                documentId: friendId,
                as: Child.self
            )
            friends.append(friend)
        }

        return friends
    }

    /// Get pending invitations sent by a child
    func fetchSentInvitations(for childId: String) async throws -> [FriendInvitation] {
        let invitations: [FriendInvitation] = try await firestoreService.query(
            collection: "friendInvitations",
            whereField: "fromChildId",
            isEqualTo: childId,
            as: FriendInvitation.self
        )

        return invitations.filter {
            $0.status != .accepted && $0.status != .declined && $0.expiresAt > Date()
        }
    }

    /// Get pending invitations received by email (before account created)
    func fetchPendingInvitationsByEmail(email: String) async throws -> [FriendInvitation] {
        let invitations: [FriendInvitation] = try await firestoreService.query(
            collection: "friendInvitations",
            whereField: "toEmail",
            isEqualTo: email,
            as: FriendInvitation.self
        )

        return invitations.filter {
            $0.status == .pendingRecipient && $0.expiresAt > Date()
        }
    }

    // MARK: - Helper Methods

    private func createFriendship(from invitation: FriendInvitation) async throws {
        guard let child1Id = invitation.toChildId,
              let child1Name = invitation.toChildName,
              let parent1Id = invitation.toParentId else {
            throw FriendInvitationError.missingRecipientInfo
        }

        let friendship = Friendship(
            id: nil,
            child1Id: invitation.fromChildId,
            child2Id: child1Id,
            child1Name: invitation.fromChildName,
            child2Name: child1Name,
            parent1Id: invitation.fromParentId,
            parent2Id: parent1Id,
            status: .active,
            createdAt: Date(),
            updatedAt: Date(),
            isPausedByParent1: false,
            isPausedByParent2: false
        )

        let friendshipId = try await firestoreService.create(
            collection: "friendships",
            data: friendship
        )

        print("✅ Friendship created: \(friendshipId)")

        // TODO: Send notifications to both kids
    }

    private func createParentApprovalRequest(
        parentId: String,
        childId: String,
        childName: String,
        invitationId: String,
        requestType: ApprovalRequestType,
        otherChildName: String,
        otherParentName: String,
        otherParentEmail: String,
        message: String?
    ) async throws {
        let request = ParentApprovalRequest(
            id: nil,
            parentId: parentId,
            childId: childId,
            childName: childName,
            requestType: requestType,
            invitationId: invitationId,
            otherChildName: otherChildName,
            otherParentName: otherParentName,
            otherParentEmail: otherParentEmail,
            message: message,
            status: .pending,
            createdAt: Date(),
            respondedAt: nil,
            expiresAt: Date().addingTimeInterval(30 * 24 * 60 * 60)
        )

        _ = try await firestoreService.create(
            collection: "parentApprovalRequests",
            data: request
        )
    }

    private func sendEmailInvitation(invitation: FriendInvitation) async throws {
        // TODO: Implement email sending via SendGrid/Firebase Functions
        print("📧 Sending email invitation to: \(invitation.toEmail)")
        print("   From: \(invitation.fromChildName)")
        print("   Message: \(invitation.message ?? "No message")")
    }
}

// MARK: - Errors

enum FriendInvitationError: LocalizedError {
    case missingRecipientInfo
    case alreadyFriends
    case invitationExpired
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .missingRecipientInfo:
            return "Recipient information is missing"
        case .alreadyFriends:
            return "You are already friends with this person"
        case .invitationExpired:
            return "This invitation has expired"
        case .unauthorized:
            return "You don't have permission to perform this action"
        }
    }
}
