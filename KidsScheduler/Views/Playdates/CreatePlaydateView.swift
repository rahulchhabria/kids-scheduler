//
//  CreatePlaydateView.swift
//  KidsScheduler
//
//  Multi-step form for creating a new playdate
//

import SwiftUI

struct CreatePlaydateView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = PlaydateCreationViewModel()

    @State private var currentStep = 1
    let totalSteps = 4

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress indicator
                ProgressStepView(currentStep: currentStep, totalSteps: totalSteps)
                    .padding()

                // Step content
                TabView(selection: $currentStep) {
                    Step1GroupSelectionView(viewModel: viewModel)
                        .tag(1)

                    Step2BasicInfoView(viewModel: viewModel)
                        .tag(2)

                    Step3TimeLocationView(viewModel: viewModel)
                        .tag(3)

                    Step4FriendsSelectionView(viewModel: viewModel)
                        .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Navigation buttons
                HStack(spacing: 16) {
                    if currentStep > 1 {
                        Button(action: { currentStep -= 1 }) {
                            Text("Back")
                                .font(.headline)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }

                    Button(action: nextStep) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text(currentStep == totalSteps ? "Create Playdate" : "Next")
                                    .font(.headline)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canProceed ? Color.blue : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(!canProceed || viewModel.isLoading)
                }
                .padding()
            }
            .navigationTitle("Create Playdate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Success!", isPresented: $viewModel.showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Playdate created successfully!")
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

    private var canProceed: Bool {
        switch currentStep {
        case 1:
            return viewModel.selectedGroup != nil
        case 2:
            return !viewModel.title.isEmpty && !viewModel.activityType.rawValue.isEmpty
        case 3:
            return viewModel.startTime < viewModel.endTime
        case 4:
            return !viewModel.selectedFriends.isEmpty
        default:
            return false
        }
    }

    private func nextStep() {
        if currentStep < totalSteps {
            withAnimation {
                currentStep += 1
            }
        } else {
            // Create playdate
            Task {
                await viewModel.createPlaydate()
            }
        }
    }
}

// MARK: - Progress Step View

struct ProgressStepView: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...totalSteps, id: \.self) { step in
                Circle()
                    .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                    .frame(height: 10)
                    .overlay(
                        Text("\(step)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .opacity(step == currentStep ? 1 : 0)
                    )
            }
        }
    }
}

// MARK: - Step 1: Group Selection

struct Step1GroupSelectionView: View {
    @ObservedObject var viewModel: PlaydateCreationViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select a Group")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Which group is this playdate for?")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                if viewModel.availableGroups.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.3")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))

                        Text("No groups available")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Text("Create or join a group first to create playdates")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                } else {
                    VStack(spacing: 12) {
                        ForEach(viewModel.availableGroups) { group in
                            GroupSelectionCard(
                                group: group,
                                isSelected: viewModel.selectedGroup?.id == group.id,
                                onSelect: { viewModel.selectedGroup = group }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
}

struct GroupSelectionCard: View {
    let group: FriendGroup
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(group.groupName.prefix(1).uppercased())
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(group.groupName)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("\(group.members.count) members")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Step 2: Basic Info

struct Step2BasicInfoView: View {
    @ObservedObject var viewModel: PlaydateCreationViewModel

    let activityTypes: [ActivityType] = [.park, .sports, .art, .gaming, .movie, .study, .birthday, .other]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Playdate Details")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("What are you planning to do?")
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .leading, spacing: 16) {
                    // Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.headline)

                        TextField("e.g., Park Playdate, Soccer Game", text: $viewModel.title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.body)
                    }

                    // Activity Type
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Activity Type")
                            .font(.headline)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                            ForEach(activityTypes, id: \.self) { type in
                                ActivityTypeButton(
                                    activityType: type,
                                    isSelected: viewModel.activityType == type,
                                    onSelect: { viewModel.activityType = type }
                                )
                            }
                        }
                    }

                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description (Optional)")
                            .font(.headline)

                        TextEditor(text: $viewModel.description)
                            .frame(height: 100)
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
    }
}

struct ActivityTypeButton: View {
    let activityType: ActivityType
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                Text(activityType.emoji)
                    .font(.system(size: 32))

                Text(activityType.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Step 3: Time & Location

struct Step3TimeLocationView: View {
    @ObservedObject var viewModel: PlaydateCreationViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("When & Where")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Set the date, time, and location")
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .leading, spacing: 16) {
                    // Start Time
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Start Time")
                            .font(.headline)

                        DatePicker("", selection: $viewModel.startTime, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.compact)
                            .labelsHidden()
                    }

                    // End Time
                    VStack(alignment: .leading, spacing: 8) {
                        Text("End Time")
                            .font(.headline)

                        DatePicker("", selection: $viewModel.endTime, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.compact)
                            .labelsHidden()
                    }

                    // Duration display
                    if viewModel.endTime > viewModel.startTime {
                        let duration = viewModel.endTime.timeIntervalSince(viewModel.startTime) / 3600
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.blue)
                            Text("Duration: \(String(format: "%.1f", duration)) hours")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }

                    Divider()

                    // Location
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Location (Optional)")
                            .font(.headline)

                        TextField("Location name", text: $viewModel.locationName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        TextField("Address", text: $viewModel.locationAddress)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Step 4: Friends Selection

struct Step4FriendsSelectionView: View {
    @ObservedObject var viewModel: PlaydateCreationViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Invite Friends")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Who would you like to invite?")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                if viewModel.availableFriends.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.2")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))

                        Text("No friends available")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                } else {
                    VStack(spacing: 12) {
                        ForEach(viewModel.availableFriends) { friend in
                            FriendSelectionRow(
                                friend: friend,
                                isSelected: viewModel.selectedFriends.contains(friend.id ?? ""),
                                onToggle: { viewModel.toggleFriend(friend) }
                            )
                        }
                    }
                    .padding(.horizontal)
                }

                if !viewModel.selectedFriends.isEmpty {
                    Text("\(viewModel.selectedFriends.count) friend(s) selected")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
}

struct FriendSelectionRow: View {
    let friend: Child
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Text(friend.avatarEmoji)
                    .font(.system(size: 40))

                VStack(alignment: .leading, spacing: 4) {
                    Text(friend.childName)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("Age \(friend.age)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .blue : .gray.opacity(0.3))
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.05) : Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Activity Type Extension

extension ActivityType {
    var emoji: String {
        switch self {
        case .park: return "🏞️"
        case .sports: return "⚽"
        case .art: return "🎨"
        case .gaming: return "🎮"
        case .movie: return "🎬"
        case .study: return "📚"
        case .birthday: return "🎂"
        case .other: return "📌"
        }
    }

    var displayName: String {
        rawValue.capitalized
    }
}

struct CreatePlaydateView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePlaydateView()
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
