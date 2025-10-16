//
//  PlaydateService.swift
//  KidsScheduler
//
//  Handles playdate operations with Firestore
//

import Foundation
import FirebaseFirestore

class PlaydateService {
    private let db = Firestore.firestore()
    private let firestoreService = FirestoreService()

    // MARK: - Create Playdate

    func createPlaydate(
        groupId: String,
        createdBy: String,
        createdByParentId: String,
        title: String,
        description: String?,
        activityType: ActivityType,
        startTime: Date,
        endTime: Date,
        location: PlaydateLocation?,
        invitedChildren: [String],
        isRecurring: Bool,
        recurrenceRule: RecurrenceRule?
    ) async throws -> String {
        let playdate = Playdate(
            id: nil,
            groupId: groupId,
            createdBy: createdBy,
            createdByParentId: createdByParentId,
            title: title,
            description: description,
            activityType: activityType,
            startTime: startTime,
            endTime: endTime,
            location: location,
            invitedChildren: invitedChildren,
            rsvps: [],
            status: .pending,
            isRecurring: isRecurring,
            recurrenceRule: recurrenceRule,
            createdAt: Date(),
            updatedAt: Date()
        )

        let playdateId = try await firestoreService.create(collection: "playdates", data: playdate)

        // TODO: Send notifications to invited children's parents
        // TODO: Create approval requests if group requires approval

        return playdateId
    }

    // MARK: - Fetch Playdates

    func fetchPlaydates(for childId: String) async throws -> [Playdate] {
        // Fetch playdates where child is invited
        let playdates: [Playdate] = try await firestoreService.query(
            collection: "playdates",
            whereField: "invitedChildren",
            isEqualTo: childId,
            as: Playdate.self
        )

        return playdates.sorted { $0.startTime < $1.startTime }
    }

    func fetchPlaydatesForGroup(groupId: String) async throws -> [Playdate] {
        let playdates: [Playdate] = try await firestoreService.query(
            collection: "playdates",
            whereField: "groupId",
            isEqualTo: groupId,
            as: Playdate.self
        )

        return playdates.sorted { $0.startTime < $1.startTime }
    }

    // MARK: - Update Playdate

    func updatePlaydate(playdateId: String, playdate: Playdate) async throws {
        var updatedPlaydate = playdate
        updatedPlaydate.updatedAt = Date()

        try await firestoreService.update(
            collection: "playdates",
            documentId: playdateId,
            data: updatedPlaydate
        )
    }

    // MARK: - Delete Playdate

    func deletePlaydate(playdateId: String) async throws {
        try await firestoreService.delete(collection: "playdates", documentId: playdateId)
    }

    // MARK: - RSVP Management

    func respondToPlaydate(
        playdateId: String,
        childId: String,
        parentId: String,
        status: RSVPStatus,
        note: String?
    ) async throws {
        var playdate = try await firestoreService.read(
            collection: "playdates",
            documentId: playdateId,
            as: Playdate.self
        )

        // Remove existing RSVP if any
        playdate.rsvps.removeAll { $0.childId == childId }

        // Add new RSVP
        let rsvp = RSVP(
            childId: childId,
            parentId: parentId,
            status: status,
            respondedAt: Date(),
            note: note
        )
        playdate.rsvps.append(rsvp)

        // Update playdate status based on RSVPs
        updatePlaydateStatus(&playdate)

        try await updatePlaydate(playdateId: playdateId, playdate: playdate)

        // TODO: Send notification to playdate creator
    }

    // MARK: - Helper Methods

    private func updatePlaydateStatus(_ playdate: inout Playdate) {
        let allResponded = playdate.invitedChildren.count == playdate.rsvps.count
        let allAccepted = playdate.rsvps.allSatisfy { $0.status == .accepted }
        let anyDeclined = playdate.rsvps.contains { $0.status == .declined }

        if allResponded && allAccepted {
            playdate.status = .confirmed
        } else if anyDeclined {
            playdate.status = .pending
        } else {
            playdate.status = .pending
        }
    }

    // MARK: - Fetch Playdate Details

    func fetchPlaydate(playdateId: String) async throws -> Playdate {
        return try await firestoreService.read(
            collection: "playdates",
            documentId: playdateId,
            as: Playdate.self
        )
    }

    // MARK: - Cancel Playdate

    func cancelPlaydate(playdateId: String, reason: String?) async throws {
        var playdate = try await fetchPlaydate(playdateId: playdateId)
        playdate.status = .cancelled
        playdate.updatedAt = Date()

        try await updatePlaydate(playdateId: playdateId, playdate: playdate)

        // TODO: Send notifications to all invited children
    }
}

// MARK: - Errors

enum PlaydateError: LocalizedError {
    case invalidTimeRange
    case conflictingPlaydate
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidTimeRange:
            return "End time must be after start time"
        case .conflictingPlaydate:
            return "You already have a playdate at this time"
        case .unauthorized:
            return "You don't have permission to perform this action"
        }
    }
}
