/**
 * 帳號安全設定頁面
 */

import SwiftUI

struct AccountSecurityView: View {
    // MARK: - Properties

    @ObservedObject var viewModel: UserProfileViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    @State private var showChangePassword = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // 背景
                AppTheme.darkGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        // 帳號資訊區域
                        accountInfoSection
                            .padding(.top, AppTheme.Spacing.xl)

                        // 安全設定選項
                        securityOptionsSection

                        Spacer()
                    }
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .padding(.bottom, AppTheme.Spacing.xxl)
                }
            }
            .navigationTitle("帳號與安全")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.gold)
                }
            }
            .sheet(isPresented: $showChangePassword) {
                ChangePasswordView(viewModel: viewModel)
            }
            .alert("提示", isPresented: $showAlert) {
                Button("確定", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - Components

    private var accountInfoSection: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // 標題
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.gold)

                Text("帳號資訊")
                    .font(.system(size: AppTheme.FontSize.title3, weight: .bold))
                    .foregroundColor(.white)

                Spacer()
            }

            // 帳號名稱
            AccountInfoRow(
                icon: "at",
                title: "帳號",
                value: viewModel.user.accountSettings.username,
                showChevron: false
            )

            // 註冊日期（假設為固定日期，實際應從資料庫取得）
            AccountInfoRow(
                icon: "calendar",
                title: "註冊日期",
                value: "2024年01月01日",
                showChevron: false
            )
        }
        .padding(AppTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                        .stroke(AppTheme.gold.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private var securityOptionsSection: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // 標題
            HStack {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.gold)

                Text("安全設定")
                    .font(.system(size: AppTheme.FontSize.title3, weight: .bold))
                    .foregroundColor(.white)

                Spacer()
            }

            // 修改密碼
            SecurityOptionButton(
                icon: "key.fill",
                title: "修改密碼",
                description: "更改您的登入密碼",
                action: {
                    showChangePassword = true
                }
            )

            // 雙重驗證（暫時顯示未啟用狀態）
            HStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.gold)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 4) {
                    Text("雙重驗證")
                        .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                        .foregroundColor(.white)

                    Text(viewModel.user.accountSettings.isTwoFactorEnabled ? "已啟用" : "未啟用")
                        .font(.system(size: AppTheme.FontSize.caption))
                        .foregroundColor(AppTheme.whiteAlpha06)
                }

                Spacer()

                Toggle("", isOn: .constant(viewModel.user.accountSettings.isTwoFactorEnabled))
                    .labelsHidden()
                    .tint(AppTheme.gold)
                    .disabled(true) // 暫時禁用，待後續開發
            }
            .padding(AppTheme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                            .stroke(AppTheme.gold.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .padding(AppTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                        .stroke(AppTheme.gold.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Account Info Row Component

struct AccountInfoRow: View {
    let icon: String
    let title: String
    let value: String
    var showChevron: Bool = true

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppTheme.gold)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: AppTheme.FontSize.caption))
                    .foregroundColor(AppTheme.whiteAlpha06)

                Text(value)
                    .font(.system(size: AppTheme.FontSize.callout))
                    .foregroundColor(.white)
            }

            Spacer()

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.whiteAlpha06)
            }
        }
        .padding(AppTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                        .stroke(AppTheme.gold.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Security Option Button Component

struct SecurityOptionButton: View {
    let icon: String
    let title: String
    let description: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.gold)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                        .foregroundColor(.white)

                    Text(description)
                        .font(.system(size: AppTheme.FontSize.caption))
                        .foregroundColor(AppTheme.whiteAlpha06)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.whiteAlpha06)
            }
            .padding(AppTheme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                            .stroke(AppTheme.gold.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Preview

#Preview {
    AccountSecurityView(viewModel: UserProfileViewModel())
}
