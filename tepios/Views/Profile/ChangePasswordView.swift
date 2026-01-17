/**
 * 密碼修改頁面
 */

import SwiftUI

struct ChangePasswordView: View {
    // MARK: - Properties

    @ObservedObject var viewModel: UserProfileViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    @State private var oldPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showOldPassword = false
    @State private var showNewPassword = false
    @State private var showConfirmPassword = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var passwordStrength: PasswordStrength = .weak

    @FocusState private var focusedField: Field?

    enum Field {
        case oldPassword, newPassword, confirmPassword
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // 背景
                AppTheme.darkGradient
                    .ignoresSafeArea()
                    .onTapGesture {
                        hideKeyboard()
                    }

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xxl) {
                        // 說明文字
                        instructionSection
                            .padding(.top, AppTheme.Spacing.xl)

                        // 密碼欄位
                        VStack(spacing: AppTheme.Spacing.lg) {
                            // 舊密碼
                            PasswordField(
                                title: "舊密碼",
                                icon: "lock.fill",
                                password: $oldPassword,
                                showPassword: $showOldPassword,
                                focusedField: $focusedField,
                                field: .oldPassword,
                                placeholder: "請輸入舊密碼"
                            )

                            // 新密碼
                            PasswordField(
                                title: "新密碼",
                                icon: "key.fill",
                                password: $newPassword,
                                showPassword: $showNewPassword,
                                focusedField: $focusedField,
                                field: .newPassword,
                                placeholder: "請輸入新密碼"
                            )

                            // 密碼強度指示器
                            if !newPassword.isEmpty {
                                passwordStrengthIndicator
                            }

                            // 確認密碼
                            PasswordField(
                                title: "確認新密碼",
                                icon: "checkmark.shield.fill",
                                password: $confirmPassword,
                                showPassword: $showConfirmPassword,
                                focusedField: $focusedField,
                                field: .confirmPassword,
                                placeholder: "請再次輸入新密碼"
                            )

                            // 密碼匹配提示
                            if !confirmPassword.isEmpty {
                                passwordMatchIndicator
                            }
                        }
                        .padding(.horizontal, AppTheme.Spacing.xl)

                        // 密碼要求說明
                        passwordRequirementsSection
                            .padding(.horizontal, AppTheme.Spacing.xl)

                        Spacer()
                    }
                    .padding(.bottom, 100)
                }

                // 儲存按鈕（固定在底部）
                VStack {
                    Spacer()
                    saveButton
                        .padding(.horizontal, AppTheme.Spacing.xl)
                        .padding(.bottom, AppTheme.Spacing.xxl)
                }
            }
            .navigationTitle("修改密碼")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.gold)
                }
            }
            .alert("提示", isPresented: $showAlert) {
                Button("確定", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .onChange(of: newPassword) { _ in
                updatePasswordStrength()
            }
        }
    }

    // MARK: - Components

    private var instructionSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.gold)

            Text("為了保護您的帳號安全")
                .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                .foregroundColor(.white)

            Text("請設定一個強度高的新密碼")
                .font(.system(size: AppTheme.FontSize.callout))
                .foregroundColor(AppTheme.whiteAlpha06)
        }
    }

    private var passwordStrengthIndicator: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                Text("密碼強度：")
                    .font(.system(size: AppTheme.FontSize.caption))
                    .foregroundColor(AppTheme.whiteAlpha06)

                Text(passwordStrength.rawValue)
                    .font(.system(size: AppTheme.FontSize.caption, weight: .semibold))
                    .foregroundColor(strengthColor)
            }

            // 強度條
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(strengthColor)
                        .frame(width: geometry.size.width * strengthProgress, height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding(.horizontal, AppTheme.Spacing.xl)
    }

    private var passwordMatchIndicator: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(passwordsMatch ? .green : .red)

            Text(passwordsMatch ? "密碼相符" : "密碼不相符")
                .font(.system(size: AppTheme.FontSize.caption))
                .foregroundColor(passwordsMatch ? .green : .red)

            Spacer()
        }
        .padding(.horizontal, AppTheme.Spacing.xl)
    }

    private var passwordRequirementsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("密碼要求")
                .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                .foregroundColor(AppTheme.gold)

            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                RequirementRow(
                    text: "至少 8 個字元",
                    isMet: newPassword.count >= 8
                )

                RequirementRow(
                    text: "包含至少一個大寫字母 (A-Z)",
                    isMet: newPassword.range(of: "[A-Z]", options: .regularExpression) != nil
                )

                RequirementRow(
                    text: "包含至少一個小寫字母 (a-z)",
                    isMet: newPassword.range(of: "[a-z]", options: .regularExpression) != nil
                )

                RequirementRow(
                    text: "包含至少一個數字 (0-9)",
                    isMet: newPassword.range(of: "[0-9]", options: .regularExpression) != nil
                )
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

    private var saveButton: some View {
        Button(action: changePassword) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.dark))
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                    Text("確認修改")
                        .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                }
            }
            .foregroundColor(AppTheme.dark)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(AppTheme.goldGradient)
            .cornerRadius(AppTheme.CornerRadius.md)
            .shadow(
                color: AppTheme.gold.opacity(0.3),
                radius: 12,
                x: 0,
                y: 4
            )
        }
        .disabled(viewModel.isLoading || !isFormValid)
        .opacity(isFormValid ? 1.0 : 0.5)
    }

    // MARK: - Computed Properties

    private var passwordsMatch: Bool {
        !newPassword.isEmpty && !confirmPassword.isEmpty && newPassword == confirmPassword
    }

    private var isFormValid: Bool {
        !oldPassword.isEmpty &&
        !newPassword.isEmpty &&
        !confirmPassword.isEmpty &&
        passwordsMatch &&
        passwordStrength == .strong
    }

    private var strengthColor: Color {
        switch passwordStrength {
        case .weak:
            return .red
        case .medium:
            return .orange
        case .strong:
            return .green
        }
    }

    private var strengthProgress: CGFloat {
        switch passwordStrength {
        case .weak:
            return 0.33
        case .medium:
            return 0.66
        case .strong:
            return 1.0
        }
    }

    // MARK: - Methods

    private func updatePasswordStrength() {
        let validation = AccountSettings.validatePassword(newPassword)
        passwordStrength = validation.strength
    }

    private func changePassword() {
        let success = viewModel.changePassword(
            oldPassword: oldPassword,
            newPassword: newPassword,
            confirmPassword: confirmPassword
        )

        if success {
            alertMessage = "密碼已成功更新"
            showAlert = true

            // 延遲關閉
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        } else {
            alertMessage = viewModel.errorMessage ?? "修改密碼失敗"
            showAlert = true
        }
    }

    private func hideKeyboard() {
        focusedField = nil
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Password Field Component

struct PasswordField: View {
    let title: String
    let icon: String
    @Binding var password: String
    @Binding var showPassword: Bool
    var focusedField: FocusState<ChangePasswordView.Field?>.Binding
    var field: ChangePasswordView.Field
    var placeholder: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.gold)
                    .frame(width: 24)

                Text(title)
                    .font(.system(size: AppTheme.FontSize.callout, weight: .medium))
                    .foregroundColor(AppTheme.whiteAlpha08)
            }

            HStack {
                if showPassword {
                    TextField(placeholder, text: $password)
                        .font(.system(size: AppTheme.FontSize.body))
                        .foregroundColor(.white)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused(focusedField, equals: field)
                } else {
                    SecureField(placeholder, text: $password)
                        .font(.system(size: AppTheme.FontSize.body))
                        .foregroundColor(.white)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused(focusedField, equals: field)
                }

                Button(action: {
                    showPassword.toggle()
                }) {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(AppTheme.whiteAlpha06)
                        .font(.system(size: 16))
                }
            }
            .padding(AppTheme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                    .fill(Color.white.opacity(focusedField.wrappedValue == field ? 0.1 : 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                            .stroke(
                                focusedField.wrappedValue == field ? AppTheme.gold : AppTheme.gold.opacity(0.3),
                                lineWidth: focusedField.wrappedValue == field ? 2 : 1
                            )
                    )
            )
        }
    }
}

// MARK: - Requirement Row Component

struct RequirementRow: View {
    let text: String
    let isMet: Bool

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 14))
                .foregroundColor(isMet ? .green : AppTheme.whiteAlpha06)

            Text(text)
                .font(.system(size: AppTheme.FontSize.caption))
                .foregroundColor(isMet ? .green : AppTheme.whiteAlpha06)

            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    ChangePasswordView(viewModel: UserProfileViewModel())
}
