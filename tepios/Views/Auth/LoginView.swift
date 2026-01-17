/**
 * 登入/註冊頁面
 * 參考：平安符打卡系統 PDF 第8頁第2張
 * 優化：流暢動畫、點擊空白處收回鍵盤
 */

import SwiftUI

struct LoginView: View {
    // MARK: - Properties

    @Binding var isLoggedIn: Bool

    // MARK: - State

    @State private var isLoginMode = true
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var confirmPassword = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showDeitySelection = false
    @State private var selectedDeity: Deity?
    @FocusState private var focusedField: Field?

    // MARK: - Focus Field Enum

    enum Field: Hashable {
        case name, email, password, confirmPassword
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // 背景漸層
            AppTheme.darkGradient
                .ignoresSafeArea()
                .onTapGesture {
                    // 點擊背景收回鍵盤
                    hideKeyboard()
                }

            ScrollView {
                VStack(spacing: AppTheme.Spacing.xxl) {
                    // Logo 區域
                    VStack(spacing: AppTheme.Spacing.lg) {
                        Image(systemName: "scroll.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(AppTheme.goldGradient)
                            .shadow(
                                color: AppTheme.gold.opacity(0.5),
                                radius: 20,
                                x: 0,
                                y: 10
                            )

                        Text("平安符打卡")
                            .font(.system(size: AppTheme.FontSize.title1, weight: .bold))
                            .foregroundColor(AppTheme.gold)
                            .tracking(4)

                        Text(isLoginMode ? "歡迎回來" : "加入我們")
                            .font(.system(size: AppTheme.FontSize.body))
                            .foregroundColor(AppTheme.whiteAlpha06)
                    }
                    .padding(.top, 60)
                    .onTapGesture {
                        hideKeyboard()
                    }

                    // 登入/註冊表單
                    VStack(spacing: AppTheme.Spacing.lg) {
                        // 註冊模式顯示姓名欄位
                        if !isLoginMode {
                            CustomTextField(
                                icon: "person.fill",
                                placeholder: "例：王曉明",
                                text: $name,
                                focusedField: $focusedField,
                                field: .name
                            )
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                        }

                        // Email 欄位
                        CustomTextField(
                            icon: "envelope.fill",
                            placeholder: "例：user@example.com",
                            text: $email,
                            focusedField: $focusedField,
                            field: .email,
                            keyboardType: .emailAddress
                        )

                        // 密碼欄位
                        CustomTextField(
                            icon: "lock.fill",
                            placeholder: "任意密碼即可登入",
                            text: $password,
                            focusedField: $focusedField,
                            field: .password,
                            isSecure: true
                        )

                        // 註冊模式顯示確認密碼
                        if !isLoginMode {
                            CustomTextField(
                                icon: "lock.fill",
                                placeholder: "再次輸入密碼",
                                text: $confirmPassword,
                                focusedField: $focusedField,
                                field: .confirmPassword,
                                isSecure: true
                            )
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                        }

                        // 登入/註冊按鈕
                        Button(action: handleSubmit) {
                            Text(isLoginMode ? "登入" : "註冊")
                                .font(.system(size: AppTheme.FontSize.headline, weight: .semibold))
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
                        .padding(.top, AppTheme.Spacing.lg)

                        // 切換登入/註冊模式
                        Button(action: {
                            hideKeyboard()
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                isLoginMode.toggle()
                                // 清空表單
                                if isLoginMode {
                                    name = ""
                                    confirmPassword = ""
                                }
                            }
                        }) {
                            HStack(spacing: 4) {
                                Text(isLoginMode ? "還沒有帳號？" : "已有帳號？")
                                    .foregroundColor(AppTheme.whiteAlpha06)
                                Text(isLoginMode ? "立即註冊" : "立即登入")
                                    .foregroundColor(AppTheme.gold)
                                    .fontWeight(.semibold)
                            }
                            .font(.system(size: AppTheme.FontSize.callout))
                        }
                        .padding(.top, AppTheme.Spacing.sm)
                    }
                    .padding(.horizontal, AppTheme.Spacing.xxl)
                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isLoginMode)

                    Spacer(minLength: 100)
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .alert("提示", isPresented: $showingAlert) {
            Button("確定", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .fullScreenCover(isPresented: $showDeitySelection) {
            DeitySelectionView(selectedDeity: $selectedDeity) {
                // 派系選擇完成後的處理
                // TODO: 這裡可以儲存選擇的神明到使用者資料
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isLoggedIn = true
                }
            }
        }
    }

    // MARK: - Methods

    private func handleSubmit() {
        hideKeyboard()

        // 驗證輸入
        if email.isEmpty || password.isEmpty {
            alertMessage = "請填寫所有必填欄位"
            showingAlert = true
            return
        }

        if !isLoginMode {
            if name.isEmpty {
                alertMessage = "請輸入姓名"
                showingAlert = true
                return
            }
            if password != confirmPassword {
                alertMessage = "密碼與確認密碼不相符"
                showingAlert = true
                return
            }

            // 註冊成功後顯示派系選擇頁面
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showDeitySelection = true
            }
        } else {
            // 登入成功直接進入主畫面
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isLoggedIn = true
            }
        }
    }

    private func hideKeyboard() {
        focusedField = nil
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Custom TextField Component

struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var focusedField: FocusState<LoginView.Field?>.Binding
    var field: LoginView.Field
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppTheme.gold)
                .frame(width: 24)

            if isSecure {
                SecureField(placeholder, text: $text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.5)))
                    .font(.system(size: AppTheme.FontSize.body))
                    .foregroundColor(AppTheme.white)
                    .focused(focusedField, equals: field)
                    .submitLabel(.next)
                    .onSubmit {
                        focusNextField()
                    }
            } else {
                TextField(placeholder, text: $text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.5)))
                    .font(.system(size: AppTheme.FontSize.body))
                    .foregroundColor(AppTheme.white)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused(focusedField, equals: field)
                    .submitLabel(.next)
                    .onSubmit {
                        focusNextField()
                    }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                .fill(Color.white.opacity(focusedField.wrappedValue == field ? 0.15 : 0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                        .stroke(
                            focusedField.wrappedValue == field ? AppTheme.gold : AppTheme.gold.opacity(0.3),
                            lineWidth: focusedField.wrappedValue == field ? 2 : 1
                        )
                )
        )
        .animation(.easeInOut(duration: 0.2), value: focusedField.wrappedValue == field)
    }

    private func focusNextField() {
        switch field {
        case .name:
            focusedField.wrappedValue = .email
        case .email:
            focusedField.wrappedValue = .password
        case .password:
            focusedField.wrappedValue = .confirmPassword
        case .confirmPassword:
            focusedField.wrappedValue = nil
        }
    }
}

// MARK: - Preview

#Preview {
    LoginView(isLoggedIn: .constant(false))
}
