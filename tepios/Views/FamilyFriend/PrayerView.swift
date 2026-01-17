/**
 * 祈福頁面
 */

import SwiftUI

struct PrayerView: View {
    // MARK: - Properties

    let friend: FamilyFriend

    // MARK: - State

    @Environment(\.dismiss) private var dismiss
    @StateObject private var userViewModel = UserProfileViewModel.shared
    @State private var prayerMessage = ""
    @State private var showConfirmation = false
    @State private var showSuccess = false
    @FocusState private var isMessageFocused: Bool

    // MARK: - Constants

    private let meritCost = 10
    private let meritReward = 20

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.darkGradient
                    .ignoresSafeArea()
                    .onTapGesture {
                        isMessageFocused = false
                    }

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xxl) {
                        // 對象資訊
                        recipientInfo
                            .padding(.top, AppTheme.Spacing.xl)

                        // 福報消耗說明
                        meritInfo

                        // 祝福留言
                        messageSection

                        // 確認按鈕
                        confirmButton
                            .padding(.bottom, AppTheme.Spacing.xxxl)
                    }
                    .padding(.horizontal, AppTheme.Spacing.xl)
                }

                // 成功動畫覆蓋層
                if showSuccess {
                    successOverlay
                }
            }
            .navigationTitle("為好友祈福")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("關閉") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.gold)
                }
            }
            .alert("確認祈福", isPresented: $showConfirmation) {
                Button("取消", role: .cancel) {}
                Button("確認") {
                    performPrayer()
                }
            } message: {
                Text("將消耗 \(meritCost) 福報值為 \(friend.displayName) 祈福\n對方將獲得 \(meritReward) 福報值")
            }
        }
    }

    // MARK: - Components

    /// 對象資訊
    private var recipientInfo: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // 頭像
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: friend.relationship.color).opacity(0.3),
                                Color(hex: friend.relationship.color).opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                if let avatarData = friend.avatarData,
                   let uiImage = UIImage(data: avatarData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: friend.relationship.color))
                }

                // 關係標籤
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(friend.relationship.rawValue)
                            .font(.system(size: AppTheme.FontSize.caption2, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: friend.relationship.color))
                            )
                            .offset(x: 8, y: 8)
                    }
                }
                .frame(width: 100, height: 100)
            }

            // 名稱
            Text(friend.displayName)
                .font(.system(size: AppTheme.FontSize.title2, weight: .bold))
                .foregroundColor(.white)
        }
    }

    /// 福報消耗說明
    private var meritInfo: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.xl) {
                // 你的消耗
                VStack(spacing: AppTheme.Spacing.sm) {
                    Text("你的消耗")
                        .font(.system(size: AppTheme.FontSize.caption, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))

                    HStack(spacing: 4) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.red)
                        Text("\(meritCost)")
                            .font(.system(size: AppTheme.FontSize.title2, weight: .bold))
                            .foregroundColor(.red)
                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                    }
                }
                .frame(maxWidth: .infinity)

                // 分隔線
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 1, height: 60)

                // 對方獲得
                VStack(spacing: AppTheme.Spacing.sm) {
                    Text("對方獲得")
                        .font(.system(size: AppTheme.FontSize.caption, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))

                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                        Text("\(meritReward)")
                            .font(.system(size: AppTheme.FontSize.title2, weight: .bold))
                            .foregroundColor(.green)
                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                            .foregroundColor(.green)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(AppTheme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                            .stroke(AppTheme.gold.opacity(0.3), lineWidth: 2)
                    )
            )

            // 當前福報值
            HStack {
                Text("當前福報值：")
                    .font(.system(size: AppTheme.FontSize.callout))
                    .foregroundColor(.white.opacity(0.7))

                Text("\(userViewModel.user.cloudPassport.currentMeritPoints)")
                    .font(.system(size: AppTheme.FontSize.callout, weight: .bold))
                    .foregroundColor(
                        userViewModel.user.cloudPassport.currentMeritPoints >= meritCost
                            ? AppTheme.gold
                            : .red
                    )

                Image(systemName: "sparkles")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.gold)
            }
        }
    }

    /// 祝福留言區域
    private var messageSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("祝福留言（選填）")
                .font(.system(size: AppTheme.FontSize.headline, weight: .semibold))
                .foregroundColor(.white)

            ZStack(alignment: .topLeading) {
                if prayerMessage.isEmpty {
                    Text("寫下您的祝福...")
                        .font(.system(size: AppTheme.FontSize.body))
                        .foregroundColor(.white.opacity(0.4))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 16)
                }

                TextEditor(text: $prayerMessage)
                    .font(.system(size: AppTheme.FontSize.body))
                    .foregroundColor(.white)
                    .scrollContentBackground(.hidden)
                    .frame(height: 120)
                    .padding(8)
                    .focused($isMessageFocused)
            }
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                    .fill(Color.white.opacity(isMessageFocused ? 0.1 : 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                            .stroke(
                                isMessageFocused ? AppTheme.gold : Color.white.opacity(0.2),
                                lineWidth: isMessageFocused ? 2 : 1
                            )
                    )
            )
        }
    }

    /// 確認按鈕
    private var confirmButton: some View {
        Button(action: {
            isMessageFocused = false
            showConfirmation = true
        }) {
            HStack {
                Image(systemName: "hands.sparkles.fill")
                Text("確認祈福")
                    .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
            }
            .foregroundColor(AppTheme.dark)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                    .fill(
                        userViewModel.user.cloudPassport.currentMeritPoints >= meritCost
                            ? AppTheme.goldGradient
                            : LinearGradient(colors: [Color.gray], startPoint: .leading, endPoint: .trailing)
                    )
                    .shadow(
                        color: userViewModel.user.cloudPassport.currentMeritPoints >= meritCost
                            ? AppTheme.gold.opacity(0.3)
                            : Color.clear,
                        radius: 12,
                        x: 0,
                        y: 4
                    )
            )
        }
        .disabled(userViewModel.user.cloudPassport.currentMeritPoints < meritCost)
    }

    /// 成功動畫覆蓋層
    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            VStack(spacing: AppTheme.Spacing.xl) {
                // 動畫圖標
                ZStack {
                    Circle()
                        .fill(AppTheme.goldGradient)
                        .frame(width: 120, height: 120)
                        .shadow(color: AppTheme.gold.opacity(0.5), radius: 30, x: 0, y: 10)

                    Image(systemName: "hands.sparkles.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppTheme.dark)
                }

                VStack(spacing: AppTheme.Spacing.md) {
                    Text("祈福成功")
                        .font(.system(size: AppTheme.FontSize.title1, weight: .bold))
                        .foregroundColor(.white)

                    Text("已為 \(friend.displayName) 送上祝福")
                        .font(.system(size: AppTheme.FontSize.callout))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showSuccess = false
                }
                dismiss()
            }
        }
    }

    // MARK: - Methods

    /// 執行祈福
    private func performPrayer() {
        // 檢查福報值是否足夠
        guard userViewModel.user.cloudPassport.currentMeritPoints >= meritCost else {
            return
        }

        // 扣除福報值
        userViewModel.user.cloudPassport.currentMeritPoints -= meritCost

        // 創建祈福記錄
        let prayer = PrayerRecord(
            fromUserId: userViewModel.user.id,
            fromUserName: userViewModel.user.profile.name,
            toUserId: friend.userId,
            toUserName: friend.displayName,
            message: prayerMessage.isEmpty ? nil : prayerMessage,
            meritPoints: meritReward
        )

        // 添加到祈福記錄
        userViewModel.user.prayerRecords.append(prayer)

        // 儲存用戶資料
        userViewModel.saveUser()

        // 顯示成功動畫
        withAnimation {
            showSuccess = true
        }
    }
}

// MARK: - Preview

#Preview {
    PrayerView(
        friend: FamilyFriend(
            userId: "123",
            displayName: "媽媽",
            relationship: .family
        )
    )
}
