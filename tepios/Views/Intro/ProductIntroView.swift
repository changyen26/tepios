/**
 * 產品介紹頁面
 * 用於官網展示和產品宣傳
 */

import SwiftUI

struct ProductIntroView: View {
    // MARK: - State

    @State private var animateHero = false
    @State private var animateFeatures = false

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Section - 主視覺區域
                heroSection

                // App 介紹
                appIntroSection
                    .padding(.top, AppTheme.Spacing.xxxl)

                // 功能特色
                featuresSection
                    .padding(.top, AppTheme.Spacing.xxxl)

                // 底部間距
                Color.clear
                    .frame(height: AppTheme.Spacing.xxxl)
            }
        }
        .background(AppTheme.darkGradient.ignoresSafeArea())
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animateHero = true
            }
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                animateFeatures = true
            }
        }
    }

    // MARK: - Components

    /// Hero Section - 主視覺
    private var heroSection: some View {
        ZStack {
            // 背景漸層
            LinearGradient(
                colors: [
                    AppTheme.gold.opacity(0.3),
                    AppTheme.dark
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 500)

            VStack(spacing: AppTheme.Spacing.xl) {
                Spacer()

                // App Icon 模擬
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.gold, Color(hex: "#D4B756")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .shadow(color: AppTheme.gold.opacity(0.5), radius: 30, x: 0, y: 15)

                    Image(systemName: "scroll.fill")
                        .font(.system(size: 70))
                        .foregroundColor(AppTheme.dark)
                }
                .scaleEffect(animateHero ? 1.0 : 0.5)
                .opacity(animateHero ? 1.0 : 0.0)

                // App 名稱
                Text("平安符打卡系統")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, AppTheme.gold.opacity(0.9)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .opacity(animateHero ? 1.0 : 0.0)
                    .offset(y: animateHero ? 0 : 20)

                // Slogan
                Text("數位守護，福報隨行")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .opacity(animateHero ? 1.0 : 0.0)
                    .offset(y: animateHero ? 0 : 20)

                // 副標題
                Text("結合傳統信仰與現代科技\n打造全新的參拜體驗")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(animateHero ? 1.0 : 0.0)
                    .offset(y: animateHero ? 0 : 20)

                Spacer()
            }
            .padding(.horizontal, AppTheme.Spacing.xl)
        }
    }

    /// App 介紹區域
    private var appIntroSection: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Text("關於我們")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)

            Text("平安符打卡系統是一款結合台灣傳統廟宇文化與現代科技的創新應用。透過 實體平安符或QR Code 打卡、數位平安符管理、福報值累積等功能，讓您的信仰生活更加便利、有趣、有意義。")
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(8)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.xl)
        }
    }

    /// 功能特色區域
    private var featuresSection: some View {
        VStack(spacing: AppTheme.Spacing.xxl) {
            // 標題
            VStack(spacing: AppTheme.Spacing.sm) {
                Text("核心功能")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)

                Text("八大特色功能，全方位服務您的信仰生活")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.6))
            }

            // 功能網格
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: AppTheme.Spacing.lg),
                    GridItem(.flexible(), spacing: AppTheme.Spacing.lg)
                ],
                spacing: AppTheme.Spacing.lg
            ) {
                ForEach(Array(ProductFeature.features.enumerated()), id: \.element.id) { index, feature in
                    FeatureCard(feature: feature)
                        .opacity(animateFeatures ? 1.0 : 0.0)
                        .offset(y: animateFeatures ? 0 : 30)
                        .animation(
                            .easeOut(duration: 0.6).delay(Double(index) * 0.1),
                            value: animateFeatures
                        )
                }
            }
            .padding(.horizontal, AppTheme.Spacing.xl)
        }
    }
}

// MARK: - Feature Card Component

struct FeatureCard: View {
    let feature: ProductFeature

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // 圖標
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: feature.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: feature.color.opacity(0.4), radius: 15, x: 0, y: 8)

                Image(systemName: feature.iconName)
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }

            // 標題
            Text(feature.title)
                .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 44)

            // 描述
            Text(feature.description)
                .font(.system(size: AppTheme.FontSize.callout))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .frame(minHeight: 80, alignment: .top)
        }
        .padding(AppTheme.Spacing.lg)
        .frame(maxWidth: .infinity, minHeight: 280)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    feature.color.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
}

// MARK: - Preview

#Preview {
    ProductIntroView()
}
