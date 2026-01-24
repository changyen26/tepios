/**
 * 打卡選擇頁面
 * 提供 QR Code 掃描和定位打卡兩種方式
 */

import SwiftUI

struct CheckInOptionsView: View {
    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    @State private var showQRScanner = false
    @State private var showNFCScanner = false
    @State private var showLocationCheckIn = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // 背景漸層
                AppTheme.darkGradient
                    .ignoresSafeArea()

                VStack(spacing: AppTheme.Spacing.xxxl) {
                    Spacer()

                    // 標題
                    VStack(spacing: AppTheme.Spacing.md) {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.system(size: 80))
                            .foregroundColor(AppTheme.gold)
                            .shadow(
                                color: AppTheme.gold.opacity(0.5),
                                radius: 20,
                                x: 0,
                                y: 10
                            )

                        Text("選擇打卡方式")
                            .font(.system(size: AppTheme.FontSize.title1, weight: .bold))
                            .foregroundColor(.white)

                        Text("請選擇您想要使用的打卡方式")
                            .font(.system(size: AppTheme.FontSize.callout))
                            .foregroundColor(.white.opacity(0.7))
                    }

                    // 選項卡片
                    VStack(spacing: AppTheme.Spacing.lg) {
                        // QR Code 掃描
                        checkInOptionCard(
                            icon: "qrcode.viewfinder",
                            title: "掃描 QR Code",
                            description: "掃描廟宇的 QR Code 快速打卡",
                            color: "4CAF50",
                            gradientColors: ["4CAF50", "45A049"]
                        ) {
                            showQRScanner = true
                        }

                        // NFC 感應
                        checkInOptionCard(
                            icon: "wave.3.right",
                            title: "NFC 感應",
                            description: "將手機靠近廟宇的 NFC 標籤感應",
                            color: "FF9800",
                            gradientColors: ["FF9800", "F57C00"]
                        ) {
                            showNFCScanner = true
                        }

                        // 定位打卡
                        checkInOptionCard(
                            icon: "location.fill",
                            title: "定位打卡",
                            description: "使用您的位置找到附近廟宇打卡",
                            color: "2196F3",
                            gradientColors: ["2196F3", "1976D2"]
                        ) {
                            showLocationCheckIn = true
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.xl)

                    Spacer()

                    // 取消按鈕
                    Button(action: {
                        dismiss()
                    }) {
                        Text("取消")
                            .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                    }
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .padding(.bottom, AppTheme.Spacing.xxl)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showQRScanner) {
                TempleQRScanView()
            }
            .fullScreenCover(isPresented: $showNFCScanner) {
                NFCScanView()
            }
            .fullScreenCover(isPresented: $showLocationCheckIn) {
                LocationCheckInView()
            }
        }
    }

    // MARK: - Components

    private func checkInOptionCard(
        icon: String,
        title: String,
        description: String,
        color: String,
        gradientColors: [String],
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.lg) {
                // 圖標
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradientColors.map { Color(hex: $0) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                        .shadow(
                            color: Color(hex: color).opacity(0.4),
                            radius: 12,
                            x: 0,
                            y: 6
                        )

                    Image(systemName: icon)
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                }

                // 文字
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                        .foregroundColor(.white)

                    Text(description)
                        .font(.system(size: AppTheme.FontSize.caption))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }

                Spacer()

                // 箭頭
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(AppTheme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                            .stroke(Color(hex: color).opacity(0.4), lineWidth: 1.5)
                    )
            )
            .shadow(
                color: Color(hex: color).opacity(0.2),
                radius: 10,
                x: 0,
                y: 5
            )
        }
    }
}

// MARK: - Preview

#Preview {
    CheckInOptionsView()
}
