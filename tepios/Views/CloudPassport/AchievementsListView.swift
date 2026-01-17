/**
 * 成就列表頁面
 * 展示所有成就的詳細資訊和進度
 */

import SwiftUI

struct AchievementsListView: View {
    // MARK: - State

    @Environment(\.dismiss) private var dismiss
    @StateObject private var userViewModel = UserProfileViewModel.shared
    @State private var selectedCategory: PassportAchievementCategory?

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.darkGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        // 總體進度卡片
                        overallProgressCard
                            .padding(.horizontal, AppTheme.Spacing.xl)
                            .padding(.top, AppTheme.Spacing.lg)

                        // 分類篩選
                        categoryFilter
                            .padding(.horizontal, AppTheme.Spacing.xl)

                        // 成就列表
                        achievementsList
                            .padding(.horizontal, AppTheme.Spacing.xl)
                            .padding(.bottom, AppTheme.Spacing.xxxl)
                    }
                }
            }
            .navigationTitle("成就系統")
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

    /// 總體進度卡片
    private var overallProgressCard: some View {
        let unlockedCount = userViewModel.user.cloudPassport.achievements.filter { $0.isUnlocked }.count
        let totalCount = PassportAchievement.allAchievements.count
        let progress = totalCount > 0 ? Double(unlockedCount) / Double(totalCount) : 0

        return VStack(spacing: AppTheme.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("成就進度")
                        .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                        .foregroundColor(.white)

                    Text("\(unlockedCount) / \(totalCount) 已解鎖")
                        .font(.system(size: AppTheme.FontSize.callout))
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 8)
                        .frame(width: 80, height: 80)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(AppTheme.gold, lineWidth: 8)
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))

                    Text("\(Int(progress * 100))%")
                        .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                        .foregroundColor(.white)
                }
            }
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
    }

    /// 分類篩選
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.md) {
                // 全部
                categoryChip(category: nil, label: "全部")

                // 各類別
                ForEach(PassportAchievementCategory.allCases, id: \.self) { category in
                    categoryChip(category: category, label: category.rawValue)
                }
            }
        }
    }

    private func categoryChip(category: PassportAchievementCategory?, label: String) -> some View {
        let isSelected = selectedCategory == category

        return Button(action: {
            withAnimation(.spring(response: 0.3)) {
                selectedCategory = category
            }
        }) {
            HStack(spacing: AppTheme.Spacing.sm) {
                if let category = category {
                    Image(systemName: category.iconName)
                        .font(.system(size: 14))
                }

                Text(label)
                    .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
            }
            .foregroundColor(isSelected ? AppTheme.dark : .white)
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? AppTheme.goldGradient : LinearGradient(colors: [Color.white.opacity(0.1)], startPoint: .leading, endPoint: .trailing))
            )
        }
    }

    /// 成就列表
    private var achievementsList: some View {
        let filteredAchievements = PassportAchievement.allAchievements.filter { achievement in
            if let selectedCategory = selectedCategory {
                return achievement.category == selectedCategory
            }
            return true
        }

        return LazyVStack(spacing: AppTheme.Spacing.md) {
            ForEach(filteredAchievements) { achievement in
                achievementCard(achievement)
            }
        }
    }

    private func achievementCard(_ achievement: PassportAchievement) -> some View {
        // 從用戶數據中獲取該成就的進度
        let userAchievement = userViewModel.user.cloudPassport.achievements.first { $0.id == achievement.id }
        let isUnlocked = userAchievement?.isUnlocked ?? false
        let progress = userAchievement?.progress ?? 0

        return VStack(spacing: AppTheme.Spacing.md) {
            HStack(alignment: .top, spacing: AppTheme.Spacing.md) {
                // 成就圖標
                ZStack {
                    Circle()
                        .fill(
                            isUnlocked
                                ? Color(hex: achievement.category.color).opacity(0.3)
                                : Color.white.opacity(0.1)
                        )
                        .frame(width: 60, height: 60)

                    Image(systemName: achievement.iconName)
                        .font(.system(size: 28))
                        .foregroundColor(
                            isUnlocked
                                ? Color(hex: achievement.category.color)
                                : .white.opacity(0.5)
                        )

                    if isUnlocked {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .offset(x: 20, y: -20)
                    }
                }

                // 成就資訊
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    // 成就名稱
                    Text(achievement.name)
                        .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                        .foregroundColor(isUnlocked ? .white : .white.opacity(0.6))

                    // 成就描述
                    Text(achievement.description)
                        .font(.system(size: AppTheme.FontSize.callout))
                        .foregroundColor(.white.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)

                    // 分類標籤
                    HStack(spacing: 4) {
                        Image(systemName: achievement.category.iconName)
                            .font(.system(size: 10))
                        Text(achievement.category.rawValue)
                            .font(.system(size: AppTheme.FontSize.caption, weight: .medium))
                    }
                    .foregroundColor(Color(hex: achievement.category.color))
                    .padding(.horizontal, AppTheme.Spacing.sm)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: achievement.category.color).opacity(0.2))
                    )

                    // 進度條（未解鎖時顯示）
                    if !isUnlocked {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("進度")
                                    .font(.system(size: AppTheme.FontSize.caption))
                                    .foregroundColor(.white.opacity(0.6))

                                Spacer()

                                Text("\(userAchievement?.currentProgress ?? 0) / \(achievement.requirement)")
                                    .font(.system(size: AppTheme.FontSize.caption, weight: .semibold))
                                    .foregroundColor(AppTheme.gold)
                            }

                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.white.opacity(0.2))
                                        .frame(height: 8)

                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(hex: achievement.category.color))
                                        .frame(width: geometry.size.width * progress, height: 8)
                                }
                            }
                            .frame(height: 8)
                        }
                    }

                    // 獎勵
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12))
                        Text("+\(achievement.rewardPoints) 福報值")
                            .font(.system(size: AppTheme.FontSize.caption, weight: .semibold))
                    }
                    .foregroundColor(isUnlocked ? .green : AppTheme.gold)
                }

                Spacer()
            }
        }
        .padding(AppTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                .fill(
                    isUnlocked
                        ? Color.white.opacity(0.15)
                        : Color.white.opacity(0.05)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                        .stroke(
                            isUnlocked
                                ? Color(hex: achievement.category.color).opacity(0.5)
                                : Color.white.opacity(0.1),
                            lineWidth: isUnlocked ? 2 : 1
                        )
                )
        )
    }
}

// MARK: - Preview

#Preview {
    AchievementsListView()
}
