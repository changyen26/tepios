/**
 * 神明卡牌詳情頁面
 * 展示單張卡牌的完整資訊
 */

import SwiftUI

struct CardDetailView: View {
    // MARK: - Properties

    let card: DeityCard
    @Environment(\.dismiss) private var dismiss
    @StateObject private var cardVM = CardCollectionViewModel.shared

    // MARK: - Computed Properties

    private var isCollected: Bool {
        cardVM.isCardCollected(card.id)
    }

    private var collectedCard: CollectedCard? {
        cardVM.getCollectedCard(card.id)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // 背景漸層
                LinearGradient(
                    colors: [
                        Color(hex: card.rarity.color).opacity(0.3),
                        Color.black,
                        Color.black
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        // 卡牌大圖區域
                        cardImageSection
                            .padding(.top, AppTheme.Spacing.xl)

                        // 基本資訊
                        basicInfoSection
                            .padding(.horizontal, AppTheme.Spacing.xl)

                        // 屬性數值
                        statsSection
                            .padding(.horizontal, AppTheme.Spacing.xl)

                        // 保佑類型
                        blessingsSection
                            .padding(.horizontal, AppTheme.Spacing.xl)

                        // 神明介紹
                        descriptionSection
                            .padding(.horizontal, AppTheme.Spacing.xl)

                        // 收集資訊（如果已收集）
                        if isCollected, let collected = collectedCard {
                            collectionInfoSection(collected)
                                .padding(.horizontal, AppTheme.Spacing.xl)
                        }

                        // 相關廟宇（如果有）
                        if !card.templeIds.isEmpty {
                            relatedTemplesSection
                                .padding(.horizontal, AppTheme.Spacing.xl)
                        }

                        // 底部間距
                        Spacer(minLength: AppTheme.Spacing.xxxl)
                    }
                }
            }
            .navigationTitle(card.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("關閉") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: card.rarity.color))
                }

                // 最愛按鈕（已收集才顯示）
                if isCollected, let collected = collectedCard {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            cardVM.toggleFavorite(collected.id)
                        }) {
                            Image(systemName: collected.isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(collected.isFavorite ? .red : Color(hex: card.rarity.color))
                        }
                    }
                }
            }
        }
    }

    // MARK: - Components

    /// 卡牌大圖區域
    private var cardImageSection: some View {
        ZStack {
            // 卡牌背景
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: card.rarity.color),
                            Color(hex: card.rarity.glowColor)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 260, height: 360)
                .shadow(
                    color: Color(hex: card.rarity.color).opacity(0.6),
                    radius: 30,
                    x: 0,
                    y: 10
                )

            // 內容層
            VStack(spacing: 0) {
                // 頂部：稀有度和編號
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: card.rarity.icon)
                            .font(.system(size: 14))
                        Text(card.rarity.rawValue)
                            .font(.system(size: AppTheme.FontSize.caption, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.4))
                    )

                    Spacer()

                    Text(card.cardNumber)
                        .font(.system(size: AppTheme.FontSize.caption, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(AppTheme.Spacing.md)

                Spacer()

                // 底部：神明名稱和稱號
                VStack(spacing: 4) {
                    Text(card.name)
                        .font(.system(size: AppTheme.FontSize.title2, weight: .bold))
                        .foregroundColor(.white)

                    Text(card.title)
                        .font(.system(size: AppTheme.FontSize.callout))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.lg)
                .frame(maxWidth: .infinity)
                .background(
                    Color.black.opacity(0.5)
                        .blur(radius: 20)
                )
            }
            .frame(width: 260, height: 360)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg))

            // 未收集遮罩
            if !isCollected {
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                    .fill(Color.black.opacity(0.7))
                    .frame(width: 260, height: 360)
                    .overlay(
                        VStack(spacing: AppTheme.Spacing.sm) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white.opacity(0.6))

                            Text("尚未收集")
                                .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    )
            }

            // 等級標籤（已收集）
            if isCollected, let level = collectedCard?.level, level > 1 {
                VStack {
                    HStack {
                        Spacer()
                        Text("Lv.\(level)")
                            .font(.system(size: AppTheme.FontSize.body, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(AppTheme.gold)
                            )
                            .padding(AppTheme.Spacing.md)
                    }
                    Spacer()
                }
                .frame(width: 260, height: 360)
            }
        }
    }

    /// 基本資訊區域
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                // 類型
                HStack(spacing: 6) {
                    Image(systemName: card.type.icon)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: card.type.color))

                    Text(card.type.rawValue)
                        .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(
                    Capsule()
                        .fill(Color(hex: card.type.color).opacity(0.2))
                        .overlay(
                            Capsule()
                                .stroke(Color(hex: card.type.color).opacity(0.5), lineWidth: 1)
                        )
                )

                Spacer()
            }
        }
    }

    /// 屬性數值區域
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("屬性數值")
                .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                .foregroundColor(.white)

            HStack(spacing: AppTheme.Spacing.md) {
                statBar(label: "神力", value: card.power, color: .red)
                statBar(label: "智慧", value: card.wisdom, color: .blue)
                statBar(label: "福運", value: card.fortune, color: .green)
            }
        }
        .padding(AppTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }

    /// 屬性條
    private func statBar(label: String, value: Int, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: AppTheme.FontSize.caption, weight: .medium))
                .foregroundColor(.white.opacity(0.7))

            Text("\(value)")
                .font(.system(size: AppTheme.FontSize.title3, weight: .bold))
                .foregroundColor(color)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(value) / 100, height: 6)
                }
            }
            .frame(height: 6)
        }
        .frame(maxWidth: .infinity)
    }

    /// 保佑類型區域
    private var blessingsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("神明保佑")
                .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                .foregroundColor(.white)

            FlowLayout(spacing: AppTheme.Spacing.sm) {
                ForEach(card.blessings, id: \.self) { blessing in
                    HStack(spacing: 6) {
                        Image(systemName: blessing.icon)
                            .font(.system(size: 12))

                        Text(blessing.rawValue)
                            .font(.system(size: AppTheme.FontSize.caption, weight: .medium))
                    }
                    .foregroundColor(AppTheme.gold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(AppTheme.gold.opacity(0.2))
                            .overlay(
                                Capsule()
                                    .stroke(AppTheme.gold.opacity(0.5), lineWidth: 1)
                            )
                    )
                }
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

    /// 神明介紹區域
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("神明介紹")
                .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                .foregroundColor(.white)

            Text(card.description)
                .font(.system(size: AppTheme.FontSize.body))
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(6)
        }
        .padding(AppTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }

    /// 收集資訊區域
    private func collectionInfoSection(_ collected: CollectedCard) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("收集資訊")
                .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                .foregroundColor(.white)

            VStack(spacing: AppTheme.Spacing.sm) {
                cardInfoRow(
                    icon: collected.obtainMethod.icon,
                    label: "獲得方式",
                    value: collected.obtainMethod.rawValue
                )

                cardInfoRow(
                    icon: "calendar",
                    label: "獲得日期",
                    value: formatDate(collected.obtainedDate)
                )

                cardInfoRow(
                    icon: "arrow.up.circle.fill",
                    label: "卡牌等級",
                    value: "Lv.\(collected.level)"
                )
            }
        }
        .padding(AppTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                .fill(AppTheme.gold.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                        .stroke(AppTheme.gold.opacity(0.3), lineWidth: 1)
                )
        )
    }

    /// 相關廟宇區域
    private var relatedTemplesSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("相關廟宇")
                .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                .foregroundColor(.white)

            Text("在這些廟宇打卡有機會獲得此卡牌")
                .font(.system(size: AppTheme.FontSize.caption))
                .foregroundColor(.white.opacity(0.6))

            // 這裡可以顯示相關廟宇列表
            // 暫時顯示數量
            Text("共 \(card.templeIds.count) 間廟宇")
                .font(.system(size: AppTheme.FontSize.callout))
                .foregroundColor(AppTheme.gold)
        }
        .padding(AppTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }

    /// 資訊行
    private func cardInfoRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.gold)
                .frame(width: 20)

            Text(label)
                .font(.system(size: AppTheme.FontSize.callout))
                .foregroundColor(.white.opacity(0.7))

            Spacer()

            Text(value)
                .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                .foregroundColor(.white)
        }
    }

    // MARK: - Helper Methods

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        formatter.locale = Locale(identifier: "zh_TW")
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview {
    CardDetailView(card: DeityCard.mockCards[0])
}
