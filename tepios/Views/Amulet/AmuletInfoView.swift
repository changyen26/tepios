/**
 * 平安符資訊頁面
 * 顯示用戶的平安符詳細資訊，支援左右滑動切換多個平安符
 */

import SwiftUI

struct AmuletInfoView: View {
    // MARK: - State

    @StateObject private var userViewModel = UserProfileViewModel.shared
    @State private var showBindAmulet = false
    @State private var showHistory = false
    @State private var currentIndex = 0
    @State private var cardRotation: Double = 0

    // MARK: - Computed Properties

    private var currentAmulet: Amulet? {
        guard !userViewModel.user.amulets.isEmpty, currentIndex < userViewModel.user.amulets.count else {
            return nil
        }
        return userViewModel.user.amulets[currentIndex]
    }

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
                            // 平安符卡片（可左右滑動）
                            TabView(selection: $currentIndex) {
                                ForEach(Array(userViewModel.user.amulets.enumerated()), id: \.element.id) { index, amulet in
                                    amuletCardSection(amulet)
                                        .tag(index)
                                }
                            }
                            .tabViewStyle(.page(indexDisplayMode: .always))
                            .indexViewStyle(.page(backgroundDisplayMode: .always))
                            .frame(height: 280)
                            .padding(.top, AppTheme.Spacing.sm)
                            .onChange(of: currentIndex) { _, _ in
                                // 切換卡片時重置旋轉
                                cardRotation = 0
                            }

                            // 當前平安符資訊
                            if let amulet = currentAmulet {
                                // 等級資訊
                                levelInfoSection(amulet)
                                    .padding(.horizontal, AppTheme.Spacing.xl)

                                // 綁定日期
                                bindDateSection(amulet)
                                    .padding(.horizontal, AppTheme.Spacing.xl)

                                // 福報值進度
                                meritProgressSection(amulet)
                                    .padding(.horizontal, AppTheme.Spacing.xl)

                                // 總累積福報值
                                totalMeritSection(amulet)
                                    .padding(.horizontal, AppTheme.Spacing.xl)

                                // 說明文字
                                descriptionText
                                    .padding(.horizontal, AppTheme.Spacing.xl)

                                // 查看歷史紀錄按鈕
                                historyButton
                                    .padding(.horizontal, AppTheme.Spacing.xl)
                            }

                            // 底部間距
                            Spacer(minLength: AppTheme.Spacing.xxxl)
                        }
                    }
                }
            }
            .task {
                // 啟動卡片 Y 軸 360 度旋轉動畫
                withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                    cardRotation = 360
                }
            }
            .navigationTitle("平安符")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showBindAmulet = true }) {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.system(size: 20))
                            .foregroundColor(AppTheme.gold)
                    }
                }
            }
            .sheet(isPresented: $showBindAmulet) {
                AmuletBindingView()
            }
            .fullScreenCover(isPresented: $showHistory) {
                AmuletHistoryView()
            }
        }
    }

    // MARK: - Components

    /// 平安符卡片區域（Y 軸 360 度旋轉）
    private func amuletCardSection(_ amulet: Amulet) -> some View {
        cardFrontSide(amulet)
            .rotation3DEffect(
                .degrees(cardRotation),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.5
            )
    }

    /// 卡片正面
    private func cardFrontSide(_ amulet: Amulet) -> some View {
        // 主卡片
        RoundedRectangle(cornerRadius: 18)
            .fill(
                LinearGradient(
                    colors: [Color(hex: "BDA138"), Color(hex: "D4B756")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 210, height: 280)
            .shadow(color: AppTheme.gold.opacity(0.6), radius: 20, x: 0, y: 10)
            .overlay(
                // 平安符圖案
                VStack(spacing: AppTheme.Spacing.sm) {
                    Spacer()

                    Image(systemName: "scroll.fill")
                        .font(.system(size: 70))
                        .foregroundColor(Color.black.opacity(0.8))

                    Text("平安符")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.black)

                    Spacer()
                }
            )
    }

    /// 卡片背面
    private func cardBackSide(_ amulet: Amulet) -> some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(
                LinearGradient(
                    colors: [Color(hex: "8B7335"), Color(hex: "A68A4A")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 210, height: 280)
            .shadow(color: AppTheme.gold.opacity(0.6), radius: 20, x: 0, y: 10)
            .overlay(
                VStack(spacing: AppTheme.Spacing.sm) {
                    // 廟宇名稱
                    Text(amulet.templeName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, AppTheme.Spacing.md)

                    Divider()
                        .background(Color.white.opacity(0.3))
                        .padding(.horizontal, AppTheme.Spacing.sm)

                    // 詳細資訊
                    VStack(spacing: 8) {
                        infoRow(label: "等級", value: "Lv.\(amulet.level)")
                        infoRow(label: "稱號", value: getLevelTitle(amulet.level))
                        infoRow(label: "當前福報", value: "\(amulet.currentPoints)")
                        infoRow(label: "累積福報", value: "\(amulet.totalPoints)")
                        infoRow(label: "綁定日期", value: formatDate(amulet.bindDate))
                    }
                    .padding(.horizontal, AppTheme.Spacing.sm)

                    Spacer()
                }
            )
    }

    /// 資訊行
    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: AppTheme.FontSize.callout))
                .foregroundColor(.white.opacity(0.8))

            Spacer()

            Text(value)
                .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                .foregroundColor(.white)
        }
    }

    /// 等級資訊區域
    private func levelInfoSection(_ amulet: Amulet) -> some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // 等級圓圈
            ZStack {
                Circle()
                    .fill(AppTheme.goldGradient)
                    .frame(width: 55, height: 55)
                    .shadow(color: AppTheme.gold.opacity(0.4), radius: 8)

                VStack(spacing: 2) {
                    Text("Lv")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppTheme.dark)

                    Text("\(amulet.level)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.dark)
                }
            }

            // 等級資訊
            VStack(alignment: .leading, spacing: 4) {
                Text(getLevelTitle(amulet.level))
                    .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                    .foregroundColor(AppTheme.gold)

                Text("再累積 100 點升級")
                    .font(.system(size: AppTheme.FontSize.caption))
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()
        }
        .padding(AppTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                        .stroke(AppTheme.gold.opacity(0.3), lineWidth: 1)
                )
        )
    }

    /// 綁定日期區域
    private func bindDateSection(_ amulet: Amulet) -> some View {
        HStack {
            Image(systemName: "calendar")
                .font(.system(size: 16))
                .foregroundColor(AppTheme.gold)

            Text("綁定日期：")
                .font(.system(size: AppTheme.FontSize.callout))
                .foregroundColor(.white.opacity(0.7))

            Text(formatDate(amulet.bindDate))
                .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                .foregroundColor(AppTheme.gold)

            Spacer()
        }
        .padding(AppTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                        .stroke(AppTheme.gold.opacity(0.2), lineWidth: 1)
                )
        )
    }

    /// 福報值進度區域
    private func meritProgressSection(_ amulet: Amulet) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                Text("福報值")
                    .font(.system(size: AppTheme.FontSize.callout, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))

                Spacer()

                Text("\(amulet.currentPoints)/100")
                    .font(.system(size: AppTheme.FontSize.callout, weight: .bold))
                    .foregroundColor(AppTheme.gold)
            }

            // 進度條
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 16)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppTheme.goldGradient)
                        .frame(
                            width: geometry.size.width * CGFloat(min(amulet.currentPoints, 100)) / 100.0,
                            height: 16
                        )
                }
            }
            .frame(height: 16)
        }
    }

    /// 總累積福報值區域
    private func totalMeritSection(_ amulet: Amulet) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text("總累積福報值")
                    .font(.system(size: AppTheme.FontSize.callout))
                    .foregroundColor(.white.opacity(0.6))

                Text("\(amulet.totalPoints)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(AppTheme.gold)
            }

            Spacer()

            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 40))
                .foregroundColor(AppTheme.gold.opacity(0.6))
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

    /// 說明文字
    private var descriptionText: some View {
        Text("每日打卡、祈福可累積福報值，福報值達到一定數量即可升級並解鎖更多功能")
            .font(.system(size: AppTheme.FontSize.caption))
            .foregroundColor(.white.opacity(0.5))
            .multilineTextAlignment(.center)
            .lineSpacing(4)
    }

    /// 查看歷史紀錄按鈕
    private var historyButton: some View {
        Button(action: { showHistory = true }) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 20))

                Text("查看歷史紀錄")
                    .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
            }
            .foregroundColor(AppTheme.dark)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(AppTheme.goldGradient)
            .cornerRadius(AppTheme.CornerRadius.lg)
            .shadow(
                color: AppTheme.gold.opacity(0.4),
                radius: 15,
                x: 0,
                y: 5
            )
        }
    }

    /// 空狀態
    private var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Image(systemName: "scroll")
                .font(.system(size: 100))
                .foregroundColor(.white.opacity(0.3))

            VStack(spacing: AppTheme.Spacing.sm) {
                Text("尚未綁定平安符")
                    .font(.system(size: AppTheme.FontSize.title3, weight: .bold))
                    .foregroundColor(.white)

                Text("請先到廟宇打卡綁定您的平安符")
                    .font(.system(size: AppTheme.FontSize.callout))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.xl)
    }

    // MARK: - Helper Methods

    private func getLevelTitle(_ level: Int) -> String {
        switch level {
        case 1:
            return "初階信徒"
        case 2:
            return "虔誠信徒"
        case 3:
            return "資深信徒"
        case 4:
            return "護法弟子"
        case 5:
            return "福德使者"
        default:
            return "初階信徒"
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
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
