//
//  Playdate.swift
//  KidsScheduler
//
//  Playdate event model
//

import Foundation
import FirebaseFirestore

struct Playdate: Identifiable, Codable {
    @DocumentID var id: String?
    var groupId: String
    var createdBy: String // Child ID
    var title: String
    var description: String?
    var startTime: Date
    var endTime: Date
    var location: PlaydateLocation?
    var invitedChildren: [String] // Array of child IDs
    var rsvps: [RSVP]
    var status: PlaydateStatus
    var isRecurring: Bool
    var recurrenceRule: RecurrenceRule?
    var createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case groupId
        case createdBy
        case title
        case description
        case startTime
        case endTime
        case location
        case invitedChildren
        case rsvps
        case status
        case isRecurring
        case recurrenceRule
        case createdAt
        case updatedAt
    }
}

struct PlaydateLocation: Codable {
    var name: String
    var address: String?
    var latitude: Double?
    var longitude: Double?
}

struct RSVP: Identifiable, Codable {
    var id: String { childId }
    var childId: String
    var status: RSVPStatus
    var parentApproved: Bool
    var respondedAt: Date?
    var approvedAt: Date?
}

enum RSVPStatus: String, Codable {
    case pending
    case accepted
    case declined
    case maybe
}

enum PlaydateStatus: String, Codable {
    case pending
    case confirmed
    case cancelled
    case completed
}

struct RecurrenceRule: Codable {
    var frequency: RecurrenceFrequency
    var interval: Int // e.g., every 2 weeks
    var endDate: Date?
}

enum RecurrenceFrequency: String, Codable {
    case daily
    case weekly
    case monthly
}

extension Playdate {
    static var preview: Playdate {
        Playdate(
            id: "playdate1",
            groupId: "group1",
            createdBy: "child1",
            title: "Park Playdate",
            description: "Let's play at the park!",
            startTime: Date().addingTimeInterval(86400), // Tomorrow
            endTime: Date().addingTimeInterval(90000),
            location: PlaydateLocation(
                name: "Central Park",
                address: "123 Park Ave",
                latitude: 40.7829,
                longitude: -73.9654
            ),
            invitedChildren: ["child1", "child2", "child3"],
            rsvps: [
                RSVP(childId: "child1", status: .accepted, parentApproved: true, respondedAt: Date(), approvedAt: Date()),
                RSVP(childId: "child2", status: .pending, parentApproved: false, respondedAt: nil, approvedAt: nil)
            ],
            status: .pending,
            isRecurring: false,
            recurrenceRule: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
