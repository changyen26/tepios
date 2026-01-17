/**
 * 家人好友列表頁面
 */

import SwiftUI

struct FamilyFriendListView: View {
    // MARK: - State

    @StateObject private var userViewModel = UserProfileViewModel.shared
    @State private var showAddFriend = false
    @State private var showPrayerView = false
    @State private var selectedFriend: FamilyFriend?

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.darkGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        // 如果沒有家人好友，顯示空狀態
                        if userViewModel.user.familyFriends.isEmpty {
                            emptyStateView
                                .padding(.top, 100)
                        } else {
                            // 家人區塊
                            familySection

                            // 好友區塊
                            friendSection
                        }

                        Spacer(minLength: AppTheme.Spacing.xxxl)
                    }
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .padding(.top, AppTheme.Spacing.lg)
                }
            }
            .navigationTitle("家人好友")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddFriend = true }) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 20))
                            .foregroundColor(AppTheme.gold)
                    }
                }
            }
            .sheet(isPresented: $showAddFriend) {
                AddFriendView()
            }
            .sheet(item: $selectedFriend) { friend in
                PrayerView(friend: friend)
            }
        }
    }

    // MARK: - Components

    /// 空狀態視圖
    private var emptyStateView: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.3))

            VStack(spacing: AppTheme.Spacing.sm) {
                Text("還沒有家人好友")
                    .font(.system(size: AppTheme.FontSize.title2, weight: .bold))
                    .foregroundColor(.white)

                Text("點擊右上角加號添加家人或好友\n與他們分享信仰之旅")
                    .font(.system(size: AppTheme.FontSize.callout))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }

            Button(action: { showAddFriend = true }) {
                HStack {
                    Image(systemName: "person.badge.plus")
                    Text("添加家人好友")
                        .font(.system(size: AppTheme.FontSize.headline, weight: .semibold))
                }
                .foregroundColor(AppTheme.dark)
                .padding(.horizontal, AppTheme.Spacing.xl)
                .padding(.vertical, AppTheme.Spacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                        .fill(AppTheme.goldGradient)
                )
            }
        }
    }

    /// 家人區塊
    private var familySection: some View {
        let familyMembers = userViewModel.user.familyFriends.filter { $0.relationship == .family }

        return Group {
            if !familyMembers.isEmpty {
                VStack(spacing: AppTheme.Spacing.md) {
                    sectionHeader(
                        icon: "person.2.fill",
                        title: "家人",
                        count: familyMembers.count,
                        color: Color(hex: Relationship.family.color)
                    )

                    ForEach(familyMembers) { friend in
                        friendCard(friend)
                    }
                }
            }
        }
    }

    /// 好友區塊
    private var friendSection: some View {
        let friends = userViewModel.user.familyFriends.filter { $0.relationship == .friend }

        return Group {
            if !friends.isEmpty {
                VStack(spacing: AppTheme.Spacing.md) {
                    sectionHeader(
                        icon: "person.fill",
                        title: "好友",
                        count: friends.count,
                        color: Color(hex: Relationship.friend.color)
                    )

                    ForEach(friends) { friend in
                        friendCard(friend)
                    }
                }
            }
        }
    }

    /// 區塊標題
    private func sectionHeader(icon: String, title: String, count: Int, color: Color) -> some View {
        HStack {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                    .foregroundColor(.white)
                Text("(\(count))")
                    .font(.system(size: AppTheme.FontSize.callout))
                    .foregroundColor(.white.opacity(0.6))
            }
            Spacer()
        }
    }

    /// 好友卡片
    private func friendCard(_ friend: FamilyFriend) -> some View {
        Button(action: {
            selectedFriend = friend
        }) {
            HStack(spacing: AppTheme.Spacing.md) {
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
                        .frame(width: 60, height: 60)

                    if let avatarData = friend.avatarData,
                       let uiImage = UIImage(data: avatarData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color(hex: friend.relationship.color))
                    }
                }

                // 資訊
                VStack(alignment: .leading, spacing: 4) {
                    Text(friend.displayName)
                        .font(.system(size: AppTheme.FontSize.headline, weight: .semibold))
                        .foregroundColor(.white)

                    // Mock 數據 - 實際應該從後端獲取
                    HStack(spacing: AppTheme.Spacing.sm) {
                        Text("Lv.15 虔誠弟子")
                            .font(.system(size: AppTheme.FontSize.caption))
                            .foregroundColor(AppTheme.gold)

                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 3, height: 3)

                        Text("連續打卡 30 天")
                            .font(.system(size: AppTheme.FontSize.caption))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }

                Spacer()

                // 祈福按鈕
                VStack(spacing: 4) {
                    Image(systemName: "hands.sparkles.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.gold)

                    Text("祈福")
                        .font(.system(size: AppTheme.FontSize.caption, weight: .medium))
                        .foregroundColor(AppTheme.gold)
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm)
                        .fill(AppTheme.gold.opacity(0.2))
                )
            }
            .padding(AppTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    FamilyFriendListView()
}
