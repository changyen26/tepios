/**
 * 廟宇詳細資訊頁面
 */

import SwiftUI
import MapKit
import CoreLocation

struct TempleDetailView: View {
    // MARK: - Properties

    let temple: Temple
    @ObservedObject var templeViewModel: TempleViewModel
    @ObservedObject var locationManager: LocationManager

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    // MARK: - State

    @State private var showCheckInSheet = false
    @State private var showDonation = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = "提示"
    @State private var selectedTab: DetailTab = .info

    enum DetailTab: String, CaseIterable {
        case info = "資訊"
        case history = "歷史"
        case records = "打卡紀錄"
    }

    // MARK: - Computed Properties

    private var distance: Double? {
        guard let userLocation = locationManager.location else { return nil }
        return temple.distance(from: userLocation)
    }

    private var hasCheckedInToday: Bool {
        templeViewModel.hasCheckedInToday(at: temple)
    }

    private var visitCount: Int {
        templeViewModel.getVisitCount(for: temple)
    }

    private var canCheckIn: Bool {
        guard let userLocation = locationManager.location else { return false }
        return temple.isInCheckInRange(from: userLocation) && !hasCheckedInToday
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // 背景
            AppTheme.darkGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // 頂部圖片區域
                    headerImage

                    // 內容區域
                    VStack(spacing: AppTheme.Spacing.xl) {
                        // 基本資訊卡片
                        basicInfoCard

                        // Tab 切換
                        tabSelector

                        // 內容區域
                        Group {
                            switch selectedTab {
                            case .info:
                                infoContent
                            case .history:
                                historyContent
                            case .records:
                                recordsContent
                            }
                        }
                        .animation(.easeInOut(duration: 0.2), value: selectedTab)
                    }
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .padding(.bottom, 160) // 為底部按鈕預留空間
                }
            }

            // 底部打卡按鈕
            VStack {
                Spacer()
                bottomActions
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: shareTemple) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(AppTheme.gold)
                }
            }
        }
        .sheet(isPresented: $showCheckInSheet) {
            CheckInSheetView(
                temple: temple,
                templeViewModel: templeViewModel,
                locationManager: locationManager
            )
        }
        .fullScreenCover(isPresented: $showDonation) {
            DonationView()
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("確定", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - Components

    private var headerImage: some View {
        ZStack(alignment: .bottomLeading) {
            // 背景圖片
            if let firstImageName = temple.images.first, !firstImageName.isEmpty {
                // 顯示真實圖片
                Image(firstImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 250)
                    .clipped()
                    .overlay(
                        // 添加漸層遮罩讓底部文字更清楚
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.black.opacity(0.6)
                            ],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                    )
            } else {
                // 沒有圖片時使用漸層和圖標
                LinearGradient(
                    colors: [
                        AppTheme.gold.opacity(0.3),
                        AppTheme.gold.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 250)

                // 廟宇圖標
                Image(systemName: temple.deity.iconName)
                    .font(.system(size: 120))
                    .foregroundColor(.white.opacity(0.3))
                    .frame(maxWidth: .infinity)
            }

            // 狀態標籤
            HStack(spacing: AppTheme.Spacing.sm) {
                // 開放狀態
                StatusBadge(
                    text: temple.openingHours.isOpenNow() ? "營業中" : "休息中",
                    color: temple.openingHours.isOpenNow() ? .green : .red
                )

                Spacer()
            }
            .padding(AppTheme.Spacing.md)
        }
        .frame(height: 250)
    }

    private var basicInfoCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            // 廟宇名稱
            HStack {
                Text(temple.name)
                    .font(.system(size: AppTheme.FontSize.title1, weight: .bold))
                    .foregroundColor(.white)

                if templeViewModel.isFavoriteTemple(temple) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                }
            }

            // 副標題
            Text(temple.description)
                .font(.system(size: AppTheme.FontSize.callout))
                .foregroundColor(AppTheme.whiteAlpha06)

            // 主祀神明
            HStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: temple.deity.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.gold)

                VStack(alignment: .leading, spacing: 4) {
                    Text(temple.deity.name)
                        .font(.system(size: AppTheme.FontSize.headline, weight: .semibold))
                        .foregroundColor(.white)

                    Text(temple.deity.description)
                        .font(.system(size: AppTheme.FontSize.caption))
                        .foregroundColor(AppTheme.whiteAlpha06)
                }

                Spacer()
            }
            .padding(AppTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                    .fill(Color.white.opacity(0.05))
            )

            // 統計資訊
            HStack(spacing: AppTheme.Spacing.lg) {
                InfoItem(
                    icon: "mappin.circle.fill",
                    value: distance != nil ? "\(Int(distance!))m" : "--",
                    label: "距離"
                )

                InfoItem(
                    icon: "star.fill",
                    value: "\(temple.blessPoints)",
                    label: "福報值"
                )

                InfoItem(
                    icon: "checkmark.circle.fill",
                    value: "\(visitCount)",
                    label: "拜訪次數"
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
    }

    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(DetailTab.allCases, id: \.self) { tab in
                Button(action: {
                    selectedTab = tab
                }) {
                    Text(tab.rawValue)
                        .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                        .foregroundColor(selectedTab == tab ? AppTheme.dark : AppTheme.whiteAlpha06)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppTheme.Spacing.md)
                        .background(
                            selectedTab == tab ?
                                AppTheme.goldGradient :
                                LinearGradient(colors: [Color.clear], startPoint: .top, endPoint: .bottom)
                        )
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                .fill(Color.white.opacity(0.05))
        )
        .cornerRadius(AppTheme.CornerRadius.md)
    }

    private var infoContent: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            // 地址
            DetailInfoRow(
                icon: "location.fill",
                title: "地址",
                content: temple.address
            )

            // 電話
            if !temple.phoneNumber.isEmpty {
                DetailInfoRow(
                    icon: "phone.fill",
                    title: "電話",
                    content: temple.phoneNumber,
                    action: {
                        if let url = URL(string: "tel://\(temple.phoneNumber.replacingOccurrences(of: "-", with: ""))") {
                            openURL(url)
                        }
                    }
                )
            }

            // 開放時間
            DetailInfoRow(
                icon: "clock.fill",
                title: "開放時間",
                content: temple.openingHours.displayText
            )

            // 詳細介紹
            if !temple.introduction.isEmpty {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    Label("詳細介紹", systemImage: "doc.text.fill")
                        .font(.system(size: AppTheme.FontSize.headline, weight: .semibold))
                        .foregroundColor(AppTheme.gold)

                    Text(temple.introduction)
                        .font(.system(size: AppTheme.FontSize.body))
                        .foregroundColor(AppTheme.whiteAlpha08)
                        .lineSpacing(4)
                }
                .padding(AppTheme.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                        .fill(Color.white.opacity(0.05))
                )
            }

            // 特色標籤
            if !temple.features.isEmpty {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    Text("特色")
                        .font(.system(size: AppTheme.FontSize.headline, weight: .semibold))
                        .foregroundColor(AppTheme.gold)

                    FlowLayout(spacing: AppTheme.Spacing.sm) {
                        ForEach(temple.features, id: \.self) { feature in
                            Text(feature)
                                .font(.system(size: AppTheme.FontSize.caption))
                                .foregroundColor(.white)
                                .padding(.horizontal, AppTheme.Spacing.md)
                                .padding(.vertical, AppTheme.Spacing.xs)
                                .background(
                                    Capsule()
                                        .fill(AppTheme.gold.opacity(0.2))
                                )
                        }
                    }
                }
            }
        }
    }

    private var historyContent: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            if !temple.history.isEmpty {
                Label("歷史沿革", systemImage: "book.fill")
                    .font(.system(size: AppTheme.FontSize.headline, weight: .semibold))
                    .foregroundColor(AppTheme.gold)

                Text(temple.history)
                    .font(.system(size: AppTheme.FontSize.body))
                    .foregroundColor(AppTheme.whiteAlpha08)
                    .lineSpacing(6)
                    .padding(AppTheme.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                            .fill(Color.white.opacity(0.05))
                    )
            } else {
                EmptyStateView(
                    icon: "book.closed.fill",
                    message: "暫無歷史資料"
                )
            }
        }
    }

    private var recordsContent: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            let records = templeViewModel.getCheckInRecords(for: temple.id)

            if !records.isEmpty {
                Text("打卡紀錄 (\(records.count))")
                    .font(.system(size: AppTheme.FontSize.headline, weight: .semibold))
                    .foregroundColor(AppTheme.gold)

                ForEach(records) { record in
                    CheckInRecordCard(record: record)
                }
            } else {
                EmptyStateView(
                    icon: "checkmark.circle",
                    message: "尚無打卡紀錄\n快來打卡吧！"
                )
            }
        }
    }

    private var bottomActions: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // 捐款按鈕
            Button(action: {
                showDonation = true
            }) {
                HStack {
                    Image(systemName: "hands.sparkles.fill")
                        .font(.system(size: 20))

                    Text("捐香油錢")
                        .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "4CAF50"), Color(hex: "45A049")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(AppTheme.CornerRadius.md)
                .shadow(
                    color: Color(hex: "4CAF50").opacity(0.3),
                    radius: 12,
                    x: 0,
                    y: 4
                )
            }

            // 導航按鈕
            Button(action: openMaps) {
                HStack {
                    Image(systemName: "map.fill")
                        .font(.system(size: 20))

                    Text("開啟導航")
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
        .padding(.horizontal, AppTheme.Spacing.xl)
        .padding(.bottom, AppTheme.Spacing.xxl)
        .background(
            LinearGradient(
                colors: [
                    Color.clear,
                    AppTheme.dark.opacity(0.8),
                    AppTheme.dark
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }

    // MARK: - Methods

    private func handleCheckIn() {
        guard let userLocation = locationManager.location else {
            alertTitle = "定位失敗"
            alertMessage = "無法取得您的位置，請確認定位服務已開啟"
            showAlert = true
            return
        }

        let validation = CheckInValidator.canCheckIn(
            at: temple,
            from: userLocation,
            lastCheckIn: templeViewModel.checkInRecords.last
        )

        if validation.isValid {
            showCheckInSheet = true
        } else {
            alertTitle = "無法打卡"
            alertMessage = validation.errorMessage ?? "打卡失敗"
            showAlert = true
        }
    }

    private func openMaps() {
        let placemark = MKPlacemark(coordinate: temple.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = temple.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
        ])
    }

    private func shareTemple() {
        // TODO: 實作分享功能
        alertTitle = "分享"
        alertMessage = "分享功能開發中"
        showAlert = true
    }
}

// MARK: - Supporting Views

struct StatusBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.system(size: AppTheme.FontSize.caption2, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, AppTheme.Spacing.sm)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(color)
            )
    }
}

struct InfoItem: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppTheme.gold)

            Text(value)
                .font(.system(size: AppTheme.FontSize.callout, weight: .bold))
                .foregroundColor(.white)

            Text(label)
                .font(.system(size: AppTheme.FontSize.caption2))
                .foregroundColor(AppTheme.whiteAlpha06)
        }
        .frame(maxWidth: .infinity)
    }
}

struct DetailInfoRow: View {
    let icon: String
    let title: String
    let content: String
    var action: (() -> Void)? = nil

    var body: some View {
        Button(action: {
            action?()
        }) {
            HStack(alignment: .top, spacing: AppTheme.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.gold)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: AppTheme.FontSize.caption))
                        .foregroundColor(AppTheme.whiteAlpha06)

                    Text(content)
                        .font(.system(size: AppTheme.FontSize.body))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.whiteAlpha06)
                }
            }
            .padding(AppTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                    .fill(Color.white.opacity(0.05))
            )
        }
        .disabled(action == nil)
    }
}

struct CheckInRecordCard: View {
    let record: CheckInRecord

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // 日期
            VStack(spacing: 4) {
                Text(record.formattedShortDate)
                    .font(.system(size: AppTheme.FontSize.callout, weight: .bold))
                    .foregroundColor(AppTheme.gold)

                Text(record.dayOfWeek)
                    .font(.system(size: AppTheme.FontSize.caption2))
                    .foregroundColor(AppTheme.whiteAlpha06)
            }
            .frame(width: 60)

            Divider()
                .background(AppTheme.gold.opacity(0.3))

            // 資訊
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: record.checkInType.icon)
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.gold)

                    Text(record.checkInType.rawValue)
                        .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                        .foregroundColor(.white)
                }

                Text("+\(record.earnedPoints) 福報值")
                    .font(.system(size: AppTheme.FontSize.caption))
                    .foregroundColor(.green)
            }

            Spacer()
        }
        .padding(AppTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct EmptyStateView: View {
    let icon: String
    let message: String

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(AppTheme.whiteAlpha06)

            Text(message)
                .font(.system(size: AppTheme.FontSize.callout))
                .foregroundColor(AppTheme.whiteAlpha06)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.xxxl)
    }
}

// Simple FlowLayout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                frames.append(CGRect(origin: CGPoint(x: currentX, y: currentY), size: size))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }

            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TempleDetailView(
            temple: Temple.mockTemples[0],
            templeViewModel: TempleViewModel(),
            locationManager: LocationManager()
        )
    }
}
