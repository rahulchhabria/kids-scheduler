//
//  InviteFriendView.swift
//  KidsScheduler
//
//  Kid-facing view for inviting friends
//

import SwiftUI

struct InviteFriendView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = InviteFriendViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "person.badge.plus.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)

                        Text("Invite a Friend")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Enter your friend's parent's email to send them an invitation")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)

                    // Form
                    VStack(alignment: .leading, spacing: 24) {
                        // Parent Email
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Parent's Email", systemImage: "envelope.fill")
                                .font(.headline)
                                .foregroundColor(.primary)

                            TextField("parent@example.com", text: $viewModel.parentEmail)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .font(.body)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)

                            Text("We'll send an invitation to this email")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        // Optional: Phone Number
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Phone Number (Optional)", systemImage: "phone.fill")
                                .font(.headline)
                                .foregroundColor(.primary)

                            TextField("(555) 123-4567", text: $viewModel.phoneNumber)
                                .textContentType(.telephoneNumber)
                                .keyboardType(.phonePad)
                                .font(.body)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)

                            Text("For text message notifications")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Divider()
                            .padding(.vertical, 8)

                        // Message
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Add a Message", systemImage: "message.fill")
                                .font(.headline)
                                .foregroundColor(.primary)

                            TextEditor(text: $viewModel.message)
                                .frame(height: 120)
                                .padding(8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )

                            Text("Tell them how you know each other!")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        // Info card
                        InfoCard(
                            icon: "info.circle.fill",
                            title: "Parent Approval Required",
                            description: "Your parent will need to approve this invitation before it's sent. The other parent will also need to approve before you become friends."
                        )
                    }
                    .padding(.horizontal)

                    // Send Button
                    Button(action: {
                        Task {
                            await viewModel.sendInvitation()
                            if viewModel.showSuccess {
                                dismiss()
                            }
                        }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Send Invitation")
                                    .font(.headline)
                                Image(systemName: "paperplane.fill")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.canSend ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: viewModel.canSend ? Color.blue.opacity(0.3) : Color.clear, radius: 10, y: 5)
                    }
                    .disabled(!viewModel.canSend || viewModel.isLoading)
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("")
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
                Text("Your invitation has been sent to your parent for approval!")
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

// MARK: - Info Card

struct InfoCard: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - ViewModel

@MainActor
class InviteFriendViewModel: ObservableObject {
    @Published var parentEmail = ""
    @Published var phoneNumber = ""
    @Published var message = ""

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showSuccess = false

    private let invitationService = FriendInvitationService()

    var canSend: Bool {
        isValidEmail(parentEmail) && !message.isEmpty
    }

    func sendInvitation() async {
        guard canSend else {
            errorMessage = "Please fill in all required fields"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            // TODO: Get current child and parent info from auth context
            let childId = "mock-child-id"
            let childName = "Current Child"
            let parentId = "mock-parent-id"
            let parentName = "Parent Name"
            let parentEmail = "parent@example.com"

            let invitationId = try await invitationService.createFriendInvitation(
                fromChildId: childId,
                fromChildName: childName,
                fromParentId: parentId,
                fromParentName: parentName,
                fromParentEmail: parentEmail,
                toEmail: self.parentEmail,
                toPhoneNumber: phoneNumber.isEmpty ? nil : phoneNumber,
                message: message
            )

            print("✅ Invitation created: \(invitationId)")

            isLoading = false
            showSuccess = true

            // Reset form
            parentEmail = ""
            phoneNumber = ""
            message = ""

        } catch {
            isLoading = false
            errorMessage = "Failed to send invitation: \(error.localizedDescription)"
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

struct InviteFriendView_Previews: PreviewProvider {
    static var previews: some View {
        InviteFriendView()
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
