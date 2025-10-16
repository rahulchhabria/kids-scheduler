//
//  FriendInvitation.swift
//  KidsScheduler
//
//  Model for friend invitations with parent approval workflow
//

import Foundation
import FirebaseFirestore

// MARK: - Friend Invitation

struct FriendInvitation: Identifiable, Codable {
    @DocumentID var id: String?
    var fromChildId: String
    var fromChildName: String
    var fromParentId: String
    var fromParentName: String
    var fromParentEmail: String

    var toEmail: String // Email to send invitation to
    var toPhoneNumber: String? // Optional phone number

    var toChildId: String? // Populated when recipient accepts
    var toChildName: String?
    var toParentId: String? // Populated when recipient accepts
    var toParentName: String?

    var status: InvitationStatus
    var message: String? // Optional message from kid

    // Approval workflow
    var fromParentApproved: Bool // Sender's parent approval
    var toParentApproved: Bool // Recipient's parent approval
    var fromParentApprovedAt: Date?
    var toParentApprovedAt: Date?

    var createdAt: Date
    var expiresAt: Date // Invitations expire after 30 days
    var respondedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case fromChildId, fromChildName, fromParentId, fromParentName, fromParentEmail
        case toEmail, toPhoneNumber
        case toChildId, toChildName, toParentId, toParentName
        case status, message
        case fromParentApproved, toParentApproved
        case fromParentApprovedAt, toParentApprovedAt
        case createdAt, expiresAt, respondedAt
    }
}

enum InvitationStatus: String, Codable {
    case pendingFromParentApproval // Waiting for sender's parent to approve
    case pendingRecipient // Sent to recipient, waiting for them to accept
    case pendingToParentApproval // Recipient accepted, waiting for their parent to approve
    case accepted // Both parents approved, friendship established
    case declined // Recipient declined
    case deniedByFromParent // Sender's parent denied
    case deniedByToParent // Recipient's parent denied
    case expired // Invitation expired
    case cancelled // Sender cancelled
}

// MARK: - Friendship

struct Friendship: Identifiable, Codable {
    @DocumentID var id: String?
    var child1Id: String
    var child2Id: String
    var child1Name: String
    var child2Name: String

    var parent1Id: String
    var parent2Id: String

    var status: FriendshipStatus
    var createdAt: Date
    var updatedAt: Date

    // Can be paused by either parent
    var isPausedByParent1: Bool
    var isPausedByParent2: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case child1Id, child2Id, child1Name, child2Name
        case parent1Id, parent2Id
        case status
        case createdAt, updatedAt
        case isPausedByParent1, isPausedByParent2
    }

    // Check if friendship is active
    var isActive: Bool {
        status == .active && !isPausedByParent1 && !isPausedByParent2
    }
}

enum FriendshipStatus: String, Codable {
    case active
    case suspended // Temporarily suspended by parent
    case blocked // Blocked by parent
}

// MARK: - Parent Approval Request

struct ParentApprovalRequest: Identifiable, Codable {
    @DocumentID var id: String?
    var parentId: String
    var childId: String
    var childName: String

    var requestType: ApprovalRequestType
    var invitationId: String

    var otherChildName: String
    var otherParentName: String
    var otherParentEmail: String

    var message: String?
    var status: ApprovalStatus

    var createdAt: Date
    var respondedAt: Date?
    var expiresAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case parentId, childId, childName
        case requestType, invitationId
        case otherChildName, otherParentName, otherParentEmail
        case message, status
        case createdAt, respondedAt, expiresAt
    }
}

enum ApprovalRequestType: String, Codable {
    case outgoingFriendRequest // Kid wants to send friend request
    case incomingFriendRequest // Kid received friend request
}

enum ApprovalStatus: String, Codable {
    case pending
    case approved
    case denied
    case expired
}

// MARK: - Preview Data

extension FriendInvitation {
    static var preview: FriendInvitation {
        FriendInvitation(
            id: "inv1",
            fromChildId: "child1",
            fromChildName: "Alex",
            fromParentId: "parent1",
            fromParentName: "John Smith",
            fromParentEmail: "john@example.com",
            toEmail: "jane@example.com",
            toPhoneNumber: nil,
            toChildId: nil,
            toChildName: nil,
            toParentId: nil,
            toParentName: nil,
            status: .pendingFromParentApproval,
            message: "I met Sam at soccer practice!",
            fromParentApproved: false,
            toParentApproved: false,
            fromParentApprovedAt: nil,
            toParentApprovedAt: nil,
            createdAt: Date(),
            expiresAt: Date().addingTimeInterval(30 * 24 * 60 * 60),
            respondedAt: nil
        )
    }
}

extension Friendship {
    static var preview: Friendship {
        Friendship(
            id: "friend1",
            child1Id: "child1",
            child2Id: "child2",
            child1Name: "Alex",
            child2Name: "Sam",
            parent1Id: "parent1",
            parent2Id: "parent2",
            status: .active,
            createdAt: Date(),
            updatedAt: Date(),
            isPausedByParent1: false,
            isPausedByParent2: false
        )
    }
}
