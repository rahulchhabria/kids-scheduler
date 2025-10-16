//
//  Child.swift
//  KidsScheduler
//
//  Child profile model
//

import Foundation
import FirebaseFirestore

struct Child: Identifiable, Codable {
    @DocumentID var id: String?
    var parentId: String
    var childName: String
    var age: Int
    var avatarUrl: String?
    var avatarEmoji: String // Fallback for avatar
    var groups: [String] // Array of group IDs
    var createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case parentId
        case childName
        case age
        case avatarUrl
        case avatarEmoji
        case groups
        case createdAt
        case updatedAt
    }
}

extension Child {
    static var preview: Child {
        Child(
            id: "child1",
            parentId: "parent123",
            childName: "Alex",
            age: 8,
            avatarUrl: nil,
            avatarEmoji: "🦁",
            groups: ["group1", "group2"],
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    static var previews: [Child] {
        [
            Child(id: "child1", parentId: "parent123", childName: "Alex", age: 8, avatarUrl: nil, avatarEmoji: "🦁", groups: [], createdAt: Date(), updatedAt: Date()),
            Child(id: "child2", parentId: "parent123", childName: "Sam", age: 10, avatarUrl: nil, avatarEmoji: "🐯", groups: [], createdAt: Date(), updatedAt: Date())
        ]
    }
}
