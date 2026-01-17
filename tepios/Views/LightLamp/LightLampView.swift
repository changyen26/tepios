/**
 * 點燈祈福主頁面
 */

import SwiftUI

struct LightLampView: View {
    // MARK: - State

    @Environment(\.dismiss) private var dismiss
    @State private var myLamps: [LightLamp] = LightLamp.mockLamps
    @State private var showCreateLamp = false
    @State private var selectedLamp: LightLamp?
    @State private var showLampDetail = false

    // MARK: - Computed Properties

    private var activeLamps: [LightLamp] {
        myLamps.filter { $0.status == .active && !$0.isExpired }
    }

    private var expiredLamps: [LightLamp] {
        myLamps.filter { $0.isExpired || $0.status == .expired }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // 背景
                AppTheme.darkGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        // 頂部說明
                        headerSection
                            .padding(.top, AppTheme.Spacing.lg)

                        // 新增點燈按鈕
                        addLampButton
                            .padding(.horizontal, AppTheme.Spacing.xl)

                        // 點燈中的燈
                        if !activeLamps.isEmpty {
                            activeLampsSection
                        }

                        // 已到期的燈
                        if !expiredLamps.isEmpty {
                            expiredLampsSection
                        }

                        // 空狀態
                        if myLamps.isEmpty {
                            emptyState
                        }

                        // 底部間距
                        Spacer(minLength: AppTheme.Spacing.xxxl)
                    }
                }
            }
            .navigationTitle("點燈祈福")
            .navigationBarTitleDisplayMode(.inline)
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
            .sheet(isPresented: $showCreateLamp) {
                LightLampCreateView { newLamp in
                    myLamps.insert(newLamp, at: 0)
                }
            }
            .sheet(item: $selectedLamp) { lamp in
                LightLampDetailView(lamp: lamp)
            }
        }
    }

    // MARK: - Components

    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "flame.fill")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.gold)

            Text("點燈祈福")
                .font(.system(size: AppTheme.FontSize.title2, weight: .bold))
                .foregroundColor(.white)

            Text("為自己與家人點一盞祈福的明燈")
                .font(.system(size: AppTheme.FontSize.callout))
                .foregroundColor(AppTheme.whiteAlpha06)
                .multilineTextAlignment(.center)
        }
    }

    private var addLampButton: some View {
        Button(action: { showCreateLamp = true }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))

                Text("新增點燈")
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

    private var activeLampsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Image(systemName: "flame.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.gold)

                Text("點燈中 (\(activeLamps.count))")
                    .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, AppTheme.Spacing.xl)

            ForEach(activeLamps) { lamp in
                LampCard(lamp: lamp)
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .onTapGesture {
                        selectedLamp = lamp
                    }
            }
        }
    }

    private var expiredLampsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Image(systemName: "clock.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.whiteAlpha06)

                Text("已到期 (\(expiredLamps.count))")
                    .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                    .foregroundColor(AppTheme.whiteAlpha06)
            }
            .padding(.horizontal, AppTheme.Spacing.xl)

            ForEach(expiredLamps) { lamp in
                LampCard(lamp: lamp)
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .opacity(0.6)
                    .onTapGesture {
                        selectedLamp = lamp
                    }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "flame")
                .font(.system(size: 80))
                .foregroundColor(AppTheme.whiteAlpha06)

            Text("尚未點燈")
                .font(.system(size: AppTheme.FontSize.title3, weight: .semibold))
                .foregroundColor(AppTheme.whiteAlpha08)

            Text("點擊上方按鈕開始為自己或家人點燈祈福")
                .font(.system(size: AppTheme.FontSize.callout))
                .foregroundColor(AppTheme.whiteAlpha06)
                .multilineTextAlignment(.center)
        }
        .padding(.top, AppTheme.Spacing.xxxl)
        .padding(.horizontal, AppTheme.Spacing.xl)
    }
}

// MARK: - Lamp Card Component

struct LampCard: View {
    let lamp: LightLamp

    var body: some View {
        VStack(spacing: 0) {
            // 上半部 - 燈的資訊
            HStack(spacing: AppTheme.Spacing.lg) {
                // 燈圖標
                ZStack {
                    Circle()
                        .fill(Color(hex: lamp.lampType.color).opacity(0.2))
                        .frame(width: 60, height: 60)

                    Image(systemName: lamp.lampType.icon)
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: lamp.lampType.color))
                }

                // 燈資訊
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(lamp.lampType.rawValue)
                        .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                        .foregroundColor(.white)

                    Text(lamp.beneficiaryName)
                        .font(.system(size: AppTheme.FontSize.callout))
                        .foregroundColor(AppTheme.whiteAlpha08)

                    Text(lamp.templeName)
                        .font(.system(size: AppTheme.FontSize.caption))
                        .foregroundColor(AppTheme.whiteAlpha06)
                }

                Spacer()

                // 狀態標籤
                VStack(alignment: .trailing, spacing: AppTheme.Spacing.xs) {
                    Text(lamp.status.rawValue)
                        .font(.system(size: AppTheme.FontSize.caption2, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, AppTheme.Spacing.sm)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color(hex: lamp.status.color))
                        )

                    if !lamp.isExpired && lamp.status == .active {
                        Text("剩 \(lamp.daysRemaining) 天")
                            .font(.system(size: AppTheme.FontSize.caption))
                            .foregroundColor(AppTheme.whiteAlpha06)
                    }
                }
            }
            .padding(AppTheme.Spacing.lg)

            // 分隔線
            Divider()
                .overlay(AppTheme.gold.opacity(0.2))

            // 下半部 - 祈福目的
            if !lamp.purpose.isEmpty {
                HStack {
                    Image(systemName: "quote.opening")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.gold.opacity(0.6))

                    Text(lamp.purpose)
                        .font(.system(size: AppTheme.FontSize.callout))
                        .foregroundColor(AppTheme.whiteAlpha08)
                        .lineLimit(2)

                    Spacer()
                }
                .padding(AppTheme.Spacing.lg)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                        .stroke(Color(hex: lamp.lampType.color).opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(
            color: Color(hex: lamp.lampType.color).opacity(0.1),
            radius: 8,
            x: 0,
            y: 4
        )
    }
}

// MARK: - Preview

#Preview {
    LightLampView()
}
