/**
 * 打卡歷史紀錄頁面
 */

import SwiftUI

struct CheckInHistoryView: View {
    // MARK: - Properties

    @ObservedObject var templeViewModel: TempleViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    @State private var selectedPeriod: TimePeriod = .week
    @State private var showDetailSheet = false
    @State private var selectedRecord: CheckInRecord?

    enum TimePeriod: String, CaseIterable {
        case week = "本週"
        case month = "本月"
        case all = "全部"
    }

    // MARK: - Computed Properties

    private var filteredRecords: [CheckInRecord] {
        switch selectedPeriod {
        case .week:
            return templeViewModel.getWeekCheckIns()
        case .month:
            return templeViewModel.getMonthCheckIns()
        case .all:
            return templeViewModel.checkInRecords.sorted { $0.checkInDate > $1.checkInDate }
        }
    }

    private var totalPoints: Int {
        filteredRecords.reduce(0) { $0 + $1.earnedPoints }
    }

    private var averagePoints: Int {
        guard !filteredRecords.isEmpty else { return 0 }
        return totalPoints / filteredRecords.count
    }

    private var uniqueTemples: Int {
        Set(filteredRecords.map { $0.templeId }).count
    }

    private var consecutiveDays: Int {
        templeViewModel.statistics.currentStreak
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // 背景
            AppTheme.darkGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppTheme.Spacing.xxl) {
                    // 標題
                    headerSection
                        .padding(.top, AppTheme.Spacing.xl)

                    // 時期選擇器
                    periodSelector
                        .padding(.horizontal, AppTheme.Spacing.xl)

                    // 統計卡片
                    statisticsCards
                        .padding(.horizontal, AppTheme.Spacing.xl)

                    // 福報值趨勢圖
                    pointsTrendChart
                        .padding(.horizontal, AppTheme.Spacing.xl)

                    // 打卡紀錄列表
                    checkInRecordsList
                        .padding(.horizontal, AppTheme.Spacing.xl)
                        .padding(.bottom, AppTheme.Spacing.xxxl)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedRecord) { record in
            CheckInDetailSheet(record: record, templeViewModel: templeViewModel)
        }
    }

    // MARK: - Components

    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.gold)
                .shadow(
                    color: AppTheme.gold.opacity(0.5),
                    radius: 20,
                    x: 0,
                    y: 10
                )

            Text("打卡紀錄")
                .font(.system(size: AppTheme.FontSize.title1, weight: .bold))
                .foregroundColor(.white)

            Text("您的修行之路")
                .font(.system(size: AppTheme.FontSize.callout))
                .foregroundColor(AppTheme.whiteAlpha06)
        }
    }

    private var periodSelector: some View {
        HStack(spacing: 0) {
            ForEach(TimePeriod.allCases, id: \.self) { period in
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        selectedPeriod = period
                    }
                }) {
                    Text(period.rawValue)
                        .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                        .foregroundColor(selectedPeriod == period ? AppTheme.dark : AppTheme.whiteAlpha08)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppTheme.Spacing.md)
                        .background(
                            selectedPeriod == period ?
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

    private var statisticsCards: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.md) {
                // 總福報值
                CheckInStatCard(
                    icon: "star.fill",
                    value: "\(totalPoints)",
                    label: "總福報值",
                    color: .yellow
                )

                // 平均福報值
                CheckInStatCard(
                    icon: "chart.bar.fill",
                    value: "\(averagePoints)",
                    label: "平均值",
                    color: .blue
                )
            }

            HStack(spacing: AppTheme.Spacing.md) {
                // 打卡次數
                CheckInStatCard(
                    icon: "checkmark.circle.fill",
                    value: "\(filteredRecords.count)",
                    label: "打卡次數",
                    color: .green
                )

                // 拜訪廟宇
                CheckInStatCard(
                    icon: "building.2.fill",
                    value: "\(uniqueTemples)",
                    label: "拜訪廟宇",
                    color: .purple
                )
            }

            // 連續打卡天數（全期間統計）
            HStack {
                Image(systemName: "flame.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.orange)

                VStack(alignment: .leading, spacing: 4) {
                    Text("連續打卡")
                        .font(.system(size: AppTheme.FontSize.caption))
                        .foregroundColor(AppTheme.whiteAlpha06)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(consecutiveDays)")
                            .font(.system(size: AppTheme.FontSize.title2, weight: .bold))
                            .foregroundColor(.orange)

                        Text("天")
                            .font(.system(size: AppTheme.FontSize.callout))
                            .foregroundColor(AppTheme.whiteAlpha08)

                        Spacer()

                        Text("最長：\(templeViewModel.statistics.longestStreak) 天")
                            .font(.system(size: AppTheme.FontSize.caption))
                            .foregroundColor(AppTheme.whiteAlpha06)
                    }
                }

                Spacer()
            }
            .padding(AppTheme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }

    private var pointsTrendChart: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Text("福報值趨勢")
                    .font(.system(size: AppTheme.FontSize.headline, weight: .semibold))
                    .foregroundColor(AppTheme.gold)

                Spacer()

                Text("近7日")
                    .font(.system(size: AppTheme.FontSize.caption))
                    .foregroundColor(AppTheme.whiteAlpha06)
            }

            let chartData = templeViewModel.getPointsHistory(days: 7)
            let maxPoints = chartData.map { $0.points }.max() ?? 1

            if !chartData.isEmpty {
                HStack(alignment: .bottom, spacing: AppTheme.Spacing.sm) {
                    ForEach(Array(chartData.enumerated()), id: \.offset) { index, data in
                        VStack(spacing: AppTheme.Spacing.xs) {
                            // 數值標籤
                            if data.points > 0 {
                                Text("\(data.points)")
                                    .font(.system(size: AppTheme.FontSize.caption2, weight: .semibold))
                                    .foregroundColor(AppTheme.gold)
                            } else {
                                Text(" ")
                                    .font(.system(size: AppTheme.FontSize.caption2))
                            }

                            // 長條
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    data.points > 0 ?
                                        AppTheme.goldGradient :
                                        LinearGradient(
                                            colors: [Color.gray.opacity(0.2)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                )
                                .frame(
                                    height: data.points > 0 ?
                                        max(CGFloat(data.points) / CGFloat(maxPoints) * 120, 20) :
                                        20
                                )
                                .shadow(
                                    color: data.points > 0 ? AppTheme.gold.opacity(0.3) : .clear,
                                    radius: 6,
                                    x: 0,
                                    y: 2
                                )

                            // 日期標籤
                            Text(data.date)
                                .font(.system(size: AppTheme.FontSize.caption2))
                                .foregroundColor(AppTheme.whiteAlpha06)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 160)
                .padding(AppTheme.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                        .fill(Color.white.opacity(0.05))
                )
            } else {
                EmptyChartView()
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

    private var checkInRecordsList: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Text("打卡紀錄")
                    .font(.system(size: AppTheme.FontSize.headline, weight: .semibold))
                    .foregroundColor(AppTheme.gold)

                Spacer()

                Text("\(filteredRecords.count) 筆")
                    .font(.system(size: AppTheme.FontSize.caption))
                    .foregroundColor(AppTheme.whiteAlpha06)
            }

            if filteredRecords.isEmpty {
                EmptyRecordsView()
            } else {
                VStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(filteredRecords) { record in
                        CheckInRecordRow(record: record)
                            .onTapGesture {
                                selectedRecord = record
                            }
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct CheckInStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: AppTheme.FontSize.title2, weight: .bold))
                .foregroundColor(.white)

            Text(label)
                .font(.system(size: AppTheme.FontSize.caption))
                .foregroundColor(AppTheme.whiteAlpha06)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct CheckInRecordRow: View {
    let record: CheckInRecord

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // 打卡類型圖標
            ZStack {
                Circle()
                    .fill(AppTheme.gold.opacity(0.2))
                    .frame(width: 48, height: 48)

                Image(systemName: record.checkInType.icon)
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.gold)
            }

            // 資訊
            VStack(alignment: .leading, spacing: 4) {
                Text(record.templeName)
                    .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                    .foregroundColor(.white)

                HStack(spacing: AppTheme.Spacing.xs) {
                    Text(record.formattedDate)
                        .font(.system(size: AppTheme.FontSize.caption))
                        .foregroundColor(AppTheme.whiteAlpha06)

                    Text("•")
                        .foregroundColor(AppTheme.whiteAlpha06)

                    Text(record.checkInType.rawValue)
                        .font(.system(size: AppTheme.FontSize.caption))
                        .foregroundColor(AppTheme.gold.opacity(0.8))
                }

                if record.isConsecutive {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.orange)

                        Text("連續 \(record.consecutiveDays) 天")
                            .font(.system(size: AppTheme.FontSize.caption2))
                            .foregroundColor(.orange)
                    }
                }
            }

            Spacer()

            // 福報值
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Text("+\(record.earnedPoints)")
                        .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                        .foregroundColor(.green)

                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)
                }

                Text("福報值")
                    .font(.system(size: AppTheme.FontSize.caption2))
                    .foregroundColor(AppTheme.whiteAlpha06)
            }
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
}

struct EmptyChartView: View {
    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.whiteAlpha06)

            Text("尚無資料")
                .font(.system(size: AppTheme.FontSize.callout))
                .foregroundColor(AppTheme.whiteAlpha06)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct EmptyRecordsView: View {
    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 64))
                .foregroundColor(AppTheme.whiteAlpha06)

            VStack(spacing: AppTheme.Spacing.xs) {
                Text("尚無打卡紀錄")
                    .font(.system(size: AppTheme.FontSize.headline))
                    .foregroundColor(.white)

                Text("快去廟宇打卡，開始您的修行之旅吧！")
                    .font(.system(size: AppTheme.FontSize.callout))
                    .foregroundColor(AppTheme.whiteAlpha06)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.xxxl)
    }
}

// MARK: - CheckIn Detail Sheet

struct CheckInDetailSheet: View {
    let record: CheckInRecord
    @ObservedObject var templeViewModel: TempleViewModel
    @Environment(\.dismiss) private var dismiss

    private var temple: Temple? {
        templeViewModel.getTemple(by: record.templeId)
    }

    var body: some View {
        ZStack {
            AppTheme.darkGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    // 標題
                    VStack(spacing: AppTheme.Spacing.md) {
                        Image(systemName: record.checkInType.icon)
                            .font(.system(size: 64))
                            .foregroundColor(AppTheme.gold)

                        Text(record.templeName)
                            .font(.system(size: AppTheme.FontSize.title2, weight: .bold))
                            .foregroundColor(.white)

                        Text(record.checkInType.rawValue)
                            .font(.system(size: AppTheme.FontSize.callout))
                            .foregroundColor(AppTheme.gold)
                            .padding(.horizontal, AppTheme.Spacing.md)
                            .padding(.vertical, AppTheme.Spacing.xs)
                            .background(
                                Capsule()
                                    .fill(AppTheme.gold.opacity(0.2))
                            )
                    }
                    .padding(.top, AppTheme.Spacing.xxl)

                    // 詳細資訊
                    VStack(spacing: AppTheme.Spacing.md) {
                        DetailRow(
                            icon: "calendar",
                            label: "打卡時間",
                            value: record.formattedDate
                        )

                        DetailRow(
                            icon: "star.fill",
                            label: "獲得福報值",
                            value: "+\(record.earnedPoints)"
                        )

                        if record.isConsecutive {
                            DetailRow(
                                icon: "flame.fill",
                                label: "連續打卡",
                                value: "\(record.consecutiveDays) 天"
                            )
                        }

                        if let temple = temple {
                            DetailRow(
                                icon: "location.fill",
                                label: "主祀神明",
                                value: temple.deity.name
                            )
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.xl)

                    // 打卡心得
                    if !record.notes.isEmpty {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                            Label("打卡心得", systemImage: "text.bubble.fill")
                                .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                                .foregroundColor(AppTheme.gold)

                            Text(record.notes)
                                .font(.system(size: AppTheme.FontSize.body))
                                .foregroundColor(AppTheme.whiteAlpha08)
                                .padding(AppTheme.Spacing.md)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                        .fill(Color.white.opacity(0.05))
                                )
                        }
                        .padding(.horizontal, AppTheme.Spacing.xl)
                    }

                    // 關閉按鈕
                    Button(action: {
                        dismiss()
                    }) {
                        Text("關閉")
                            .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                            .foregroundColor(AppTheme.dark)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(AppTheme.goldGradient)
                            .cornerRadius(AppTheme.CornerRadius.md)
                    }
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .padding(.bottom, AppTheme.Spacing.xxl)
                }
            }
        }
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppTheme.gold)
                .frame(width: 32)

            Text(label)
                .font(.system(size: AppTheme.FontSize.callout))
                .foregroundColor(AppTheme.whiteAlpha06)

            Spacer()

            Text(value)
                .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(AppTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                .fill(Color.white.opacity(0.05))
        )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CheckInHistoryView(templeViewModel: TempleViewModel())
    }
}
