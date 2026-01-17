/**
 * 成就系統頁面
 * 整合雲端護照成就系統
 */

import SwiftUI

struct AchievementView: View {
    // MARK: - Properties

    @ObservedObject var achievementManager: AchievementManager // 保留以避免編譯錯誤
    @StateObject private var userViewModel = UserProfileViewModel.shared

    // MARK: - State

    @State private var selectedAchievement: PassportAchievement?
    @State private var selectedCategory: PassportAchievementCategory?
    @State private var showDetailSheet = false

    // MARK: - Computed Properties

    private var achievements: [PassportAchievement] {
        return userViewModel.user.cloudPassport.achievements
    }

    private var filteredAchievements: [PassportAchievement] {
        if let category = selectedCategory {
            return achievements.filter { $0.category == category }
        }
        return achievements
    }

    private var unlockedAchievements: [PassportAchievement] {
        return achievements.filter { $0.isUnlocked }
    }

    private var totalRewardPoints: Int {
        return unlockedAchievements.reduce(0) { $0 + $1.rewardPoints }
    }

    private var completionPercentage: Int {
        guard !achievements.isEmpty else { return 0 }
        return Int((Double(unlockedAchievements.count) / Double(achievements.count)) * 100)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // 背景漸層
                AppTheme.darkGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xxl) {
                        // 頂部統計卡片
                        statsSection
                            .padding(.horizontal, AppTheme.Spacing.xl)
                            .padding(.top, AppTheme.Spacing.lg)

                        // 分類篩選
                        categoryFilter
                            .padding(.horizontal, AppTheme.Spacing.xl)

                        // 成就網格
                        achievementsGrid
                            .padding(.horizontal, AppTheme.Spacing.xl)

                        Spacer(minLength: AppTheme.Spacing.xxxl)
                    }
                }
            }
            .navigationTitle("成就系統")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showDetailSheet) {
                if let achievement = selectedAchievement {
                    AchievementDetailSheet(achievement: achievement)
                }
            }
        }
    }

    // MARK: - Components

    /// 統計區域
    private var statsSection: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // 主要統計
            HStack(spacing: AppTheme.Spacing.md) {
                // 已解鎖
                StatCard(
                    icon: "trophy.fill",
                    value: "\(unlockedAchievements.count)",
                    label: "已解鎖",
                    color: AppTheme.gold
                )

                // 完成率
                StatCard(
                    icon: "percent",
                    value: "\(completionPercentage)%",
                    label: "完成率",
                    color: Color(hex: "#10B981")
                )

                // 總獎勵
                StatCard(
                    icon: "star.fill",
                    value: "\(totalRewardPoints)",
                    label: "獲得福報",
                    color: Color(hex: "#F59E0B")
                )
            }

            // 分類統計
            categoryStatsRow
        }
    }

    /// 分類統計列
    private var categoryStatsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(PassportAchievementCategory.allCases, id: \.self) { category in
                    let categoryAchievements = achievements.filter { $0.category == category }
                    let unlockedCount = categoryAchievements.filter { $0.isUnlocked }.count

                    CategoryStatBadge(
                        category: category,
                        unlocked: unlockedCount,
                        total: categoryAchievements.count
                    )
                }
            }
        }
    }

    /// 分類篩選器
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.md) {
                // 全部
                FilterChip(
                    title: "全部",
                    icon: "square.grid.2x2.fill",
                    isSelected: selectedCategory == nil,
                    action: { selectedCategory = nil }
                )

                // 各分類
                ForEach(PassportAchievementCategory.allCases, id: \.self) { category in
                    FilterChip(
                        title: category.rawValue,
                        icon: category.iconName,
                        isSelected: selectedCategory == category,
                        action: { selectedCategory = category }
                    )
                }
            }
        }
    }

    /// 成就網格
    private var achievementsGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: AppTheme.Spacing.md),
                GridItem(.flexible(), spacing: AppTheme.Spacing.md),
                GridItem(.flexible(), spacing: AppTheme.Spacing.md)
            ],
            spacing: AppTheme.Spacing.md
        ) {
            ForEach(filteredAchievements) { achievement in
                AchievementGridItem(achievement: achievement)
                    .onTapGesture {
                        selectedAchievement = achievement
                        showDetailSheet = true
                    }
            }
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: AppTheme.FontSize.title3, weight: .bold))
                .foregroundColor(.white)

            Text(label)
                .font(.system(size: AppTheme.FontSize.caption2))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Category Stat Badge

struct CategoryStatBadge: View {
    let category: PassportAchievementCategory
    let unlocked: Int
    let total: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: category.iconName)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: category.color))

            Text("\(unlocked)/\(total)")
                .font(.system(size: AppTheme.FontSize.caption2, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.xs)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.1))
                .overlay(
                    Capsule()
                        .stroke(Color(hex: category.color).opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
            }
            .foregroundColor(isSelected ? AppTheme.dark : .white.opacity(0.8))
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(
                Capsule()
                    .fill(isSelected ? AppTheme.goldGradient : LinearGradient(colors: [Color.white.opacity(0.1)], startPoint: .leading, endPoint: .trailing))
                    .overlay(
                        Capsule()
                            .stroke(isSelected ? Color.clear : Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Achievement Grid Item

struct AchievementGridItem: View {
    let achievement: PassportAchievement

    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                    .fill(
                        achievement.isUnlocked ?
                            LinearGradient(
                                colors: [Color(hex: achievement.category.color), Color(hex: achievement.category.color).opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
                    .frame(height: 90)
                    .shadow(
                        color: achievement.isUnlocked ? Color(hex: achievement.category.color).opacity(0.3) : Color.clear,
                        radius: 8,
                        x: 0,
                        y: 4
                    )

                VStack {
                    // 分類圖標
                    HStack {
                        Image(systemName: achievement.category.iconName)
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                    }
                    .padding(6)
                    Spacer()
                }

                Image(systemName: achievement.iconName)
                    .font(.system(size: 36))
                    .foregroundColor(.white.opacity(achievement.isUnlocked ? 1.0 : 0.5))

                if !achievement.isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.8))
                        .offset(x: 30, y: -30)
                }
            }

            Text(achievement.name)
                .font(.system(size: AppTheme.FontSize.caption, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)

            // 進度顯示
            if !achievement.isUnlocked {
                Text("\(achievement.currentProgress)/\(achievement.requirement)")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.6))
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.green)
            }
        }
    }
}

// MARK: - Achievement Detail Sheet

struct AchievementDetailSheet: View {
    let achievement: PassportAchievement
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.darkGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xxl) {
                        // 大型圖標
                        ZStack {
                            // 背景漸層
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl)
                                .fill(
                                    achievement.isUnlocked ?
                                        LinearGradient(
                                            colors: [Color(hex: achievement.category.color), Color(hex: achievement.category.color).opacity(0.6)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ) :
                                        LinearGradient(
                                            colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.3)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                )
                                .frame(height: 300)
                                .shadow(
                                    color: achievement.isUnlocked ? Color(hex: achievement.category.color).opacity(0.5) : Color.clear,
                                    radius: 20,
                                    x: 0,
                                    y: 10
                                )

                            // 圖標
                            Image(systemName: achievement.iconName)
                                .font(.system(size: 120))
                                .foregroundColor(.white.opacity(achievement.isUnlocked ? 1.0 : 0.5))
                                .shadow(
                                    color: .black.opacity(0.3),
                                    radius: 10,
                                    x: 0,
                                    y: 5
                                )

                            // 分類標籤
                            VStack {
                                HStack {
                                    HStack(spacing: 4) {
                                        Image(systemName: achievement.category.iconName)
                                            .font(.system(size: 12))
                                        Text(achievement.category.rawValue)
                                            .font(.system(size: AppTheme.FontSize.caption, weight: .bold))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, AppTheme.Spacing.md)
                                    .padding(.vertical, AppTheme.Spacing.xs)
                                    .background(
                                        Capsule()
                                            .fill(Color.black.opacity(0.3))
                                    )
                                    .padding(AppTheme.Spacing.md)
                                    Spacer()
                                }
                                Spacer()
                            }

                            // 未解鎖鎖頭
                            if !achievement.isUnlocked {
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white.opacity(0.9))
                                            .padding(AppTheme.Spacing.xl)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, AppTheme.Spacing.xl)
                        .padding(.top, AppTheme.Spacing.lg)

                        // 資訊區域
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                            HStack {
                                Text(achievement.name)
                                    .font(.system(size: AppTheme.FontSize.title2, weight: .bold))
                                    .foregroundColor(.white)

                                Spacer()

                                // 獎勵點數
                                HStack(spacing: 4) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 16))
                                    Text("+\(achievement.rewardPoints)")
                                        .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                                }
                                .foregroundColor(AppTheme.gold)
                            }

                            Text(achievement.description)
                                .font(.system(size: AppTheme.FontSize.body))
                                .foregroundColor(.white.opacity(0.8))
                                .lineSpacing(6)

                            // 進度區域
                            if !achievement.isUnlocked {
                                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                                    HStack {
                                        Text("完成進度")
                                            .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                                            .foregroundColor(.white)

                                        Spacer()

                                        Text("\(achievement.currentProgress)/\(achievement.requirement)")
                                            .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                                            .foregroundColor(AppTheme.gold)
                                    }

                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.white.opacity(0.1))
                                                .frame(height: 16)

                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [Color(hex: achievement.category.color), Color(hex: achievement.category.color).opacity(0.8)],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .frame(
                                                    width: geometry.size.width * achievement.progress,
                                                    height: 16
                                                )
                                                .shadow(
                                                    color: Color(hex: achievement.category.color).opacity(0.5),
                                                    radius: 8,
                                                    x: 0,
                                                    y: 0
                                                )
                                        }
                                    }
                                    .frame(height: 16)

                                    Text("\(Int(achievement.progress * 100))% 完成")
                                        .font(.system(size: AppTheme.FontSize.callout))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .padding(AppTheme.Spacing.lg)
                                .background(
                                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                                        .fill(Color.white.opacity(0.05))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                )
                            } else {
                                // 已解鎖狀態
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 24))
                                    Text("已解鎖")
                                        .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                                }
                                .foregroundColor(.green)
                                .frame(maxWidth: .infinity)
                                .padding(AppTheme.Spacing.lg)
                                .background(
                                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                                        .fill(Color.green.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                        }
                        .padding(.horizontal, AppTheme.Spacing.xl)
                        .padding(.bottom, AppTheme.Spacing.xxxl)
                    }
                }
            }
            .navigationTitle("成就詳情")
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
}

// MARK: - Preview

#Preview {
    AchievementView(achievementManager: AchievementManager())
}
