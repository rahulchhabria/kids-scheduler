//
//  ParentApprovalDashboard.swift
//  KidsScheduler
//
//  Parent dashboard for approving friend requests and managing friendships
//

import SwiftUI

struct ParentApprovalDashboardView: View {
    @StateObject private var viewModel = ParentApprovalViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "shield.checkered")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Parent Dashboard")
                                    .font(.title)
                                    .fontWeight(.bold)

                                Text("Review and manage friend requests")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top)

                    // Pending Approvals Section
                    if viewModel.isLoading {
                        ProgressView()
                            .padding(.vertical, 60)
                    } else if viewModel.pendingRequests.isEmpty {
                        EmptyApprovalState()
                    } else {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Pending Approvals")
                                    .font(.title2)
                                    .fontWeight(.bold)

                                Spacer()

                                Text("\(viewModel.pendingRequests.count)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.red)
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal)

                            ForEach(viewModel.pendingRequests) { request in
                                ApprovalRequestCard(
                                    request: request,
                                    onApprove: {
                                        Task {
                                            await viewModel.approveRequest(request)
                                        }
                                    },
                                    onDeny: {
                                        Task {
                                            await viewModel.denyRequest(request)
                                        }
                                    }
                                )
                                .padding(.horizontal)
                            }
                        }
                    }

                    Divider()
                        .padding(.vertical)

                    // Active Friendships Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Active Friendships")
                                .font(.title2)
                                .fontWeight(.bold)

                            Spacer()

                            Text("\(viewModel.friendships.count)")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)

                        if viewModel.friendships.isEmpty {
                            EmptyFriendshipsState()
                        } else {
                            ForEach(viewModel.friendships) { friendship in
                                FriendshipCard(
                                    friendship: friendship,
                                    onPause: {
                                        Task {
                                            await viewModel.pauseFriendship(friendship)
                                        }
                                    },
                                    onResume: {
                                        Task {
                                            await viewModel.resumeFriendship(friendship)
                                        }
                                    },
                                    onBlock: {
                                        Task {
                                            await viewModel.blockFriendship(friendship)
                                        }
                                    }
                                )
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Parent Controls")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await viewModel.loadData()
            }
            .task {
                await viewModel.loadData()
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }
}

// MARK: - Approval Request Card

struct ApprovalRequestCard: View {
    let request: ParentApprovalRequest
    let onApprove: () -> Void
    let onDeny: () -> Void

    @State private var showConfirmDeny = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: requestIcon)
                    .font(.title)
                    .foregroundColor(requestColor)
                    .frame(width: 50, height: 50)
                    .background(requestColor.opacity(0.1))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(requestTitle)
                        .font(.headline)
                        .fontWeight(.bold)

                    Text(request.childName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(timeAgo(from: request.createdAt))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Request Details
            VStack(alignment: .leading, spacing: 12) {
                DetailRow(
                    icon: "person.fill",
                    label: "Other Child",
                    value: request.otherChildName
                )

                DetailRow(
                    icon: "person.2.fill",
                    label: "Other Parent",
                    value: request.otherParentName
                )

                DetailRow(
                    icon: "envelope.fill",
                    label: "Email",
                    value: request.otherParentEmail
                )

                if let message = request.message, !message.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "message.fill")
                                .foregroundColor(.blue)
                            Text("Message")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                        }

                        Text(message)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }

            // Action Buttons
            HStack(spacing: 12) {
                Button(action: { showConfirmDeny = true }) {
                    Label("Deny", systemImage: "xmark.circle.fill")
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                }

                Button(action: onApprove) {
                    Label("Approve", systemImage: "checkmark.circle.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                        .shadow(color: Color.green.opacity(0.3), radius: 8, y: 4)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        .confirmationDialog("Deny Request?", isPresented: $showConfirmDeny) {
            Button("Deny", role: .destructive, action: onDeny)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to deny this friend request? Your child will be notified.")
        }
    }

    private var requestIcon: String {
        request.requestType == .outgoingFriendRequest ? "paperplane.fill" : "tray.fill"
    }

    private var requestColor: Color {
        request.requestType == .outgoingFriendRequest ? .blue : .green
    }

    private var requestTitle: String {
        request.requestType == .outgoingFriendRequest
            ? "Outgoing Friend Request"
            : "Incoming Friend Request"
    }

    private func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let hours = Int(interval / 3600)
        if hours < 24 {
            return "\(hours)h ago"
        }
        let days = hours / 24
        return "\(days)d ago"
    }
}

// MARK: - Detail Row

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)

            Text(label)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)

            Text(value)
                .font(.body)

            Spacer()
        }
    }
}

// MARK: - Friendship Card

struct FriendshipCard: View {
    let friendship: Friendship
    let onPause: () -> Void
    let onResume: () -> Void
    let onBlock: () -> Void

    @State private var showActions = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 12) {
                    Text("👥")
                        .font(.system(size: 40))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(friendship.child1Name) & \(friendship.child2Name)")
                            .font(.headline)

                        Text("Friends since \(formattedDate(friendship.createdAt))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                if isPaused {
                    Image(systemName: "pause.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                }

                Button(action: { showActions = true }) {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }

            if isPaused {
                Text("⚠️ Friendship Paused")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        .confirmationDialog("Manage Friendship", isPresented: $showActions) {
            if isPaused {
                Button("Resume Friendship", action: onResume)
            } else {
                Button("Pause Friendship", action: onPause)
            }
            Button("Block Friendship", role: .destructive, action: onBlock)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Choose an action for this friendship")
        }
    }

    private var isPaused: Bool {
        friendship.isPausedByParent1 || friendship.isPausedByParent2
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Empty States

struct EmptyApprovalState: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green.opacity(0.5))

            Text("All Caught Up!")
                .font(.title2)
                .fontWeight(.bold)

            Text("No pending friend requests to review")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 60)
    }
}

struct EmptyFriendshipsState: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))

            Text("No Active Friendships")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("When your child makes friends, they'll appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
        .padding(.horizontal)
    }
}

// MARK: - ViewModel

@MainActor
class ParentApprovalViewModel: ObservableObject {
    @Published var pendingRequests: [ParentApprovalRequest] = []
    @Published var friendships: [Friendship] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let invitationService = FriendInvitationService()

    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            // TODO: Get actual parent ID from auth context
            let parentId = "mock-parent-id"

            // Load pending approval requests
            pendingRequests = try await invitationService.fetchPendingApprovalRequests(for: parentId)

            // Load friendships for all children of this parent
            // TODO: Get actual children IDs
            let childId = "mock-child-id"
            friendships = try await invitationService.fetchFriendships(for: childId)

            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to load data: \(error.localizedDescription)"
        }
    }

    func approveRequest(_ request: ParentApprovalRequest) async {
        do {
            guard let requestId = request.id else { return }
            try await invitationService.respondToApprovalRequest(
                approvalRequestId: requestId,
                approved: true
            )

            // Remove from list
            pendingRequests.removeAll { $0.id == requestId }

            // Reload friendships in case new one was created
            await loadData()
        } catch {
            errorMessage = "Failed to approve: \(error.localizedDescription)"
        }
    }

    func denyRequest(_ request: ParentApprovalRequest) async {
        do {
            guard let requestId = request.id else { return }
            try await invitationService.respondToApprovalRequest(
                approvalRequestId: requestId,
                approved: false
            )

            // Remove from list
            pendingRequests.removeAll { $0.id == requestId }
        } catch {
            errorMessage = "Failed to deny: \(error.localizedDescription)"
        }
    }

    func pauseFriendship(_ friendship: Friendship) async {
        do {
            guard let friendshipId = friendship.id else { return }
            let parentId = "mock-parent-id" // TODO: Get from auth

            try await invitationService.pauseFriendship(
                friendshipId: friendshipId,
                parentId: parentId
            )

            await loadData()
        } catch {
            errorMessage = "Failed to pause: \(error.localizedDescription)"
        }
    }

    func resumeFriendship(_ friendship: Friendship) async {
        do {
            guard let friendshipId = friendship.id else { return }
            let parentId = "mock-parent-id" // TODO: Get from auth

            try await invitationService.resumeFriendship(
                friendshipId: friendshipId,
                parentId: parentId
            )

            await loadData()
        } catch {
            errorMessage = "Failed to resume: \(error.localizedDescription)"
        }
    }

    func blockFriendship(_ friendship: Friendship) async {
        do {
            guard let friendshipId = friendship.id else { return }
            let parentId = "mock-parent-id" // TODO: Get from auth

            try await invitationService.blockFriendship(
                friendshipId: friendshipId,
                parentId: parentId
            )

            await loadData()
        } catch {
            errorMessage = "Failed to block: \(error.localizedDescription)"
        }
    }
}

struct ParentApprovalDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        ParentApprovalDashboardView()
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
