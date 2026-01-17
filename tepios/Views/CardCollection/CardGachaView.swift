/**
 * 抽卡頁面
 * 福報值抽取神明卡牌
 */

import SwiftUI

struct CardGachaView: View {
    // MARK: - State

    @Environment(\.dismiss) private var dismiss
    @StateObject private var cardVM = CardCollectionViewModel.shared
    @State private var drawnCard: DeityCard? = nil
    @State private var showCard = false
    @State private var isDrawing = false
    @State private var showInsufficientPoints = false
    @State private var cardRotation: Double = 0
    @State private var cardScale: CGFloat = 0.1
    @State private var showGlow = false

    // 抽卡費用
    private let gachaCost = 100

    // MARK: - Computed Properties

    private var availablePoints: Int {
        cardVM.userViewModel.user.cloudPassport.currentMeritPoints
    }

    private var canDraw: Bool {
        availablePoints >= gachaCost
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // 背景
                AppTheme.darkGradient
                    .ignoresSafeArea()

                if showCard, let card = drawnCard {
                    // 顯示抽到的卡牌
                    cardRevealView(card)
                } else {
                    // 抽卡介面
                    gachaInterfaceView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("關閉") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.gold)
                }
            }
            .alert("福報值不足", isPresented: $showInsufficientPoints) {
                Button("確定", role: .cancel) { }
            } message: {
                Text("需要 \(gachaCost) 福報值才能抽卡\n目前擁有 \(availablePoints) 福報值")
            }
        }
    }

    // MARK: - Components

    /// 抽卡介面
    private var gachaInterfaceView: some View {
        VStack(spacing: AppTheme.Spacing.xxl) {
            Spacer()

            // 標題
            VStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: "gift.fill")
                    .font(.system(size: 80))
                    .foregroundColor(AppTheme.gold)
                    .shadow(color: AppTheme.gold.opacity(0.5), radius: 20)

                Text("福報抽卡")
                    .font(.system(size: AppTheme.FontSize.title1, weight: .bold))
                    .foregroundColor(.white)

                Text("使用福報值抽取神明卡牌")
                    .font(.system(size: AppTheme.FontSize.callout))
                    .foregroundColor(.white.opacity(0.7))
            }

            // 機率說明
            probabilitySection

            Spacer()

            // 福報值顯示
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.gold)

                Text("可用福報值：")
                    .font(.system(size: AppTheme.FontSize.body))
                    .foregroundColor(.white.opacity(0.7))

                Text("\(availablePoints)")
                    .font(.system(size: AppTheme.FontSize.title3, weight: .bold))
                    .foregroundColor(AppTheme.gold)
            }
            .padding(AppTheme.Spacing.lg)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                            .stroke(AppTheme.gold.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.horizontal, AppTheme.Spacing.xl)

            // 抽卡按鈕
            Button(action: handleDraw) {
                HStack {
                    if isDrawing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.dark))
                    } else {
                        Image(systemName: "sparkles")
                            .font(.system(size: 20))

                        Text("抽一張")
                            .font(.system(size: AppTheme.FontSize.headline, weight: .bold))

                        Spacer()

                        Text("\(gachaCost)")
                            .font(.system(size: AppTheme.FontSize.headline, weight: .bold))

                        Image(systemName: "sparkles")
                            .font(.system(size: 16))
                    }
                }
                .foregroundColor(AppTheme.dark)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .padding(.horizontal, AppTheme.Spacing.lg)
                .background(
                    canDraw ?
                        AppTheme.goldGradient :
                        LinearGradient(colors: [Color.gray, Color.gray], startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(AppTheme.CornerRadius.md)
                .shadow(
                    color: canDraw ? AppTheme.gold.opacity(0.4) : Color.clear,
                    radius: 16,
                    x: 0,
                    y: 6
                )
            }
            .disabled(!canDraw || isDrawing)
            .padding(.horizontal, AppTheme.Spacing.xl)
            .padding(.bottom, AppTheme.Spacing.xxl)
        }
    }

    /// 機率說明區域
    private var probabilitySection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("獲得機率")
                .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                .foregroundColor(.white)

            VStack(spacing: 8) {
                ForEach([CardRarity.mythical, .legendary, .epic, .rare, .common], id: \.self) { rarity in
                    probabilityRow(rarity)
                }
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
        .padding(.horizontal, AppTheme.Spacing.xl)
    }

    /// 機率行
    private func probabilityRow(_ rarity: CardRarity) -> some View {
        HStack {
            Image(systemName: rarity.icon)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: rarity.color))
                .frame(width: 20)

            Text(rarity.rawValue)
                .font(.system(size: AppTheme.FontSize.callout))
                .foregroundColor(.white)

            Spacer()

            Text(String(format: "%.1f%%", rarity.dropRate))
                .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                .foregroundColor(Color(hex: rarity.color))
        }
    }

    /// 卡牌揭示視圖
    private func cardRevealView(_ card: DeityCard) -> some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Spacer()

            // 稀有度公告
            VStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: card.rarity.icon)
                    .font(.system(size: 50))
                    .foregroundColor(Color(hex: card.rarity.color))
                    .shadow(color: Color(hex: card.rarity.glowColor).opacity(0.8), radius: 20)
                    .scaleEffect(showGlow ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: showGlow)

                Text(card.rarity.rawValue)
                    .font(.system(size: AppTheme.FontSize.title2, weight: .bold))
                    .foregroundColor(Color(hex: card.rarity.color))
            }
            .opacity(showGlow ? 1 : 0)
            .animation(.easeIn(duration: 0.5).delay(0.5), value: showGlow)

            // 卡牌
            ZStack {
                // 光暈效果
                if card.rarity == .legendary || card.rarity == .mythical {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: card.rarity.glowColor).opacity(0.6),
                                    Color(hex: card.rarity.glowColor).opacity(0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 200
                            )
                        )
                        .frame(width: 400, height: 400)
                        .blur(radius: 30)
                        .opacity(showGlow ? 1 : 0)
                }

                // 卡牌本體
                cardView(card)
                    .rotation3DEffect(
                        .degrees(cardRotation),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .scaleEffect(cardScale)
            }

            Spacer()

            // 按鈕
            VStack(spacing: AppTheme.Spacing.md) {
                // 查看詳情按鈕
                Button(action: {
                    // 可以導航到卡牌詳情
                }) {
                    Text("查看詳情")
                        .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                .fill(Color(hex: card.rarity.color))
                        )
                }

                // 繼續抽卡或關閉
                HStack(spacing: AppTheme.Spacing.md) {
                    Button(action: resetGacha) {
                        Text("再抽一次")
                            .font(.system(size: AppTheme.FontSize.body, weight: .semibold))
                            .foregroundColor(AppTheme.gold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                            .stroke(AppTheme.gold.opacity(0.5), lineWidth: 1)
                                    )
                            )
                    }

                    Button(action: { dismiss() }) {
                        Text("返回圖鑑")
                            .font(.system(size: AppTheme.FontSize.body, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                    .fill(Color.white.opacity(0.1))
                            )
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.xl)
            .padding(.bottom, AppTheme.Spacing.xxl)
            .opacity(showGlow ? 1 : 0)
            .animation(.easeIn(duration: 0.5).delay(1.5), value: showGlow)
        }
    }

    /// 卡牌視圖
    private func cardView(_ card: DeityCard) -> some View {
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

            // 內容
            VStack(spacing: 0) {
                // 頂部
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
                    .background(Capsule().fill(Color.black.opacity(0.4)))

                    Spacer()
                }
                .padding(AppTheme.Spacing.md)

                Spacer()

                // 底部：神明名稱
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
                .background(Color.black.opacity(0.5))
            }
            .frame(width: 260, height: 360)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg))
        }
        .shadow(
            color: Color(hex: card.rarity.color).opacity(0.6),
            radius: 30,
            x: 0,
            y: 10
        )
    }

    // MARK: - Methods

    /// 處理抽卡
    private func handleDraw() {
        guard canDraw else {
            showInsufficientPoints = true
            return
        }

        isDrawing = true

        // 延遲模擬抽卡過程
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let card = cardVM.gachaCard(costPoints: gachaCost) {
                drawnCard = card
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    showCard = true
                }

                // 翻卡動畫
                withAnimation(.easeInOut(duration: 0.8)) {
                    cardRotation = 360
                    cardScale = 1.0
                }

                // 觸發光暈效果
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showGlow = true
                }
            }

            isDrawing = false
        }
    }

    /// 重置抽卡
    private func resetGacha() {
        withAnimation {
            showCard = false
            showGlow = false
            cardRotation = 0
            cardScale = 0.1
        }

        drawnCard = nil
    }
}

// MARK: - Preview

#Preview {
    CardGachaView()
}
