//
//  JoinGroupView.swift
//  KidsScheduler
//
//  View for joining a group with an invite code
//

import SwiftUI

struct JoinGroupView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: GroupViewModel
    let selectedChild: Child?

    @State private var inviteCode = ""
    @FocusState private var isCodeFieldFocused: Bool

    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Spacer()

                // Icon
                Image(systemName: "number.square.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)

                // Title and description
                VStack(spacing: 12) {
                    Text("Join a Group")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Enter the 6-character invite code shared by your friend")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                // Invite code input
                VStack(spacing: 16) {
                    TextField("INVITE CODE", text: $inviteCode)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .textCase(.uppercase)
                        .autocapitalization(.allCharacters)
                        .disableAutocorrection(true)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .frame(maxWidth: 400)
                        .focused($isCodeFieldFocused)
                        .onChange(of: inviteCode) { newValue in
                            // Limit to 6 characters
                            if newValue.count > 6 {
                                inviteCode = String(newValue.prefix(6))
                            }
                        }

                    Text("\(inviteCode.count)/6 characters")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Join button
                Button(action: joinGroup) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Join Group")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: 400)
                    .padding()
                    .background(inviteCode.count == 6 ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(inviteCode.count != 6 || viewModel.isLoading)

                Spacer()
            }
            .padding()
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                // Auto-focus the text field when view appears
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isCodeFieldFocused = true
                }
            }
        }
    }

    private func joinGroup() {
        Task {
            // TODO: Get actual child ID from auth context
            let childId = selectedChild?.id ?? "mock-child-id"

            await viewModel.joinGroup(inviteCode: inviteCode, childId: childId)

            if viewModel.successMessage != nil {
                dismiss()
            }
        }
    }
}

struct JoinGroupView_Previews: PreviewProvider {
    static var previews: some View {
        JoinGroupView(viewModel: GroupViewModel(), selectedChild: nil)
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
