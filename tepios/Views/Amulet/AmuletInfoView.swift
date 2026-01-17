/**
 * 平安符資訊頁面
 * 顯示用戶的平安符列表和相關資訊
 */

import SwiftUI

struct AmuletInfoView: View {
    // MARK: - State

    @StateObject private var userViewModel = UserProfileViewModel.shared
    @State private var showBindAmulet = false
    @State private var selectedAmulet: Amulet?

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // 背景
                AppTheme.darkGradient
                    .ignoresSafeArea()

                if userViewModel.user.amulets.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: AppTheme.Spacing.xl) {
                            // 平安符列表
                            amuletsList
                                .padding(.top, AppTheme.Spacing.lg)

                            // 底部間距
                            Spacer(minLength: AppTheme.Spacing.xxxl)
                        }
                        .padding(.horizontal, AppTheme.Spacing.xl)
                    }
                }

                // 綁定平安符按鈕（浮動）
                VStack {
                    Spacer()
                    bindAmuletButton
                        .padding(.horizontal, AppTheme.Spacing.xl)
                        .padding(.bottom, AppTheme.Spacing.xxl)
                }
            }
            .navigationTitle("我的平安符")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showBindAmulet) {
                AmuletBindingView()
            }
            .sheet(item: $selectedAmulet) { amulet in
                AmuletDetailSheet(amulet: amulet)
            }
        }
    }

    // MARK: - Components

    private var amuletsList: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            ForEach(userViewModel.user.amulets, id: \.id) { amulet in
                AmuletCard(amulet: amulet)
                    .onTapGesture {
                        selectedAmulet = amulet
                    }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "scroll")
                .font(.system(size: 80))
                .foregroundColor(AppTheme.whiteAlpha06)

            Text("尚未綁定平安符")
                .font(.system(size: AppTheme.FontSize.title3, weight: .semibold))
                .foregroundColor(AppTheme.whiteAlpha08)

            Text("點擊下方按鈕綁定您的平安符")
                .font(.system(size: AppTheme.FontSize.callout))
                .foregroundColor(AppTheme.whiteAlpha06)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, AppTheme.Spacing.xl)
    }

    private var bindAmuletButton: some View {
        Button(action: { showBindAmulet = true }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))

                Text("綁定平安符")
                    .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
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
    }
}

// MARK: - Amulet Card

struct AmuletCard: View {
    let amulet: Amulet

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // 頭部
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(amulet.templeName)
                        .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                        .foregroundColor(.white)

                    Text("等級 \(amulet.level)")
                        .font(.system(size: AppTheme.FontSize.callout))
                        .foregroundColor(AppTheme.gold)
                }

                Spacer()

                // 平安符圖標
                ZStack {
                    Circle()
                        .fill(AppTheme.gold.opacity(0.2))
                        .frame(width: 60, height: 60)

                    Image(systemName: "scroll.fill")
                        .font(.system(size: 28))
                        .foregroundColor(AppTheme.gold)
                }
            }

            // 福報值進度
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                HStack {
                    Text("福報值")
                        .font(.system(size: AppTheme.FontSize.caption))
                        .foregroundColor(AppTheme.whiteAlpha06)

                    Spacer()

                    Text("\(amulet.currentPoints) / 100")
                        .font(.system(size: AppTheme.FontSize.caption, weight: .semibold))
                        .foregroundColor(.white)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppTheme.goldGradient)
                            .frame(width: geometry.size.width * CGFloat(min(amulet.currentPoints, 100)) / 100.0, height: 8)
                    }
                }
                .frame(height: 8)
            }

            // 統計資訊
            HStack(spacing: AppTheme.Spacing.md) {
                StatItem(icon: "calendar", value: formatDate(amulet.bindDate), label: "綁定日期")
                Divider()
                    .frame(height: 30)
                    .overlay(AppTheme.gold.opacity(0.3))
                StatItem(icon: "star.fill", value: "\(amulet.totalPoints)", label: "累積福報")
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
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
}

// MARK: - Stat Item

struct StatItem: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.gold)

                Text(value)
                    .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                    .foregroundColor(.white)
            }

            Text(label)
                .font(.system(size: AppTheme.FontSize.caption2))
                .foregroundColor(AppTheme.whiteAlpha06)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Amulet Detail Sheet

struct AmuletDetailSheet: View {
    let amulet: Amulet
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.darkGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        // 平安符圖標
                        ZStack {
                            Circle()
                                .fill(AppTheme.gold.opacity(0.2))
                                .frame(width: 120, height: 120)

                            Image(systemName: "scroll.fill")
                                .font(.system(size: 60))
                                .foregroundColor(AppTheme.gold)
                        }
                        .padding(.top, AppTheme.Spacing.xl)

                        // 詳細資訊
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                            AmuletDetailRow(title: "廟宇名稱", value: amulet.templeName)
                            AmuletDetailRow(title: "當前等級", value: "等級 \(amulet.level)")
                            AmuletDetailRow(title: "當前福報值", value: "\(amulet.currentPoints)")
                            AmuletDetailRow(title: "累積福報值", value: "\(amulet.totalPoints)")
                            AmuletDetailRow(title: "綁定日期", value: formatDate(amulet.bindDate))
                        }
                        .padding(AppTheme.Spacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                                .fill(Color.white.opacity(0.05))
                        )
                        .padding(.horizontal, AppTheme.Spacing.xl)
                    }
                }
            }
            .navigationTitle("平安符詳情")
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

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        formatter.locale = Locale(identifier: "zh_TW")
        return formatter.string(from: date)
    }
}

// MARK: - Amulet Detail Row

struct AmuletDetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: AppTheme.FontSize.callout))
                .foregroundColor(AppTheme.whiteAlpha06)

            Spacer()

            Text(value)
                .font(.system(size: AppTheme.FontSize.body, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Preview

#Preview {
    AmuletInfoView()
}
