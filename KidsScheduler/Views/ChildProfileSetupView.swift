//
//  ChildProfileSetupView.swift
//  KidsScheduler
//
//  First-time setup for creating child profiles
//

import SwiftUI

struct ChildProfileSetupView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var childName = ""
    @State private var childAge = 8
    @State private var selectedEmoji = "🦁"

    let emojiOptions = ["🦁", "🐯", "🐻", "🐼", "🐨", "🐸", "🦊", "🐙", "🦄", "🐰", "🐶", "🐱"]

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Let's create a profile for your child")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding()

                VStack(spacing: 20) {
                    // Avatar selection
                    VStack {
                        Text("Choose an avatar")
                            .font(.title2)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 15) {
                            ForEach(emojiOptions, id: \.self) { emoji in
                                Button(action: {
                                    selectedEmoji = emoji
                                }) {
                                    Text(emoji)
                                        .font(.system(size: 50))
                                        .frame(width: 80, height: 80)
                                        .background(selectedEmoji == emoji ? Color.blue.opacity(0.3) : Color.gray.opacity(0.1))
                                        .cornerRadius(15)
                                }
                            }
                        }
                        .padding()
                    }

                    // Name input
                    VStack(alignment: .leading) {
                        Text("Child's name")
                            .font(.headline)
                        TextField("Enter name", text: $childName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.title3)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }

                    // Age picker
                    VStack(alignment: .leading) {
                        Text("Age")
                            .font(.headline)
                        Picker("Age", selection: $childAge) {
                            ForEach(4...17, id: \.self) { age in
                                Text("\(age) years old").tag(age)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: 150)
                    }
                }
                .padding()

                Spacer()

                // Action buttons
                HStack(spacing: 20) {
                    Button("Skip for now") {
                        // Skip setup
                    }
                    .font(.title3)
                    .foregroundColor(.secondary)

                    Button(action: {
                        // Create child profile
                        Task {
                            await createChildProfile()
                        }
                    }) {
                        Text("Create Profile")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 15)
                            .background(childName.isEmpty ? Color.gray : Color.blue)
                            .cornerRadius(15)
                    }
                    .disabled(childName.isEmpty)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }

    private func createChildProfile() async {
        // Implementation to save child profile to Firestore
        // This will be connected to the ViewModel
    }
}

struct ChildProfileSetupView_Previews: PreviewProvider {
    static var previews: some View {
        ChildProfileSetupView()
            .environmentObject(AuthenticationViewModel())
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
