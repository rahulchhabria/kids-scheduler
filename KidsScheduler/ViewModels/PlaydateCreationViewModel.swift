//
//  PlaydateCreationViewModel.swift
//  KidsScheduler
//
//  Manages playdate creation flow and data
//

import Foundation
import SwiftUI

@MainActor
class PlaydateCreationViewModel: ObservableObject {
    // Step 1: Group Selection
    @Published var availableGroups: [FriendGroup] = []
    @Published var selectedGroup: FriendGroup?

    // Step 2: Basic Info
    @Published var title = ""
    @Published var description = ""
    @Published var activityType: ActivityType = .park

    // Step 3: Time & Location
    @Published var startTime = Date().addingTimeInterval(3600) // 1 hour from now
    @Published var endTime = Date().addingTimeInterval(7200) // 2 hours from now
    @Published var locationName = ""
    @Published var locationAddress = ""

    // Step 4: Friends Selection
    @Published var availableFriends: [Child] = []
    @Published var selectedFriends: [String] = []

    // UI State
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showSuccess = false

    private let playdateService = PlaydateService()
    private let groupService = GroupService()
    private let firestoreService = FirestoreService()

    init() {
        // Load mock data in debug mode
        if DEBUG_MODE {
            availableGroups = FriendGroup.mockGroups
            availableFriends = Child.mockChildren
        }
    }

    // MARK: - Load Data

    func loadGroups(for childId: String) async {
        do {
            availableGroups = try await groupService.fetchGroups(for: childId)
        } catch {
            errorMessage = "Failed to load groups: \(error.localizedDescription)"
        }
    }

    func loadFriends(for groupId: String) async {
        guard let group = availableGroups.first(where: { $0.id == groupId }) else {
            return
        }

        do {
            var friends: [Child] = []
            for memberId in group.members {
                let child = try await firestoreService.read(
                    collection: "children",
                    documentId: memberId,
                    as: Child.self
                )
                friends.append(child)
            }
            availableFriends = friends
        } catch {
            errorMessage = "Failed to load friends: \(error.localizedDescription)"
        }
    }

    // MARK: - Friend Selection

    func toggleFriend(_ friend: Child) {
        guard let friendId = friend.id else { return }

        if selectedFriends.contains(friendId) {
            selectedFriends.removeAll { $0 == friendId }
        } else {
            selectedFriends.append(friendId)
        }
    }

    // MARK: - Create Playdate

    func createPlaydate() async {
        guard let group = selectedGroup,
              let groupId = group.id else {
            errorMessage = "Please select a group"
            return
        }

        // Validation
        guard !title.isEmpty else {
            errorMessage = "Please enter a title"
            return
        }

        guard startTime < endTime else {
            errorMessage = "End time must be after start time"
            return
        }

        guard !selectedFriends.isEmpty else {
            errorMessage = "Please invite at least one friend"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            // TODO: Get actual child and parent IDs from auth context
            let createdBy = "mock-child-id"
            let parentId = "mock-parent-id"

            // Create location if provided
            var location: PlaydateLocation?
            if !locationName.isEmpty {
                location = PlaydateLocation(
                    name: locationName,
                    address: locationAddress.isEmpty ? nil : locationAddress,
                    latitude: nil,
                    longitude: nil
                )
            }

            let playdateId = try await playdateService.createPlaydate(
                groupId: groupId,
                createdBy: createdBy,
                createdByParentId: parentId,
                title: title,
                description: description.isEmpty ? nil : description,
                activityType: activityType,
                startTime: startTime,
                endTime: endTime,
                location: location,
                invitedChildren: selectedFriends,
                isRecurring: false,
                recurrenceRule: nil
            )

            isLoading = false
            showSuccess = true

            print("✅ Playdate created with ID: \(playdateId)")
        } catch {
            isLoading = false
            errorMessage = "Failed to create playdate: \(error.localizedDescription)"
        }
    }
}

// MARK: - Mock Data

extension Child {
    static var mockChildren: [Child] {
        [
            Child(
                id: "child1",
                parentId: "parent1",
                childName: "Alex",
                age: 10,
                avatarEmoji: "🦁",
                groups: ["group1", "group2"],
                createdAt: Date(),
                updatedAt: Date()
            ),
            Child(
                id: "child2",
                parentId: "parent2",
                childName: "Sam",
                age: 9,
                avatarEmoji: "🐶",
                groups: ["group1", "group2"],
                createdAt: Date(),
                updatedAt: Date()
            ),
            Child(
                id: "child3",
                parentId: "parent3",
                childName: "Jordan",
                age: 11,
                avatarEmoji: "🐼",
                groups: ["group1", "group3"],
                createdAt: Date(),
                updatedAt: Date()
            ),
            Child(
                id: "child4",
                parentId: "parent4",
                childName: "Taylor",
                age: 10,
                avatarEmoji: "🦊",
                groups: ["group1", "group3"],
                createdAt: Date(),
                updatedAt: Date()
            ),
            Child(
                id: "child5",
                parentId: "parent5",
                childName: "Casey",
                age: 8,
                avatarEmoji: "🐨",
                groups: ["group3"],
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
    }
}
