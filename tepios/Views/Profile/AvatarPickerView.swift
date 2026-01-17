/**
 * 頭像選擇器
 */

import SwiftUI
import PhotosUI

struct AvatarPickerView: View {
    // MARK: - Properties

    @ObservedObject var viewModel: UserProfileViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    @State private var selectedItem: PhotosPickerItem?
    @State private var showCamera = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // 背景
                AppTheme.darkGradient
                    .ignoresSafeArea()

                VStack(spacing: AppTheme.Spacing.xxxl) {
                    // 當前頭像預覽
                    currentAvatarPreview
                        .padding(.top, AppTheme.Spacing.xxxl)

                    // 選擇方式
                    VStack(spacing: AppTheme.Spacing.lg) {
                        // 從相簿選擇
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            HStack {
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 24))
                                Text("從相簿選擇")
                                    .font(.system(size: AppTheme.FontSize.headline, weight: .semibold))
                            }
                            .foregroundColor(AppTheme.dark)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(AppTheme.goldGradient)
                            .cornerRadius(AppTheme.CornerRadius.md)
                        }

                        // 拍照
                        Button(action: {
                            showCamera = true
                        }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 24))
                                Text("拍照")
                                    .font(.system(size: AppTheme.FontSize.headline, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                    .stroke(AppTheme.gold, lineWidth: 2)
                            )
                        }

                        // 移除頭像
                        if viewModel.user.profile.avatarData != nil {
                            Button(action: removeAvatar) {
                                HStack {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 20))
                                    Text("移除頭像")
                                        .font(.system(size: AppTheme.FontSize.body, weight: .medium))
                                }
                                .foregroundColor(.red.opacity(0.8))
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(
                                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                        .stroke(Color.red.opacity(0.5), lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.xl)

                    Spacer()
                }
            }
            .navigationTitle("更換頭像")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.gold)
                }
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await MainActor.run {
                            viewModel.updateAvatar(image)
                            dismiss()
                        }
                    }
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraView { image in
                    viewModel.updateAvatar(image)
                    showCamera = false
                    dismiss()
                }
            }
            .alert("提示", isPresented: $showAlert) {
                Button("確定", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - Components

    private var currentAvatarPreview: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            if let avatarData = viewModel.user.profile.avatarData,
               let uiImage = UIImage(data: avatarData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(AppTheme.gold, lineWidth: 3)
                    )
                    .shadow(
                        color: AppTheme.gold.opacity(0.3),
                        radius: 12,
                        x: 0,
                        y: 8
                    )
            } else {
                Circle()
                    .fill(AppTheme.goldGradient)
                    .frame(width: 150, height: 150)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.dark)
                    )
                    .shadow(
                        color: AppTheme.gold.opacity(0.3),
                        radius: 12,
                        x: 0,
                        y: 8
                    )
            }

            Text("選擇新的頭像")
                .font(.system(size: AppTheme.FontSize.callout))
                .foregroundColor(AppTheme.whiteAlpha06)
        }
    }

    // MARK: - Methods

    private func removeAvatar() {
        viewModel.user.profile.avatarData = nil
        viewModel.saveUser()
        dismiss()
    }
}

// MARK: - Camera View

struct CameraView: UIViewControllerRepresentable {
    var onImageCaptured: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageCaptured(image)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Preview

#Preview {
    AvatarPickerView(viewModel: UserProfileViewModel())
}
