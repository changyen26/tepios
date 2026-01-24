/**
 * 打卡確認表單頁面
 */

import SwiftUI
import CoreLocation

struct CheckInSheetView: View {
    // MARK: - Properties

    let temple: Temple
    @ObservedObject var templeViewModel: TempleViewModel
    @ObservedObject var locationManager: LocationManager

    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    @State private var notes = ""
    @State private var showPrayerAnimation = false
    @State private var prayerProgress: Double = 0
    @State private var showSuccessAnimation = false
    @State private var earnedPoints = 0
    @State private var unlockedAchievements: [Achievement] = []
    @State private var showAchievementUnlocked = false
    @State private var currentAchievementIndex = 0
    @State private var prayerTimer: Timer?
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var showDonation = false
    @FocusState private var isNotesFieldFocused: Bool

    // MARK: - Body

    var body: some View {
        ZStack {
            // 背景
            AppTheme.darkGradient
                .ignoresSafeArea()

            if showSuccessAnimation {
                successView
            } else if showPrayerAnimation {
                prayerAnimationView
            } else {
                formView
            }

            // 成就解鎖覆蓋層
            if showAchievementUnlocked && currentAchievementIndex < unlockedAchievements.count {
                AchievementUnlockedView(
                    achievement: unlockedAchievements[currentAchievementIndex],
                    onDismiss: {
                        showAchievementUnlocked = false
                        currentAchievementIndex += 1

                        // 如果還有更多成就，顯示下一個
                        if currentAchievementIndex < unlockedAchievements.count {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showAchievementUnlocked = true
                            }
                        } else {
                            // 所有成就顯示完畢，清除通知
                            templeViewModel.clearNewlyUnlockedAchievements()
                        }
                    }
                )
                .transition(.opacity)
                .zIndex(100)
            }
        }
        .alert("打卡失敗", isPresented: $showErrorAlert) {
            Button("確定", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .fullScreenCover(isPresented: $showDonation) {
            DonationView()
        }
    }

    // MARK: - Form View

    private var formView: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.xxl) {
                // 頂部提示
                VStack(spacing: AppTheme.Spacing.md) {
                    Image(systemName: temple.deity.iconName)
                        .font(.system(size: 80))
                        .foregroundColor(AppTheme.gold)
                        .shadow(
                            color: AppTheme.gold.opacity(0.5),
                            radius: 20,
                            x: 0,
                            y: 10
                        )

                    Text("準備打卡")
                        .font(.system(size: AppTheme.FontSize.title2, weight: .bold))
                        .foregroundColor(.white)

                    Text(temple.name)
                        .font(.system(size: AppTheme.FontSize.headline))
                        .foregroundColor(AppTheme.gold)
                }
                .padding(.top, AppTheme.Spacing.xxl)

                // 廟宇資訊卡片
                VStack(spacing: AppTheme.Spacing.md) {
                    InfoRow(
                        icon: "location.fill",
                        title: "主祀神明",
                        value: temple.deity.name
                    )

                    InfoRow(
                        icon: "star.fill",
                        title: "基礎福報值",
                        value: "+\(temple.blessPoints)"
                    )

                    if let distance = locationManager.location.map({ temple.distance(from: $0) }) {
                        InfoRow(
                            icon: "map.fill",
                            title: "距離",
                            value: "\(Int(distance)) 公尺"
                        )
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
                .padding(.horizontal, AppTheme.Spacing.xl)

                // 打卡心得
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    Label("打卡心得（選填）", systemImage: "text.bubble.fill")
                        .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                        .foregroundColor(AppTheme.gold)

                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $notes)
                            .font(.system(size: AppTheme.FontSize.body))
                            .foregroundColor(.white)
                            .frame(height: 100)
                            .padding(AppTheme.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                    .fill(Color.white.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                            .stroke(
                                                isNotesFieldFocused ? AppTheme.gold : AppTheme.gold.opacity(0.3),
                                                lineWidth: isNotesFieldFocused ? 2 : 1
                                            )
                                    )
                            )
                            .focused($isNotesFieldFocused)
                            .scrollContentBackground(.hidden)

                        if notes.isEmpty && !isNotesFieldFocused {
                            Text("分享您的祈福心得或祝福語...")
                                .font(.system(size: AppTheme.FontSize.body))
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.horizontal, AppTheme.Spacing.md + 4)
                                .padding(.vertical, AppTheme.Spacing.md + 8)
                                .allowsHitTesting(false)
                        }
                    }

                    Text("分享您的祈福心得或祝福語")
                        .font(.system(size: AppTheme.FontSize.caption))
                        .foregroundColor(AppTheme.whiteAlpha06)
                }
                .padding(.horizontal, AppTheme.Spacing.xl)

                // 打卡提示
                VStack(spacing: AppTheme.Spacing.sm) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(AppTheme.gold.opacity(0.8))

                        Text("打卡須知")
                            .font(.system(size: AppTheme.FontSize.caption, weight: .semibold))
                            .foregroundColor(AppTheme.gold.opacity(0.8))

                        Spacer()
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        TipRow(text: "每日每廟宇限打卡一次")
                        TipRow(text: "連續打卡可獲得額外加成")
                        TipRow(text: "首次拜訪可獲得 2.5 倍福報值")
                    }
                }
                .padding(AppTheme.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                        .fill(AppTheme.gold.opacity(0.05))
                )
                .padding(.horizontal, AppTheme.Spacing.xl)

                // 按鈕區域
                VStack(spacing: AppTheme.Spacing.md) {
                    Button(action: performCheckIn) {
                        HStack {
                            if templeViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.dark))
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))

                                Text("確認打卡")
                                    .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                            }
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
                    .disabled(templeViewModel.isLoading)

                    Button(action: {
                        dismiss()
                    }) {
                        Text("取消")
                            .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                            .foregroundColor(AppTheme.whiteAlpha08)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.xl)
                .padding(.bottom, AppTheme.Spacing.xxl)
            }
        }
        .onTapGesture {
            isNotesFieldFocused = false
        }
    }

    // MARK: - Success View

    private var successView: some View {
        VStack(spacing: AppTheme.Spacing.xxl) {
            Spacer()

            // 成功動畫
            VStack(spacing: AppTheme.Spacing.xl) {
                ZStack {
                    // 光圈效果
                    Circle()
                        .fill(AppTheme.gold.opacity(0.2))
                        .frame(width: 200, height: 200)
                        .scaleEffect(showSuccessAnimation ? 1.5 : 0.5)
                        .opacity(showSuccessAnimation ? 0 : 1)
                        .animation(.easeOut(duration: 1.5), value: showSuccessAnimation)

                    // 勾選圖標
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(AppTheme.gold)
                        .scaleEffect(showSuccessAnimation ? 1.0 : 0.3)
                        .opacity(showSuccessAnimation ? 1.0 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showSuccessAnimation)
                }

                VStack(spacing: AppTheme.Spacing.md) {
                    Text("打卡成功！")
                        .font(.system(size: AppTheme.FontSize.title1, weight: .bold))
                        .foregroundColor(.white)

                    Text(temple.name)
                        .font(.system(size: AppTheme.FontSize.headline))
                        .foregroundColor(AppTheme.gold)
                }
                .opacity(showSuccessAnimation ? 1.0 : 0)
                .animation(.easeIn(duration: 0.5).delay(0.3), value: showSuccessAnimation)

                // 福報值顯示
                HStack(spacing: AppTheme.Spacing.md) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.yellow)

                    Text("+\(earnedPoints)")
                        .font(.system(size: AppTheme.FontSize.title1, weight: .bold))
                        .foregroundColor(.yellow)

                    Text("福報值")
                        .font(.system(size: AppTheme.FontSize.headline))
                        .foregroundColor(.white)
                }
                .padding(AppTheme.Spacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                                .stroke(AppTheme.gold.opacity(0.5), lineWidth: 2)
                        )
                )
                .scaleEffect(showSuccessAnimation ? 1.0 : 0.5)
                .opacity(showSuccessAnimation ? 1.0 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.5), value: showSuccessAnimation)

                // 統計資訊
                VStack(spacing: AppTheme.Spacing.sm) {
                    Text("連續打卡 \(templeViewModel.statistics.currentStreak) 天")
                        .font(.system(size: AppTheme.FontSize.callout))
                        .foregroundColor(AppTheme.whiteAlpha08)

                    Text("累積 \(templeViewModel.statistics.totalPoints) 福報值")
                        .font(.system(size: AppTheme.FontSize.callout))
                        .foregroundColor(AppTheme.whiteAlpha08)
                }
                .opacity(showSuccessAnimation ? 1.0 : 0)
                .animation(.easeIn(duration: 0.5).delay(0.8), value: showSuccessAnimation)
            }

            Spacer()

            // 香油錢捐款提示
            VStack(spacing: AppTheme.Spacing.md) {
                // 捐款按鈕
                Button(action: {
                    showDonation = true
                }) {
                    HStack {
                        Image(systemName: "hands.sparkles.fill")
                        Text("捐香油錢")
                            .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                    }
                    .foregroundColor(AppTheme.dark)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(AppTheme.goldGradient)
                    .cornerRadius(AppTheme.CornerRadius.md)
                }

                // 暫不捐款按鈕
                Button(action: {
                    dismiss()
                }) {
                    Text("暫不捐款")
                        .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.xl)
            .padding(.bottom, AppTheme.Spacing.xxl)
            .opacity(showSuccessAnimation ? 1.0 : 0)
            .animation(.easeIn(duration: 0.5).delay(1.0), value: showSuccessAnimation)
        }
    }

    // MARK: - Prayer Animation View

    private var prayerAnimationView: some View {
        VStack(spacing: AppTheme.Spacing.xxxl) {
            Spacer()

            // 標題
            Text("祈福加持中...")
                .font(.system(size: AppTheme.FontSize.title2, weight: .bold))
                .foregroundColor(AppTheme.gold)
                .tracking(2)

            // 彩虹圓環進度條
            ZStack {
                // 背景圓環
                Circle()
                    .stroke(
                        Color.white.opacity(0.1),
                        lineWidth: 12
                    )
                    .frame(width: 280, height: 280)

                // 進度圓環 - 彩虹漸層
                Circle()
                    .trim(from: 0, to: prayerProgress / 100)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "FF6B6B"),
                                Color(hex: "FFD93D"),
                                Color(hex: "6BCF7F"),
                                Color(hex: "4D96FF"),
                                Color(hex: "A084DC"),
                                Color(hex: "FF6B6B")
                            ]),
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        ),
                        style: StrokeStyle(
                            lineWidth: 12,
                            lineCap: .round
                        )
                    )
                    .frame(width: 280, height: 280)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.1), value: prayerProgress)

                // 中心香爐圖案
                VStack(spacing: AppTheme.Spacing.md) {
                    // 香爐圖標
                    Image(systemName: "flame.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "FF6B6B"), Color(hex: "FFD93D")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(
                            color: Color.orange.opacity(0.6),
                            radius: 20,
                            x: 0,
                            y: 10
                        )
                        .scaleEffect(1.0 + sin(prayerProgress * 0.1) * 0.05)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: prayerProgress)

                    // 百分比
                    Text("\(Int(prayerProgress))%")
                        .font(.system(size: AppTheme.FontSize.title1, weight: .bold))
                        .foregroundColor(AppTheme.gold)
                }
            }

            // 提示文字
            Text("請保持虔誠的心")
                .font(.system(size: AppTheme.FontSize.body))
                .foregroundColor(AppTheme.whiteAlpha06)

            Spacer()
        }
    }

    // MARK: - Methods

    private func performCheckIn() {
        // 檢查是否有位置資訊
        guard let userLocation = locationManager.location else {
            errorMessage = "無法取得您的位置\n\n請確認已開啟定位權限，或使用位置模擬器測試"
            showErrorAlert = true
            print("❌ 打卡失敗：無法取得位置")
            return
        }

        print("📍 用戶位置: \(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude)")
        print("🏛️ 廟宇位置: \(temple.latitude), \(temple.longitude)")

        let result = templeViewModel.performCheckIn(
            at: temple,
            from: userLocation,
            notes: notes
        )

        switch result {
        case .success:
            print("✅ 打卡成功")

            // 取得獲得的福報值
            if let lastCheckIn = templeViewModel.checkInRecords.last {
                earnedPoints = lastCheckIn.earnedPoints
            }

            // 檢查是否有新解鎖的成就
            unlockedAchievements = templeViewModel.getNewlyUnlockedAchievements()

            // 先顯示祈福加持動畫
            withAnimation {
                showPrayerAnimation = true
            }

            // 開始祈福進度動畫
            startPrayerProgress()

        case .failure(let reason):
            // 打卡驗證失敗
            errorMessage = reason
            showErrorAlert = true
            print("❌ 打卡驗證失敗: \(reason)")
        }
    }

    private func startPrayerProgress() {
        prayerProgress = 0
        prayerTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
            if prayerProgress < 100 {
                prayerProgress += 1
            } else {
                prayerTimer?.invalidate()
                // 祈福完成後顯示成功頁面
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation {
                        showPrayerAnimation = false
                        showSuccessAnimation = true
                    }

                    // 如果有新成就，延遲顯示
                    if !unlockedAchievements.isEmpty {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            currentAchievementIndex = 0
                            showAchievementUnlocked = true
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppTheme.gold)
                .frame(width: 32)

            Text(title)
                .font(.system(size: AppTheme.FontSize.callout))
                .foregroundColor(AppTheme.whiteAlpha06)

            Spacer()

            Text(value)
                .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

struct TipRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.xs) {
            Text("•")
                .foregroundColor(AppTheme.whiteAlpha06)

            Text(text)
                .font(.system(size: AppTheme.FontSize.caption))
                .foregroundColor(AppTheme.whiteAlpha06)
        }
    }
}

// MARK: - Preview

#Preview {
    CheckInSheetView(
        temple: Temple.mockTemples[0],
        templeViewModel: TempleViewModel(),
        locationManager: LocationManager()
    )
}
