/**
 * 點燈詳情頁面
 */

import SwiftUI

struct LightLampDetailView: View {
    // MARK: - Properties

    let lamp: LightLamp
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // 背景
                AppTheme.darkGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        // 頂部燈圖標
                        lampIconSection
                            .padding(.top, AppTheme.Spacing.xl)

                        // 燈資訊卡片
                        lampInfoCard

                        // 祈福對象資訊
                        beneficiaryInfoCard

                        // 時間資訊
                        timeInfoCard

                        // 底部間距
                        Spacer(minLength: AppTheme.Spacing.xxxl)
                    }
                    .padding(.horizontal, AppTheme.Spacing.xl)
                }
            }
            .navigationTitle("點燈詳情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("關閉") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.gold)
                }
            }
        }
    }

    // MARK: - Components

    private var lampIconSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color(hex: lamp.lampType.color).opacity(0.2))
                    .frame(width: 120, height: 120)
                    .overlay(
                        Circle()
                            .stroke(Color(hex: lamp.lampType.color).opacity(0.5), lineWidth: 2)
                    )

                Image(systemName: lamp.lampType.icon)
                    .font(.system(size: 60))
                    .foregroundColor(Color(hex: lamp.lampType.color))
            }

            Text(lamp.lampType.rawValue)
                .font(.system(size: AppTheme.FontSize.title2, weight: .bold))
                .foregroundColor(.white)

            Text(lamp.lampType.description)
                .font(.system(size: AppTheme.FontSize.callout))
                .foregroundColor(AppTheme.whiteAlpha06)
                .multilineTextAlignment(.center)

            // 狀態標籤
            Text(lamp.status.rawValue)
                .font(.system(size: AppTheme.FontSize.callout, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(
                    Capsule()
                        .fill(Color(hex: lamp.status.color))
                )
        }
    }

    private var lampInfoCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(AppTheme.gold)

                Text("點燈資訊")
                    .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                    .foregroundColor(.white)
            }

            Divider()
                .overlay(AppTheme.gold.opacity(0.2))

            LampInfoRow(title: "廟宇", value: lamp.templeName)
            LampInfoRow(title: "點燈期間", value: lamp.duration.rawValue)
            LampInfoRow(title: "費用", value: "NT$ \(lamp.price)")

            if !lamp.purpose.isEmpty {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text("祈福目的")
                        .font(.system(size: AppTheme.FontSize.callout, weight: .medium))
                        .foregroundColor(AppTheme.whiteAlpha06)

                    Text(lamp.purpose)
                        .font(.system(size: AppTheme.FontSize.body))
                        .foregroundColor(.white)
                        .padding(AppTheme.Spacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm)
                                .fill(Color.white.opacity(0.05))
                        )
                }
                .padding(.top, AppTheme.Spacing.xs)
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

    private var beneficiaryInfoCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(AppTheme.gold)

                Text("祈福對象")
                    .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                    .foregroundColor(.white)
            }

            Divider()
                .overlay(AppTheme.gold.opacity(0.2))

            LampInfoRow(title: "姓名", value: lamp.beneficiaryName)

            if let birthday = lamp.beneficiaryBirthday {
                LampInfoRow(title: "生辰", value: formatDate(birthday))
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

    private var timeInfoCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(AppTheme.gold)

                Text("時間資訊")
                    .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                    .foregroundColor(.white)
            }

            Divider()
                .overlay(AppTheme.gold.opacity(0.2))

            LampInfoRow(title: "開始日期", value: formatDate(lamp.startDate))
            LampInfoRow(title: "結束日期", value: formatDate(lamp.endDate))

            if !lamp.isExpired && lamp.status == .active {
                HStack {
                    Text("剩餘天數")
                        .font(.system(size: AppTheme.FontSize.callout, weight: .medium))
                        .foregroundColor(AppTheme.whiteAlpha06)

                    Spacer()

                    Text("\(lamp.daysRemaining) 天")
                        .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                        .foregroundColor(AppTheme.gold)
                }
            }

            LampInfoRow(title: "建立日期", value: formatDate(lamp.createdDate))
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

    // MARK: - Helper Methods

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        formatter.locale = Locale(identifier: "zh_TW")
        return formatter.string(from: date)
    }
}

// MARK: - Lamp Info Row Component

struct LampInfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: AppTheme.FontSize.callout, weight: .medium))
                .foregroundColor(AppTheme.whiteAlpha06)

            Spacer()

            Text(value)
                .font(.system(size: AppTheme.FontSize.body))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Preview

#Preview {
    LightLampDetailView(lamp: LightLamp.mockLamps[0])
}
