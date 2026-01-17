/**
 * 服務選單頁面
 * 提供商城、活動報名、點燈等服務入口
 */

import SwiftUI

struct ServiceMenuView: View {
    // MARK: - State

    @Environment(\.dismiss) private var dismiss
    @State private var showShop = false
    @State private var showEvents = false
    @State private var showLightLamp = false
    @State private var showCardCollection = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    // MARK: - Services Data

    private let services = [
        ServiceItem(
            id: "shop",
            icon: "cart.fill",
            title: "福品商城",
            description: "購買各式祈福商品",
            color: "FFD700"
        ),
        ServiceItem(
            id: "events",
            icon: "calendar.badge.clock",
            title: "活動報名",
            description: "參加廟宇活動與法會",
            color: "FF6B6B"
        ),
        ServiceItem(
            id: "light",
            icon: "flame.fill",
            title: "點燈祈福",
            description: "線上點燈為自己與家人祈福",
            color: "FFA500"
        ),
        ServiceItem(
            id: "cards",
            icon: "sparkles",
            title: "神明圖鑑",
            description: "收集神明卡牌、福報抽卡",
            color: "9C27B0"
        ),
        ServiceItem(
            id: "donate",
            icon: "heart.fill",
            title: "線上捐款",
            description: "支持廟宇運作與公益活動",
            color: "E74C3C"
        )
    ]

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // 背景
                AppTheme.darkGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        // 標題說明
                        VStack(spacing: AppTheme.Spacing.sm) {
                            Image(systemName: "apps.iphone")
                                .font(.system(size: 50))
                                .foregroundColor(AppTheme.gold)
                                .padding(.top, AppTheme.Spacing.xl)

                            Text("服務選單")
                                .font(.system(size: AppTheme.FontSize.title2, weight: .bold))
                                .foregroundColor(.white)

                            Text("選擇您需要的服務")
                                .font(.system(size: AppTheme.FontSize.callout))
                                .foregroundColor(AppTheme.whiteAlpha06)
                        }

                        // 服務卡片網格
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: AppTheme.Spacing.md),
                            GridItem(.flexible(), spacing: AppTheme.Spacing.md)
                        ], spacing: AppTheme.Spacing.md) {
                            ForEach(services) { service in
                                ServiceCard(service: service)
                                    .onTapGesture {
                                        handleServiceTap(service)
                                    }
                            }
                        }
                        .padding(.horizontal, AppTheme.Spacing.xl)
                        .padding(.bottom, AppTheme.Spacing.xxxl)
                    }
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
            .alert("提示", isPresented: $showAlert) {
                Button("確定", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
        .fullScreenCover(isPresented: $showShop) {
            ShopView()
        }
        .fullScreenCover(isPresented: $showEvents) {
            EventListView()
        }
        .fullScreenCover(isPresented: $showLightLamp) {
            LightLampView()
        }
        .fullScreenCover(isPresented: $showCardCollection) {
            CardCollectionView()
        }
    }

    // MARK: - Methods

    private func handleServiceTap(_ service: ServiceItem) {
        switch service.id {
        case "shop":
            showShop = true
        case "events":
            showEvents = true
        case "light":
            showLightLamp = true
        case "cards":
            showCardCollection = true
        case "donate":
            alertMessage = "線上捐款功能開發中"
            showAlert = true
        default:
            break
        }
    }
}

// MARK: - Service Item Model

struct ServiceItem: Identifiable {
    let id: String
    let icon: String
    let title: String
    let description: String
    let color: String
}

// MARK: - Service Card Component

struct ServiceCard: View {
    let service: ServiceItem

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // 圖標
            ZStack {
                Circle()
                    .fill(Color(hex: service.color).opacity(0.2))
                    .frame(width: 70, height: 70)

                Image(systemName: service.icon)
                    .font(.system(size: 32))
                    .foregroundColor(Color(hex: service.color))
            }

            // 文字
            VStack(spacing: AppTheme.Spacing.xs) {
                Text(service.title)
                    .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                    .foregroundColor(.white)

                Text(service.description)
                    .font(.system(size: AppTheme.FontSize.caption))
                    .foregroundColor(AppTheme.whiteAlpha06)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                        .stroke(Color(hex: service.color).opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(
            color: Color(hex: service.color).opacity(0.1),
            radius: 8,
            x: 0,
            y: 4
        )
    }
}

// MARK: - Preview

#Preview {
    ServiceMenuView()
}
