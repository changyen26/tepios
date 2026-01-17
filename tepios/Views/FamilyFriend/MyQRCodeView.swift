/**
 * 我的 QR Code 頁面
 */

import SwiftUI
import CoreImage.CIFilterBuiltins

struct MyQRCodeView: View {
    // MARK: - State

    @Environment(\.dismiss) private var dismiss
    @StateObject private var userViewModel = UserProfileViewModel.shared

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.darkGradient
                    .ignoresSafeArea()

                VStack(spacing: AppTheme.Spacing.xxl) {
                    Spacer()

                    // 用戶資訊
                    userInfoSection

                    // QR Code
                    qrCodeSection

                    // 說明文字
                    instructionText

                    Spacer()

                    // 分享按鈕
                    shareButton
                }
                .padding(.horizontal, AppTheme.Spacing.xl)
            }
            .navigationTitle("我的 QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("關閉") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.gold)
                }
            }
        }
    }

    // MARK: - Components

    /// 用戶資訊區域
    private var userInfoSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // 頭像
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.gold, Color(hex: "#D4B756")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)

                if let avatarData = userViewModel.user.profile.avatarData,
                   let uiImage = UIImage(data: avatarData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 40))
                        .foregroundColor(AppTheme.dark)
                }
            }

            // 名稱和等級
            VStack(spacing: 4) {
                if !userViewModel.user.profile.name.isEmpty {
                    Text(userViewModel.user.profile.name)
                        .font(.system(size: AppTheme.FontSize.title2, weight: .bold))
                        .foregroundColor(.white)
                }

                Text("Lv.\(userViewModel.user.cloudPassport.level) \(userViewModel.user.cloudPassport.title)")
                    .font(.system(size: AppTheme.FontSize.callout, weight: .medium))
                    .foregroundColor(AppTheme.gold)
            }

            // 用戶 ID
            HStack(spacing: 4) {
                Text("ID:")
                    .font(.system(size: AppTheme.FontSize.caption))
                    .foregroundColor(.white.opacity(0.6))

                Text(userViewModel.user.id.prefix(8) + "...")
                    .font(.system(size: AppTheme.FontSize.caption, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }

    /// QR Code 區域
    private var qrCodeSection: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // QR Code 卡片
            VStack(spacing: AppTheme.Spacing.md) {
                if let qrCodeImage = generateQRCode(from: "tepios://user/\(userViewModel.user.id)") {
                    Image(uiImage: qrCodeImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220, height: 220)
                        .padding(AppTheme.Spacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                                .fill(Color.white)
                        )
                } else {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 220, height: 220)
                        .cornerRadius(AppTheme.CornerRadius.lg)
                        .overlay(
                            Text("無法生成 QR Code")
                                .foregroundColor(.gray)
                        )
                }
            }
            .padding(AppTheme.Spacing.xl)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl)
                            .stroke(AppTheme.gold.opacity(0.3), lineWidth: 2)
                    )
            )
        }
    }

    /// 說明文字
    private var instructionText: some View {
        Text("請對方掃描此 QR Code\n即可快速添加為好友")
            .font(.system(size: AppTheme.FontSize.callout))
            .foregroundColor(.white.opacity(0.7))
            .multilineTextAlignment(.center)
    }

    /// 分享按鈕
    private var shareButton: some View {
        Button(action: shareQRCode) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("分享 QR Code")
                    .font(.system(size: AppTheme.FontSize.headline, weight: .semibold))
            }
            .foregroundColor(AppTheme.dark)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                    .fill(AppTheme.goldGradient)
            )
        }
        .padding(.bottom, AppTheme.Spacing.xl)
    }

    // MARK: - Methods

    /// 生成 QR Code
    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()

        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            // 放大 QR Code 以提高清晰度
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)

            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }

        return nil
    }

    /// 分享 QR Code
    private func shareQRCode() {
        guard let qrCodeImage = generateQRCode(from: "tepios://user/\(userViewModel.user.id)") else {
            return
        }

        let activityVC = UIActivityViewController(
            activityItems: [qrCodeImage, "掃描此 QR Code 添加我為好友"],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Preview

#Preview {
    MyQRCodeView()
}
