//
//  Group.swift
//  KidsScheduler
//
//  Friend group model
//

import Foundation
import FirebaseFirestore

struct FriendGroup: Identifiable, Codable {
    @DocumentID var id: String?
    var groupName: String
    var groupDescription: String?
    var createdBy: String // Parent ID
    var members: [String] // Array of child IDs
    var inviteCode: String
    var settings: GroupSettings
    var createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case groupName
        case groupDescription
        case createdBy
        case members
        case inviteCode
        case settings
        case createdAt
        case updatedAt
    }
}

struct GroupSettings: Codable {
    var requireParentApproval: Bool
    var allowMembersToInvite: Bool
    var maxMembers: Int

    static var defaultSettings: GroupSettings {
        GroupSettings(
            requireParentApproval: true,
            allowMembersToInvite: false,
            maxMembers: 20
        )
    }
}

extension FriendGroup {
    static var preview: FriendGroup {
        FriendGroup(
            id: "group1",
            groupName: "Soccer Team",
            groupDescription: "Weekend soccer practice and games",
            createdBy: "parent123",
            members: ["child1", "child2", "child3"],
            inviteCode: "SOCCER2024",
            settings: GroupSettings.defaultSettings,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
