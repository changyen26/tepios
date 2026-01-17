/**
 * 活動列表頁面
 * 顯示所有可報名的活動，支援分類篩選
 */

import SwiftUI

struct EventListView: View {
    // MARK: - State

    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: EventCategory? = nil
    @State private var selectedEvent: Event? = nil
    @State private var showEventDetail = false

    // MARK: - Computed Properties

    private var filteredEvents: [Event] {
        let events = Event.mockEvents

        if let category = selectedCategory {
            return events.filter { $0.category == category }
        }

        return events
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // 背景漸層
                AppTheme.darkGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        // 分類篩選
                        categoryFilterSection
                            .padding(.top, AppTheme.Spacing.md)

                        // 活動列表
                        if filteredEvents.isEmpty {
                            emptyState
                        } else {
                            eventsSection
                        }

                        // 底部間距
                        Spacer(minLength: AppTheme.Spacing.xxxl)
                    }
                }
            }
            .navigationTitle("活動報名")
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
            .sheet(isPresented: $showEventDetail) {
                if let event = selectedEvent {
                    EventDetailView(event: event)
                }
            }
        }
    }

    // MARK: - Components

    /// 分類篩選區域
    private var categoryFilterSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("活動分類")
                .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, AppTheme.Spacing.xl)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    // 全部按鈕
                    categoryChip(
                        title: "全部",
                        isSelected: selectedCategory == nil
                    ) {
                        selectedCategory = nil
                    }

                    // 各分類按鈕
                    ForEach(EventCategory.allCases, id: \.self) { category in
                        categoryChip(
                            title: category.rawValue,
                            iconName: category.iconName,
                            color: Color(hex: category.color),
                            isSelected: selectedCategory == category
                        ) {
                            if selectedCategory == category {
                                selectedCategory = nil
                            } else {
                                selectedCategory = category
                            }
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.xl)
            }
        }
    }

    /// 分類按鈕
    private func categoryChip(
        title: String,
        iconName: String? = nil,
        color: Color = AppTheme.gold,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.xs) {
                if let icon = iconName {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                }

                Text(title)
                    .font(.system(size: AppTheme.FontSize.callout, weight: .medium))
            }
            .foregroundColor(isSelected ? AppTheme.dark : .white)
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
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

    /// 活動列表區域
    private var eventsSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            ForEach(filteredEvents) { event in
                eventCard(event)
                    .onTapGesture {
                        selectedEvent = event
                        showEventDetail = true
                    }
            }
        }
        .padding(.horizontal, AppTheme.Spacing.xl)
    }

    /// 活動卡片
    private func eventCard(_ event: Event) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // 頂部：分類和狀態
            HStack {
                // 分類標籤
                HStack(spacing: 4) {
                    Image(systemName: event.category.iconName)
                        .font(.system(size: 12))
                    Text(event.category.rawValue)
                        .font(.system(size: AppTheme.FontSize.caption, weight: .medium))
                }
                .foregroundColor(Color(hex: event.category.color))
                .padding(.horizontal, AppTheme.Spacing.sm)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color(hex: event.category.color).opacity(0.2))
                )

                Spacer()

                // 狀態標籤
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color(hex: event.status.color))
                        .frame(width: 6, height: 6)

                    Text(event.status.rawValue)
                        .font(.system(size: AppTheme.FontSize.caption, weight: .medium))
                        .foregroundColor(Color(hex: event.status.color))
                }
            }

            // 活動標題
            Text(event.title)
                .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(2)

            // 日期和地點
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.gold)

                    Text(event.dateRangeString)
                        .font(.system(size: AppTheme.FontSize.callout))
                        .foregroundColor(.white.opacity(0.8))
                }

                HStack(spacing: 6) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.gold)

                    Text(event.location)
                        .font(.system(size: AppTheme.FontSize.callout))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                }
            }

            // 底部資訊
            HStack {
                // 福報值獎勵
                if event.meritPointsReward > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12))
                        Text("+\(event.meritPointsReward)")
                            .font(.system(size: AppTheme.FontSize.caption, weight: .semibold))
                    }
                    .foregroundColor(AppTheme.gold)
                }

                Spacer()

                // 名額顯示
                if let remaining = event.remainingSlots {
                    Text("剩餘 \(remaining) 名")
                        .font(.system(size: AppTheme.FontSize.caption, weight: .medium))
                        .foregroundColor(remaining > 0 ? .green : .red)
                } else {
                    Text("名額無限制")
                        .font(.system(size: AppTheme.FontSize.caption, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }

                // 費用
                if event.fee > 0 {
                    Text("NT$ \(event.fee)")
                        .font(.system(size: AppTheme.FontSize.caption, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                } else {
                    Text("免費")
                        .font(.system(size: AppTheme.FontSize.caption, weight: .semibold))
                        .foregroundColor(.green)
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
    }

    /// 空狀態
    private var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.gold.opacity(0.5))

            Text("目前沒有相關活動")
                .font(.system(size: AppTheme.FontSize.headline, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.top, AppTheme.Spacing.xxxl)
    }
}

// MARK: - Preview

#Preview {
    EventListView()
}
