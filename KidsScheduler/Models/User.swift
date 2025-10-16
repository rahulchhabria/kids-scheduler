//
//  User.swift
//  KidsScheduler
//
//  Parent user model
//

import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var email: String
    var parentName: String
    var linkedChildren: [String] // Array of child IDs
    var createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case parentName
        case linkedChildren
        case createdAt
        case updatedAt
    }
}

extension User {
    static var preview: User {
        User(
            id: "parent123",
            email: "parent@example.com",
            parentName: "Jane Smith",
            linkedChildren: ["child1", "child2"],
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
