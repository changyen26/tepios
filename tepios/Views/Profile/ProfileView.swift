/**
 * 個人帳號頁面
 * 參考：平安符打卡系統 PDF 第8頁第1張
 */

import SwiftUI

struct ProfileView: View {
    // MARK: - Properties

    @StateObject private var viewModel = UserProfileViewModel()

    // MARK: - State

    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showPersonalInfoEdit = false
    @State private var showAccountSecurity = false
    @State private var showDeityPicker = false
    @State private var showFamilyFriend = false
    @State private var selectedDeity: Deity?
    @Environment(\.dismiss) private var dismiss

    private let profileOptions = [
        ProfileOption(
            id: "info",
            icon: "person.fill",
            title: "個人資訊",
            description: "編輯姓名、生日等基本資料"
        ),
        ProfileOption(
            id: "account",
            icon: "lock.fill",
            title: "帳號與密碼",
            description: "修改帳號、密碼等安全設定"
        ),
        ProfileOption(
            id: "privacy",
            icon: "hand.raised.fill",
            title: "資料與隱私",
            description: "管理隱私設定與資料使用"
        ),
        ProfileOption(
            id: "family",
            icon: "person.3.fill",
            title: "家人好友系統",
            description: "管理家人好友關係"
        ),
        ProfileOption(
            id: "payment",
            icon: "creditcard.fill",
            title: "付款與訂閱",
            description: "管理付款方式與訂閱服務"
        )
    ]

    // MARK: - Body

    var body: some View {
        ZStack {
            // 背景漸層
            AppTheme.darkGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppTheme.Spacing.xxxl) {
                    // 頂部用戶資訊區域
                    userHeader
                        .padding(.top, AppTheme.Spacing.xxxl)

                    // 信仰神明卡片
                    deityCard
                        .padding(.horizontal, AppTheme.Spacing.xl)

                    // 個人帳號選項列表
                    VStack(spacing: AppTheme.Spacing.md) {
                        ForEach(Array(profileOptions.enumerated()), id: \.element.id) { index, option in
                            ProfileOptionCard(
                                option: option,
                                index: index
                            )
                            .onTapGesture {
                                handleOptionTap(option)
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .padding(.bottom, AppTheme.Spacing.xxxl)
                }
            }

            // 右上角資訊圖標
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        alertMessage = "這裡可以查看更多資訊"
                        showingAlert = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.gold.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(AppTheme.gold.opacity(0.3), lineWidth: 1)
                                )

                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(AppTheme.gold)
                        }
                    }
                    .padding(.top, AppTheme.Spacing.lg)
                    .padding(.trailing, AppTheme.Spacing.lg)
                }
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(false)
        .alert("提示", isPresented: $showingAlert) {
            Button("確定", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showPersonalInfoEdit) {
            PersonalInfoEditView(viewModel: viewModel)
        }
        .sheet(isPresented: $showAccountSecurity) {
            AccountSecurityView(viewModel: viewModel)
        }
        .sheet(isPresented: $showDeityPicker) {
            DeitySelectionView(
                selectedDeity: $selectedDeity,
                onComplete: {
                    showDeityPicker = false
                    if let deity = selectedDeity {
                        viewModel.updateProfile(deityId: deity.id)
                    }
                }
            )
        }
        .sheet(isPresented: $showFamilyFriend) {
            FamilyFriendListView()
        }
        .onAppear {
            selectedDeity = viewModel.getCurrentDeity()
        }
    }

    // MARK: - Components

    private var userHeader: some View {
        VStack(spacing: AppTheme.Spacing.xxl) {
            // 用戶頭像
            ZStack {
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
                        .shadow(
                            color: AppTheme.gold.opacity(0.3),
                            radius: 12,
                            x: 0,
                            y: 8
                        )
                } else {
                    Circle()
                        .fill(AppTheme.goldGradient)
                        .frame(width: 100, height: 100)
                        .shadow(
                            color: AppTheme.gold.opacity(0.3),
                            radius: 12,
                            x: 0,
                            y: 8
                        )
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 48))
                                .foregroundColor(AppTheme.dark)
                        )
                }
            }

            // 用戶資訊
            VStack(spacing: AppTheme.Spacing.xs) {
                Text(viewModel.user.profile.name)
                    .font(.system(size: AppTheme.FontSize.title2, weight: .bold))
                    .foregroundColor(AppTheme.gold)

                Text(viewModel.user.profile.nickname)
                    .font(.system(size: AppTheme.FontSize.callout))
                    .foregroundColor(AppTheme.whiteAlpha06)
            }

            // 問候語
            VStack(spacing: AppTheme.Spacing.xs) {
                Text("【祝您有個美好的一天】")
                    .font(.system(size: AppTheme.FontSize.callout, weight: .medium))
                    .foregroundColor(AppTheme.whiteAlpha08)

                Text("祝您身體健康 福運滿滿")
                    .font(.system(size: AppTheme.FontSize.callout, weight: .medium))
                    .foregroundColor(AppTheme.whiteAlpha08)
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
            .padding(.horizontal, AppTheme.Spacing.xl)
        }
    }

    private var deityCard: some View {
        Button(action: {
            showDeityPicker = true
        }) {
            VStack(spacing: AppTheme.Spacing.md) {
                // 標題
                HStack {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.gold)

                    Text("我的信仰")
                        .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                        .foregroundColor(AppTheme.gold)

                    Spacer()

                    Text("更換")
                        .font(.system(size: AppTheme.FontSize.caption))
                        .foregroundColor(AppTheme.gold.opacity(0.8))

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.gold.opacity(0.6))
                }

                Divider()
                    .background(AppTheme.gold.opacity(0.2))

                // 神明資訊
                if let deity = viewModel.getCurrentDeity() {
                    HStack(spacing: AppTheme.Spacing.lg) {
                        // 神明圖標
                        ZStack {
                            Circle()
                                .fill(Color(hex: deity.color).opacity(0.2))
                                .frame(width: 60, height: 60)

                            Image(systemName: deity.iconName)
                                .font(.system(size: 28))
                                .foregroundColor(Color(hex: deity.color))
                        }

                        // 神明詳情
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                            Text(deity.displayName)
                                .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                                .foregroundColor(.white)

                            Text(deity.description)
                                .font(.system(size: AppTheme.FontSize.caption))
                                .foregroundColor(AppTheme.whiteAlpha06)
                                .lineLimit(2)

                            // 屬性標籤
                            HStack(spacing: AppTheme.Spacing.xs) {
                                ForEach(deity.attributes.prefix(3), id: \.self) { attribute in
                                    Text(attribute)
                                        .font(.system(size: AppTheme.FontSize.caption2))
                                        .foregroundColor(Color(hex: deity.color))
                                        .padding(.horizontal, AppTheme.Spacing.sm)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(Color(hex: deity.color).opacity(0.2))
                                        )
                                }
                            }
                        }

                        Spacer()
                    }
                } else {
                    // 未選擇神明
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.gold.opacity(0.6))

                        Text("點擊選擇您的信仰神明")
                            .font(.system(size: AppTheme.FontSize.body))
                            .foregroundColor(AppTheme.whiteAlpha06)

                        Spacer()
                    }
                    .padding(.vertical, AppTheme.Spacing.md)
                }
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
            .shadow(
                color: AppTheme.gold.opacity(0.1),
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Methods

    private func handleOptionTap(_ option: ProfileOption) {
        switch option.id {
        case "info":
            showPersonalInfoEdit = true
        case "account":
            showAccountSecurity = true
        case "family":
            showFamilyFriend = true
        default:
            alertMessage = "\(option.title)功能開發中"
            showingAlert = true
        }
    }
}

// MARK: - Profile Option Model

struct ProfileOption: Identifiable {
    let id: String
    let icon: String
    let title: String
    let description: String
}

// MARK: - Profile Option Card

struct ProfileOptionCard: View {
    let option: ProfileOption
    let index: Int

    var body: some View {
        HStack(spacing: AppTheme.Spacing.lg) {
            // 圖標
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                    .fill(AppTheme.gold.opacity(0.15))
                    .frame(width: 48, height: 48)

                Image(systemName: option.icon)
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.gold)
            }

            // 內容
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(option.title)
                    .font(.system(size: AppTheme.FontSize.body, weight: .semibold))
                    .foregroundColor(AppTheme.gold)

                Text(option.description)
                    .font(.system(size: AppTheme.FontSize.caption))
                    .foregroundColor(AppTheme.whiteAlpha06)
                    .lineLimit(1)
            }

            Spacer()

            // 箭頭
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.gold.opacity(0.6))
        }
        .padding(AppTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                        .stroke(AppTheme.gold.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ProfileView()
    }
}
