//
//  ChildProfileSetupView.swift
//  KidsScheduler
//
//  Full-screen child profile setup with photo upload
//

import SwiftUI
import PhotosUI
import FirebaseStorage

struct ChildProfileSetupView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var viewModel = ChildProfileSetupViewModel()

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("Create Your Profile")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 60)

                    Text("Let's set up your account so you can start scheduling playdates!")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 40)

                // Main content card
                VStack(spacing: 32) {
                    // Profile Photo Section
                    VStack(spacing: 20) {
                        Text("Profile Photo")
                            .font(.title2)
                            .fontWeight(.bold)

                        // Large profile photo display
                        ProfilePhotoView(
                            selectedImage: viewModel.selectedImage,
                            selectedEmoji: viewModel.selectedEmoji,
                            photoURL: viewModel.photoURL
                        )

                        // Photo selection options
                        HStack(spacing: 20) {
                            PhotoOptionButton(
                                icon: "camera.circle.fill",
                                title: "Take Photo",
                                color: .blue,
                                action: { viewModel.showCamera = true }
                            )

                            PhotoOptionButton(
                                icon: "photo.circle.fill",
                                title: "Choose Photo",
                                color: .green,
                                action: { viewModel.showPhotoPicker = true }
                            )

                            PhotoOptionButton(
                                icon: "face.smiling.fill",
                                title: "Use Emoji",
                                color: .orange,
                                action: { viewModel.showEmojiPicker = true }
                            )
                        }
                    }

                    Divider()
                        .padding(.horizontal)

                    // Name input
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What's your name?")
                            .font(.title3)
                            .fontWeight(.semibold)

                        TextField("Enter your name", text: $viewModel.childName)
                            .font(.system(size: 24, weight: .medium))
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                    }
                    .padding(.horizontal)

                    // Age picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How old are you?")
                            .font(.title3)
                            .fontWeight(.semibold)

                        HStack(spacing: 12) {
                            ForEach([8, 9, 10, 11, 12, 13, 14, 15], id: \.self) { age in
                                AgeButton(
                                    age: age,
                                    isSelected: viewModel.childAge == age,
                                    onSelect: { viewModel.childAge = age }
                                )
                            }
                        }

                        Picker("Age", selection: $viewModel.childAge) {
                            ForEach(4...17, id: \.self) { age in
                                Text("\(age)").tag(age)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 120)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                    }
                    .padding(.horizontal)

                    Spacer()

                    // Create Profile Button
                    Button(action: {
                        Task {
                            await viewModel.createProfile(authViewModel: authViewModel)
                        }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.2)
                            } else {
                                Text("Create Profile")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.title2)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(viewModel.canCreateProfile ? Color.white : Color.gray.opacity(0.5))
                        .foregroundColor(viewModel.canCreateProfile ? .blue : .white)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                    }
                    .disabled(!viewModel.canCreateProfile || viewModel.isLoading)
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
                .frame(maxWidth: 700)
                .padding(.vertical, 30)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white.opacity(0.95))
                        .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
                )
                .padding(.horizontal, 30)
            }
        }
        .sheet(isPresented: $viewModel.showPhotoPicker) {
            PhotoPickerView(selectedImage: $viewModel.selectedImage)
        }
        .sheet(isPresented: $viewModel.showCamera) {
            CameraView(selectedImage: $viewModel.selectedImage)
        }
        .sheet(isPresented: $viewModel.showEmojiPicker) {
            EmojiPickerView(selectedEmoji: $viewModel.selectedEmoji)
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

// MARK: - Profile Photo View

struct ProfilePhotoView: View {
    let selectedImage: UIImage?
    let selectedEmoji: String
    let photoURL: String?

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 200, height: 200)

            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 6)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 15, y: 8)
            } else if let urlString = photoURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                } placeholder: {
                    ProgressView()
                }
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 6)
                )
                .shadow(color: .black.opacity(0.3), radius: 15, y: 8)
            } else {
                Text(selectedEmoji)
                    .font(.system(size: 100))
                    .frame(width: 200, height: 200)
                    .background(
                        Circle()
                            .fill(Color.white)
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 6
                            )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 15, y: 8)
            }
        }
    }
}

// MARK: - Photo Option Button

struct PhotoOptionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                    .frame(width: 70, height: 70)
                    .background(color)
                    .clipShape(Circle())
                    .shadow(color: color.opacity(0.4), radius: 8, y: 4)

                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
        }
    }
}

// MARK: - Age Button

struct AgeButton: View {
    let age: Int
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            Text("\(age)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(isSelected ? .white : .primary)
                .frame(width: 60, height: 60)
                .background(isSelected ? Color.blue : Color.white)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                )
                .shadow(color: isSelected ? Color.blue.opacity(0.4) : Color.clear, radius: 8, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Emoji Picker View

struct EmojiPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedEmoji: String

    let emojiOptions = [
        "😀", "😃", "😄", "😁", "😆", "😅", "🤣", "😂",
        "🙂", "🙃", "😉", "😊", "😇", "🥰", "😍", "🤩",
        "😘", "😗", "😚", "😙", "🥲", "😋", "😛", "😜",
        "🤪", "😝", "🤑", "🤗", "🤭", "🤫", "🤔", "🤐",
        "🦁", "🐯", "🐻", "🐼", "🐨", "🐸", "🦊", "🐙",
        "🦄", "🐰", "🐶", "🐱", "🐭", "🐹", "🐷", "🐮",
        "🦀", "🦞", "🦐", "🦑", "🐋", "🐬", "🐟", "🐠",
        "🦈", "🐡", "🐢", "🦎", "🐍", "🦕", "🦖", "🦦"
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 16) {
                    ForEach(emojiOptions, id: \.self) { emoji in
                        Button(action: {
                            selectedEmoji = emoji
                            dismiss()
                        }) {
                            Text(emoji)
                                .font(.system(size: 50))
                                .frame(width: 80, height: 80)
                                .background(selectedEmoji == emoji ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(selectedEmoji == emoji ? Color.blue : Color.clear, lineWidth: 3)
                                )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Choose an Emoji")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Photo Picker View

struct PhotoPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        NavigationView {
            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                VStack(spacing: 20) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)

                    Text("Choose a Photo")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Tap to select a photo from your library")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                        dismiss()
                    }
                }
            }
            .navigationTitle("Select Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Camera View

struct CameraView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedImage: UIImage?

    var body: some View {
        ImagePicker(selectedImage: $selectedImage, sourceType: .camera, onDismiss: {
            dismiss()
        })
    }
}

// MARK: - UIImagePicker Wrapper

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    let sourceType: UIImagePickerController.SourceType
    let onDismiss: () -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.onDismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onDismiss()
        }
    }
}

// MARK: - ViewModel

@MainActor
class ChildProfileSetupViewModel: ObservableObject {
    @Published var childName = ""
    @Published var childAge = 10
    @Published var selectedEmoji = "🦁"
    @Published var selectedImage: UIImage?
    @Published var photoURL: String?
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var showPhotoPicker = false
    @Published var showCamera = false
    @Published var showEmojiPicker = false

    var canCreateProfile: Bool {
        !childName.isEmpty && childAge >= 4 && childAge <= 17
    }

    func createProfile(authViewModel: AuthenticationViewModel) async {
        guard canCreateProfile else {
            errorMessage = "Please fill in all required fields"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            // Upload photo if selected
            var uploadedPhotoURL: String?
            if let image = selectedImage {
                uploadedPhotoURL = try await uploadPhoto(image)
            }

            // Create child profile
            let child = Child(
                id: nil,
                parentId: authViewModel.currentUser?.id ?? "unknown",
                childName: childName,
                age: childAge,
                avatarUrl: uploadedPhotoURL,
                avatarEmoji: selectedEmoji,
                groups: [],
                createdAt: Date(),
                updatedAt: Date()
            )

            // Save to Firestore
            let firestoreService = FirestoreService()
            let childId = try await firestoreService.create(collection: "children", data: child)

            print("✅ Child profile created with ID: \(childId)")

            // Update auth view model
            await authViewModel.fetchChildren(for: authViewModel.currentUser!)

            isLoading = false
        } catch {
            errorMessage = "Failed to create profile: \(error.localizedDescription)"
            isLoading = false
        }
    }

    private func uploadPhoto(_ image: UIImage) async throws -> String {
        // Resize image to reasonable size
        guard let resizedImage = image.resized(toWidth: 500),
              let imageData = resizedImage.jpegData(compressionQuality: 0.7) else {
            throw ProfileError.imageProcessingFailed
        }

        // Upload to Firebase Storage
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let filename = "\(UUID().uuidString).jpg"
        let photoRef = storageRef.child("profile_photos/\(filename)")

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await photoRef.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await photoRef.downloadURL()

        return downloadURL.absoluteString
    }
}

// MARK: - UIImage Extension

extension UIImage {
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

// MARK: - Errors

enum ProfileError: LocalizedError {
    case imageProcessingFailed

    var errorDescription: String? {
        switch self {
        case .imageProcessingFailed:
            return "Failed to process the image. Please try another photo."
        }
    }
}

struct ChildProfileSetupView_Previews: PreviewProvider {
    static var previews: some View {
        ChildProfileSetupView()
            .environmentObject(AuthenticationViewModel())
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
