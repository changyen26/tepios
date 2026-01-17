/**
 * 個人資訊編輯頁面
 */

import SwiftUI

struct PersonalInfoEditView: View {
    // MARK: - Properties

    @ObservedObject var viewModel: UserProfileViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    @State private var name: String
    @State private var nickname: String
    @State private var birthday: Date
    @State private var selectedGender: Gender
    @State private var phoneNumber: String
    @State private var address: String
    @State private var showAvatarPicker = false
    @State private var showBirthdayPicker = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    @FocusState private var focusedField: Field?

    enum Field {
        case name, nickname, phone, address
    }

    // MARK: - Initialization

    init(viewModel: UserProfileViewModel) {
        self.viewModel = viewModel
        _name = State(initialValue: viewModel.user.profile.name)
        _nickname = State(initialValue: viewModel.user.profile.nickname)
        _birthday = State(initialValue: viewModel.user.profile.birthday ?? Date())
        _selectedGender = State(initialValue: viewModel.user.profile.gender)
        _phoneNumber = State(initialValue: viewModel.user.profile.phoneNumber)
        _address = State(initialValue: viewModel.user.profile.address)
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
                        // 頭像編輯區域
                        avatarSection
                            .padding(.top, AppTheme.Spacing.xl)

                        // 表單欄位
                        VStack(spacing: AppTheme.Spacing.lg) {
                            // 姓名
                            FormField(
                                title: "姓名",
                                icon: "person.fill",
                                text: $name,
                                focusedField: $focusedField,
                                field: .name,
                                placeholder: "請輸入您的姓名"
                            )

                            // 暱稱
                            FormField(
                                title: "暱稱",
                                icon: "star.fill",
                                text: $nickname,
                                focusedField: $focusedField,
                                field: .nickname,
                                placeholder: "請輸入暱稱"
                            )

                            // 生日
                            birthdayField

                            // 性別
                            genderField

                            // 電話
                            FormField(
                                title: "電話",
                                icon: "phone.fill",
                                text: $phoneNumber,
                                focusedField: $focusedField,
                                field: .phone,
                                placeholder: "09XXXXXXXX",
                                keyboardType: .phonePad
                            )

                            // 地址
                            FormField(
                                title: "地址",
                                icon: "mappin.and.ellipse",
                                text: $address,
                                focusedField: $focusedField,
                                field: .address,
                                placeholder: "台北市中正區重慶南路一段122號"
                            )
                        }
                        .padding(.horizontal, AppTheme.Spacing.xl)
                        .padding(.bottom, 100)
                    }
                }

                // 儲存按鈕（固定在底部）
                VStack {
                    Spacer()
                    saveButton
                        .padding(.horizontal, AppTheme.Spacing.xl)
                        .padding(.bottom, AppTheme.Spacing.xxl)
                }
            }
            .navigationTitle("個人資訊")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.gold)
                }
            }
            .sheet(isPresented: $showAvatarPicker) {
                AvatarPickerView(viewModel: viewModel)
            }
            .alert("提示", isPresented: $showAlert) {
                Button("確定", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - Components

    private var avatarSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Button(action: {
                showAvatarPicker = true
            }) {
                ZStack(alignment: .bottomTrailing) {
                    // 頭像
                    if let avatarData = viewModel.user.profile.avatarData,
                       let uiImage = UIImage(data: avatarData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(AppTheme.gold, lineWidth: 3)
                            )
                    } else {
                        Circle()
                            .fill(AppTheme.goldGradient)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(AppTheme.dark)
                            )
                    }

                    // 編輯圖標
                    ZStack {
                        Circle()
                            .fill(AppTheme.gold)
                            .frame(width: 32, height: 32)

                        Image(systemName: "camera.fill")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.dark)
                    }
                    .offset(x: -5, y: -5)
                }
            }

            Text("點擊更換頭像")
                .font(.system(size: AppTheme.FontSize.caption))
                .foregroundColor(AppTheme.whiteAlpha06)
        }
    }

    private var birthdayField: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "calendar")
                    .foregroundColor(AppTheme.gold)
                    .frame(width: 24)

                Text("生日")
                    .font(.system(size: AppTheme.FontSize.callout, weight: .medium))
                    .foregroundColor(AppTheme.whiteAlpha08)
            }

            Button(action: {
                hideKeyboard()
                showBirthdayPicker.toggle()
            }) {
                HStack {
                    Text(formatDate(birthday))
                        .font(.system(size: AppTheme.FontSize.body))
                        .foregroundColor(.white)

                    Spacer()

                    Image(systemName: "chevron.down")
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

            if showBirthdayPicker {
                DatePicker(
                    "",
                    selection: $birthday,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .colorScheme(.dark)
                .environment(\.locale, Locale(identifier: "zh_TW"))
            }
        }
    }

    private var genderField: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "person.2.fill")
                    .foregroundColor(AppTheme.gold)
                    .frame(width: 24)

                Text("性別")
                    .font(.system(size: AppTheme.FontSize.callout, weight: .medium))
                    .foregroundColor(AppTheme.whiteAlpha08)
            }

            HStack(spacing: AppTheme.Spacing.md) {
                ForEach(Gender.allCases, id: \.self) { gender in
                    Button(action: {
                        selectedGender = gender
                    }) {
                        Text(gender.rawValue)
                            .font(.system(size: AppTheme.FontSize.callout))
                            .foregroundColor(selectedGender == gender ? AppTheme.dark : AppTheme.whiteAlpha08)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppTheme.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                    .fill(selectedGender == gender ? AppTheme.goldGradient : LinearGradient(colors: [Color.white.opacity(0.05)], startPoint: .top, endPoint: .bottom))
                            )
                    }
                }
            }
        }
    }

    private var saveButton: some View {
        Button(action: saveChanges) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.dark))
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                    Text("儲存變更")
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
        .disabled(viewModel.isLoading)
    }

    // MARK: - Methods

    private func saveChanges() {
        // 驗證輸入
        guard !name.isEmpty else {
            alertMessage = "請輸入姓名"
            showAlert = true
            return
        }

        if !phoneNumber.isEmpty && !viewModel.validatePhoneNumber(phoneNumber) {
            alertMessage = "電話號碼格式不正確"
            showAlert = true
            return
        }

        // 更新資料
        viewModel.updateProfile(
            name: name,
            nickname: nickname,
            birthday: birthday,
            gender: selectedGender,
            phoneNumber: phoneNumber,
            address: address
        )

        // 顯示成功訊息並關閉
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            dismiss()
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        formatter.locale = Locale(identifier: "zh_TW")
        return formatter.string(from: date)
    }

    private func hideKeyboard() {
        focusedField = nil
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Form Field Component

struct FormField: View {
    let title: String
    let icon: String
    @Binding var text: String
    var focusedField: FocusState<PersonalInfoEditView.Field?>.Binding
    var field: PersonalInfoEditView.Field
    var placeholder: String = ""
    var keyboardType: UIKeyboardType = .default

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

            TextField(placeholder, text: $text)
                .font(.system(size: AppTheme.FontSize.body))
                .foregroundColor(.white)
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
                .keyboardType(keyboardType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused(focusedField, equals: field)
                .submitLabel(.next)
        }
    }
}

// MARK: - Preview

#Preview {
    PersonalInfoEditView(viewModel: UserProfileViewModel())
}
