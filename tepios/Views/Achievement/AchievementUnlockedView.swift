/**
 * 成就解鎖動畫視圖
 */

import SwiftUI

struct AchievementUnlockedView: View {
    // MARK: - Properties

    let achievement: Achievement
    let onDismiss: () -> Void

    // MARK: - State

    @State private var showContent = false
    @State private var showGlow = false
    @State private var rotation: Double = 0

    // MARK: - Body

    var body: some View {
        ZStack {
            // 半透明背景
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            VStack(spacing: AppTheme.Spacing.xxl) {
                Spacer()

                // 成就卡片
                achievementCard
                    .scaleEffect(showContent ? 1.0 : 0.3)
                    .opacity(showContent ? 1.0 : 0)

                // 按鈕
                Button(action: dismiss) {
                    Text("太棒了！")
                        .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                        .foregroundColor(AppTheme.dark)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppTheme.goldGradient)
                        .cornerRadius(AppTheme.CornerRadius.md)
                }
                .padding(.horizontal, AppTheme.Spacing.xl)
                .opacity(showContent ? 1.0 : 0)

                Spacer()
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    // MARK: - Components

    private var achievementCard: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            // 標題
            Text("🎉 成就解鎖！")
                .font(.system(size: AppTheme.FontSize.title1, weight: .bold))
                .foregroundColor(.white)

            // 成就圖示
            ZStack {
                // 發光效果
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                rarityColor(achievement.rarity).opacity(0.6),
                                rarityColor(achievement.rarity).opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 50,
                            endRadius: 150
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(showGlow ? 1.3 : 1.0)
                    .opacity(showGlow ? 0.3 : 0.7)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: showGlow)

                // 稀有度環
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: rarityGradientColors(achievement.rarity),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 8
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(rotation))

                // 成就圖標
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: rarityGradientColors(achievement.rarity),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .shadow(
                            color: rarityColor(achievement.rarity).opacity(0.5),
                            radius: 20,
                            x: 0,
                            y: 10
                        )

                    Image(systemName: achievement.icon)
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                }
            }

            // 成就資訊
            VStack(spacing: AppTheme.Spacing.md) {
                HStack {
                    Text(achievement.rarity.icon)
                        .font(.system(size: 20))
                    Text(achievement.rarity.rawValue)
                        .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                        .foregroundColor(rarityColor(achievement.rarity))
                }

                Text(achievement.title)
                    .font(.system(size: AppTheme.FontSize.title2, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text(achievement.description)
                    .font(.system(size: AppTheme.FontSize.body))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, AppTheme.Spacing.lg)

                // 獎勵點數
                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.yellow)

                    Text("+\(achievement.rewardPoints)")
                        .font(.system(size: AppTheme.FontSize.title2, weight: .bold))
                        .foregroundColor(.yellow)

                    Text("福報值")
                        .font(.system(size: AppTheme.FontSize.body))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(AppTheme.Spacing.md)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                )
            }
        }
        .padding(AppTheme.Spacing.xxl)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "1a1a2e"),
                            Color(hex: "16213e")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
        )
        .padding(.horizontal, AppTheme.Spacing.xl)
    }

    // MARK: - Methods

    private func startAnimation() {
        // 主要內容動畫
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            showContent = true
        }

        // 發光效果
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showGlow = true
        }

        // 旋轉動畫
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            rotation = 360
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.3)) {
            showContent = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }

    private func rarityColor(_ rarity: AchievementRarity) -> Color {
        switch rarity {
        case .bronze: return Color(hex: "CD7F32")
        case .silver: return Color(hex: "C0C0C0")
        case .gold: return AppTheme.gold
        case .diamond: return Color(hex: "B9F2FF")
        }
    }

    private func rarityGradientColors(_ rarity: AchievementRarity) -> [Color] {
        switch rarity {
        case .bronze:
            return [Color(hex: "CD7F32"), Color(hex: "B87333")]
        case .silver:
            return [Color(hex: "C0C0C0"), Color(hex: "A8A8A8")]
        case .gold:
            return [AppTheme.gold, Color(hex: "D4B756")]
        case .diamond:
            return [Color(hex: "B9F2FF"), Color(hex: "4FC3F7")]
        }
    }
}

// MARK: - Preview

#Preview {
    AchievementUnlockedView(
        achievement: Achievement(
            id: "test",
            title: "初心者",
            description: "完成第一次打卡，踏上信仰之路",
            icon: "flame",
            type: .checkIn,
            rarity: .gold,
            requirement: .firstCheckIn,
            rewardPoints: 100,
            progress: 1,
            unlocked: true,
            unlockedDate: Date()
        ),
        onDismiss: {}
    )
}
