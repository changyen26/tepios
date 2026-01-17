/**
 * 神明卡牌圖鑑主頁面
 * 展示所有可收集的神明卡牌
 */

import SwiftUI

struct CardCollectionView: View {
    // MARK: - State

    @Environment(\.dismiss) private var dismiss
    @StateObject private var cardVM = CardCollectionViewModel.shared
    @State private var selectedRarity: CardRarity? = nil
    @State private var selectedType: DeityType? = nil
    @State private var selectedCard: DeityCard? = nil
    @State private var showCardDetail = false
    @State private var showGacha = false

    // MARK: - Computed Properties

    private var filteredCards: [DeityCard] {
        var cards = cardVM.allCards

        if let rarity = selectedRarity {
            cards = cards.filter { $0.rarity == rarity }
        }

        if let type = selectedType {
            cards = cards.filter { $0.type == type }
        }

        return cards.sorted { $0.rarity.rawValue > $1.rarity.rawValue }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // 背景
                AppTheme.darkGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        // 收集進度卡片
                        progressCard
                            .padding(.horizontal, AppTheme.Spacing.xl)
                            .padding(.top, AppTheme.Spacing.md)

                        // 稀有度統計
                        rarityStatsSection
                            .padding(.horizontal, AppTheme.Spacing.xl)

                        // 篩選器
                        filterSection

                        // 卡牌網格
                        cardsGrid
                            .padding(.horizontal, AppTheme.Spacing.xl)

                        // 底部間距
                        Spacer(minLength: AppTheme.Spacing.xxxl * 2)
                    }
                }

                // 浮動抽卡按鈕
                VStack {
                    Spacer()
                    gachaButton
                        .padding(.horizontal, AppTheme.Spacing.xl)
                        .padding(.bottom, AppTheme.Spacing.xxl)
                }
            }
            .navigationTitle("神明圖鑑")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("返回")
                                .font(.system(size: AppTheme.FontSize.body))
                        }
                        .foregroundColor(AppTheme.gold)
                    }
                }
            }
            .sheet(isPresented: $showCardDetail) {
                if let card = selectedCard {
                    CardDetailView(card: card)
                }
            }
            .fullScreenCover(isPresented: $showGacha) {
                CardGachaView()
            }
        }
    }

    // MARK: - Components

    /// 收集進度卡片
    private var progressCard: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // 標題與數量
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("收集進度")
                        .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                        .foregroundColor(.white)

                    Text("\(cardVM.collectedCount) / \(cardVM.totalCardCount)")
                        .font(.system(size: AppTheme.FontSize.title1, weight: .bold))
                        .foregroundColor(AppTheme.gold)
                }

                Spacer()

                // 百分比圓形進度
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 8)
                        .frame(width: 70, height: 70)

                    Circle()
                        .trim(from: 0, to: cardVM.collectionProgress / 100)
                        .stroke(
                            AppTheme.goldGradient,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 70, height: 70)
                        .rotationEffect(.degrees(-90))

                    Text("\(Int(cardVM.collectionProgress))%")
                        .font(.system(size: AppTheme.FontSize.body, weight: .bold))
                        .foregroundColor(.white)
                }
            }

            // 進度條
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 20)

                    RoundedRectangle(cornerRadius: 10)
                        .fill(AppTheme.goldGradient)
                        .frame(width: geometry.size.width * (cardVM.collectionProgress / 100), height: 20)
                }
            }
            .frame(height: 20)
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

    /// 稀有度統計區域
    private var rarityStatsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("稀有度統計")
                .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                .foregroundColor(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(CardRarity.allCases.reversed(), id: \.self) { rarity in
                        rarityStatChip(rarity)
                    }
                }
            }
        }
    }

    /// 稀有度統計卡片
    private func rarityStatChip(_ rarity: CardRarity) -> some View {
        let stats = cardVM.getCollectionStats()[rarity] ?? (collected: 0, total: 0)

        return Button(action: {
            if selectedRarity == rarity {
                selectedRarity = nil
            } else {
                selectedRarity = rarity
                selectedType = nil
            }
        }) {
            VStack(spacing: AppTheme.Spacing.xs) {
                // 稀有度圖標
                Image(systemName: rarity.icon)
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: rarity.color))

                // 稀有度名稱
                Text(rarity.rawValue)
                    .font(.system(size: AppTheme.FontSize.caption, weight: .semibold))
                    .foregroundColor(.white)

                // 收集數量
                Text("\(stats.collected)/\(stats.total)")
                    .font(.system(size: AppTheme.FontSize.caption2))
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(width: 80)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                    .fill(selectedRarity == rarity ? Color(hex: rarity.color).opacity(0.2) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                            .stroke(Color(hex: rarity.color).opacity(selectedRarity == rarity ? 0.8 : 0.3), lineWidth: selectedRarity == rarity ? 2 : 1)
                    )
            )
        }
    }

    /// 篩選區域
    private var filterSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("神明類型")
                .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, AppTheme.Spacing.xl)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    // 全部按鈕
                    typeChip(title: "全部", isSelected: selectedType == nil) {
                        selectedType = nil
                    }

                    // 類型按鈕
                    ForEach(DeityType.allCases, id: \.self) { type in
                        typeChip(
                            title: type.rawValue,
                            icon: type.icon,
                            color: Color(hex: type.color),
                            isSelected: selectedType == type
                        ) {
                            if selectedType == type {
                                selectedType = nil
                            } else {
                                selectedType = type
                                selectedRarity = nil
                            }
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.xl)
            }
        }
    }

    /// 類型篩選按鈕
    private func typeChip(
        title: String,
        icon: String? = nil,
        color: Color = AppTheme.gold,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let iconName = icon {
                    Image(systemName: iconName)
                        .font(.system(size: 12))
                }
                Text(title)
                    .font(.system(size: AppTheme.FontSize.caption, weight: .medium))
            }
            .foregroundColor(isSelected ? AppTheme.dark : .white)
            .padding(.horizontal, AppTheme.Spacing.sm)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected ? color : Color.white.opacity(0.1))
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : color.opacity(0.3), lineWidth: 1)
            )
        }
    }

    /// 卡牌網格
    private var cardsGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: AppTheme.Spacing.md),
                GridItem(.flexible(), spacing: AppTheme.Spacing.md),
                GridItem(.flexible(), spacing: AppTheme.Spacing.md)
            ],
            spacing: AppTheme.Spacing.md
        ) {
            ForEach(filteredCards) { card in
                cardGridItem(card)
                    .onTapGesture {
                        selectedCard = card
                        showCardDetail = true
                    }
            }
        }
    }

    /// 卡牌網格項目
    private func cardGridItem(_ card: DeityCard) -> some View {
        let isCollected = cardVM.isCardCollected(card.id)
        let collectedCard = cardVM.getCollectedCard(card.id)

        return VStack(spacing: 8) {
            // 卡牌預覽
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm)
                    .fill(
                        LinearGradient(
                            colors: isCollected ?
                                [Color(hex: card.rarity.color), Color(hex: card.rarity.glowColor)] :
                                [Color.white.opacity(0.05), Color.white.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .aspectRatio(0.7, contentMode: .fit)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm)
                            .stroke(Color(hex: card.rarity.color).opacity(isCollected ? 0.8 : 0.3), lineWidth: 2)
                    )

                if isCollected {
                    // 已收集 - 顯示神明名稱
                    VStack {
                        Spacer()
                        Text(card.name)
                            .font(.system(size: AppTheme.FontSize.caption2, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 6)
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.6))
                    }

                    // 等級標籤
                    if let level = collectedCard?.level, level > 1 {
                        VStack {
                            HStack {
                                Spacer()
                                Text("Lv.\(level)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(
                                        Capsule()
                                            .fill(AppTheme.gold)
                                    )
                                    .padding(4)
                            }
                            Spacer()
                        }
                    }
                } else {
                    // 未收集 - 顯示問號
                    Image(systemName: "questionmark")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white.opacity(0.3))
                }

                // 稀有度圖標
                VStack {
                    HStack {
                        Image(systemName: card.rarity.icon)
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: card.rarity.color))
                            .padding(4)
                        Spacer()
                    }
                    Spacer()
                }
            }

            // 卡牌編號
            Text(card.cardNumber)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.5))
        }
    }

    /// 抽卡按鈕
    private var gachaButton: some View {
        Button(action: { showGacha = true }) {
            HStack {
                Image(systemName: "gift.fill")
                    .font(.system(size: 20))

                Text("福報抽卡")
                    .font(.system(size: AppTheme.FontSize.headline, weight: .bold))

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                    Text("100")
                        .font(.system(size: AppTheme.FontSize.body, weight: .semibold))
                }
            }
            .foregroundColor(AppTheme.dark)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .padding(.horizontal, AppTheme.Spacing.lg)
            .background(AppTheme.goldGradient)
            .cornerRadius(AppTheme.CornerRadius.md)
            .shadow(
                color: AppTheme.gold.opacity(0.4),
                radius: 16,
                x: 0,
                y: 6
            )
        }
    }
}

// MARK: - Preview

#Preview {
    CardCollectionView()
}
