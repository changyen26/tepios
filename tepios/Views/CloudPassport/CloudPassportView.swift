
/**
 * 雲端護照主頁面
 * 遊戲化的個人護照系統，根據用戶選擇的信仰神明展示專屬主題
 */

import SwiftUI

struct CloudPassportView: View {
    // MARK: - State

    @StateObject private var userViewModel = UserProfileViewModel.shared
    @State private var showCheckIn = false
    @State private var showProfile = false
    @State private var showShop = false
    @State private var showEvents = false
    @State private var showLightLamp = false
    @State private var showCardCollection = false
    @State private var showAllAmulets = false
    @State private var showBindAmulet = false
    @State private var selectedAmulet: Amulet?
    @State private var amuletRotation: Double = 0

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // 背景漸層（固定深色背景）
                AppTheme.darkGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        // 護照頭部：等級和稱號
                        passportHeader
                            .padding(.top, AppTheme.Spacing.lg)

                        // 福報值進度條
                        meritPointsProgress
                            .padding(.horizontal, AppTheme.Spacing.xl)

                        // 統計數據卡片
                        statisticsCards
                            .padding(.horizontal, AppTheme.Spacing.xl)

                        // 快速操作按鈕
                        quickActionsSection
                            .padding(.horizontal, AppTheme.Spacing.xl)

                        // 我的平安符
                        amuletsSection
                            .padding(.horizontal, AppTheme.Spacing.xl)

                        // 服務功能區域
                        servicesSection
                            .padding(.horizontal, AppTheme.Spacing.xl)

                        // 底部間距
                        Spacer(minLength: AppTheme.Spacing.xxxl)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showProfile = true }) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
            }
            .navigationDestination(isPresented: $showProfile) {
                ProfileView()
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
            .fullScreenCover(isPresented: $showAllAmulets) {
                AmuletInfoView()
            }
            .sheet(isPresented: $showBindAmulet) {
                AmuletBindingView()
            }
            .sheet(item: $selectedAmulet) { amulet in
                AmuletDetailSheet(amulet: amulet)
            }
            .onAppear {
                // 啟動平安符旋轉動畫
                withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                    amuletRotation = 360
                }
            }
        }
    }

    // MARK: - Components

    /// 根據用戶選擇的神明返回主題漸層
    private var deityThemeGradient: LinearGradient {
        guard let deity = userViewModel.getCurrentDeity() else {
            return AppTheme.darkGradient
        }

        let color = Color(hex: deity.color)
        return LinearGradient(
            colors: [
                color.opacity(0.8),
                color.opacity(0.6),
                AppTheme.dark
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// 護照頭部：等級、稱號和神明
    private var passportHeader: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // 神明圖標和名稱
            if let deity = userViewModel.getCurrentDeity() {
                VStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: deity.iconName)
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color(hex: deity.color).opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: Color(hex: deity.color).opacity(0.5), radius: 20, x: 0, y: 10)

                    Text(deity.displayName)
                        .font(.system(size: AppTheme.FontSize.callout, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
            }

            // 等級顯示
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.gold, Color(hex: "#D4B756")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: AppTheme.gold.opacity(0.5), radius: 20, x: 0, y: 10)

                VStack(spacing: 4) {
                    Text("Lv.\(userViewModel.user.cloudPassport.level)")
                        .font(.system(size: AppTheme.FontSize.title1, weight: .bold))
                        .foregroundColor(AppTheme.dark)

                    Text(userViewModel.user.cloudPassport.title)
                        .font(.system(size: AppTheme.FontSize.caption, weight: .semibold))
                        .foregroundColor(AppTheme.dark.opacity(0.8))
                }
            }

            // 用戶名稱
            if !userViewModel.user.profile.name.isEmpty {
                Text(userViewModel.user.profile.name)
                    .font(.system(size: AppTheme.FontSize.title2, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }

    /// 福報值進度條
    private var meritPointsProgress: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16))
                    Text("福報值")
                        .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                }
                .foregroundColor(.white)

                Spacer()

                Text("\(userViewModel.user.cloudPassport.currentMeritPoints) / \(userViewModel.user.cloudPassport.meritPointsNeededForNextLevel)")
                    .font(.system(size: AppTheme.FontSize.callout, weight: .bold))
                    .foregroundColor(AppTheme.gold)
            }

            // 進度條
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 20)

                    // 進度
                    RoundedRectangle(cornerRadius: 10)
                        .fill(AppTheme.goldGradient)
                        .frame(
                            width: geometry.size.width * userViewModel.user.cloudPassport.levelProgress,
                            height: 20
                        )
                        .shadow(color: AppTheme.gold.opacity(0.5), radius: 8, x: 0, y: 2)
                }
            }
            .frame(height: 20)
        }
        .padding(AppTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }

    /// 統計數據卡片
    private var statisticsCards: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            statisticCard(
                icon: "checkmark.circle.fill",
                value: "\(userViewModel.user.statistics.totalCheckIns)",
                label: "總打卡",
                color: .green
            )

            statisticCard(
                icon: "flame.fill",
                value: "\(userViewModel.user.statistics.totalPrayers)",
                label: "總祈福",
                color: .orange
            )

            statisticCard(
                icon: "calendar.badge.clock",
                value: "\(userViewModel.user.cloudPassport.checkInStreak)",
                label: "連續天數",
                color: .red
            )
        }
    }

    private func statisticCard(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: AppTheme.FontSize.title2, weight: .bold))
                .foregroundColor(.white)

            Text(label)
                .font(.system(size: AppTheme.FontSize.caption, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }

    /// 快速操作區域
    private var quickActionsSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack {
                Text("快速操作")
                    .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }

            HStack(spacing: AppTheme.Spacing.md) {
                quickActionButton(
                    icon: "qrcode.viewfinder",
                    title: "打卡",
                    color: AppTheme.gold
                ) {
                    showCheckIn = true
                }

                quickActionButton(
                    icon: "map.fill",
                    title: "找廟宇",
                    color: .blue
                ) {
                    // Navigate to map
                }

                quickActionButton(
                    icon: "flame.fill",
                    title: "祈福",
                    color: .orange
                ) {
                    // Navigate to prayer
                }
            }
        }
    }

    private func quickActionButton(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }

                Text(title)
                    .font(.system(size: AppTheme.FontSize.caption, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                    .fill(Color.white.opacity(0.1))
            )
        }
    }

    /// 我的平安符區域
    private var amuletsSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack {
                Text("我的平安符")
                    .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                    .foregroundColor(.white)
                Spacer()

                if !userViewModel.user.amulets.isEmpty {
                    Button(action: { showAllAmulets = true }) {
                        HStack(spacing: 4) {
                            Text("查看全部")
                                .font(.system(size: AppTheme.FontSize.caption, weight: .medium))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(AppTheme.gold)
                    }
                }
            }

            if userViewModel.user.amulets.isEmpty {
                // 空狀態
                emptyAmuletCard
            } else {
                // 顯示前3個平安符
                VStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(userViewModel.user.amulets.prefix(3)) { amulet in
                        compactAmuletCard(amulet)
                            .onTapGesture {
                                selectedAmulet = amulet
                            }
                    }
                }
            }
        }
    }

    /// 空狀態平安符卡片
    private var emptyAmuletCard: some View {
        Button(action: { showBindAmulet = true }) {
            VStack(spacing: AppTheme.Spacing.md) {
                Image("amulet_image")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .opacity(0.5)
                    .rotationEffect(.degrees(amuletRotation))

                VStack(spacing: 4) {
                    Text("尚未綁定平安符")
                        .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                        .foregroundColor(.white)

                    Text("點擊綁定您的第一個平安符")
                        .font(.system(size: AppTheme.FontSize.caption2))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.xl)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [5, 5]))
                            .foregroundColor(AppTheme.gold.opacity(0.3))
                    )
            )
        }
    }

    /// 精簡平安符卡片
    private func compactAmuletCard(_ amulet: Amulet) -> some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // 平安符圖片（旋轉動畫）
            ZStack {
                Circle()
                    .fill(AppTheme.gold.opacity(0.2))
                    .frame(width: 50, height: 50)

                Image("amulet_image")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(amuletRotation))
            }

            // 平安符資訊
            VStack(alignment: .leading, spacing: 4) {
                Text(amulet.templeName)
                    .font(.system(size: AppTheme.FontSize.callout, weight: .bold))
                    .foregroundColor(.white)

                Text("等級 \(amulet.level)")
                    .font(.system(size: AppTheme.FontSize.caption))
                    .foregroundColor(AppTheme.gold)
            }

            Spacer()

            // 福報值進度
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(amulet.currentPoints)/100")
                    .font(.system(size: AppTheme.FontSize.caption, weight: .semibold))
                    .foregroundColor(.white)

                // 迷你進度條
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 4)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(AppTheme.goldGradient)
                            .frame(width: geometry.size.width * CGFloat(min(amulet.currentPoints, 100)) / 100.0, height: 4)
                    }
                }
                .frame(width: 60, height: 4)
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                        .stroke(AppTheme.gold.opacity(0.3), lineWidth: 1)
                )
        )
    }

    /// 服務功能區域
    private var servicesSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack {
                Text("服務中心")
                    .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: AppTheme.Spacing.md),
                    GridItem(.flexible(), spacing: AppTheme.Spacing.md)
                ],
                spacing: AppTheme.Spacing.md
            ) {
                // 福品商城
                serviceCard(
                    icon: "cart.fill",
                    title: "福品商城",
                    description: "購買祈福商品",
                    color: "FFD700"
                ) {
                    showShop = true
                }

                // 活動報名
                serviceCard(
                    icon: "calendar.badge.clock",
                    title: "活動報名",
                    description: "參加廟宇活動",
                    color: "FF6B6B"
                ) {
                    showEvents = true
                }

                // 點燈祈福
                serviceCard(
                    icon: "flame.fill",
                    title: "點燈祈福",
                    description: "線上點燈祈福",
                    color: "FFA500"
                ) {
                    showLightLamp = true
                }

                // 神明圖鑑
                serviceCard(
                    icon: "sparkles",
                    title: "神明圖鑑",
                    description: "收集神明卡牌",
                    color: "9C27B0"
                ) {
                    showCardCollection = true
                }
            }
        }
    }

    private func serviceCard(icon: String, title: String, description: String, color: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Spacing.md) {
                // 圖標
                ZStack {
                    Circle()
                        .fill(Color(hex: color).opacity(0.2))
                        .frame(width: 60, height: 60)

                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: color))
                }

                // 文字
                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: AppTheme.FontSize.callout, weight: .bold))
                        .foregroundColor(.white)

                    Text(description)
                        .font(.system(size: AppTheme.FontSize.caption2))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                            .stroke(Color(hex: color).opacity(0.3), lineWidth: 1)
                    )
            )
            .shadow(
                color: Color(hex: color).opacity(0.2),
                radius: 8,
                x: 0,
                y: 4
            )
        }
    }
}

// MARK: - Preview

#Preview {
    CloudPassportView()
}
