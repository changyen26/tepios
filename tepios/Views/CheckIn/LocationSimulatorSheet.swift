/**
 * 位置模擬器工具（開發測試用）
 * 用於在開發時模擬 GPS 位置以測試打卡功能
 */

import SwiftUI
import CoreLocation

struct LocationSimulatorSheet: View {
    // MARK: - Properties

    @ObservedObject var locationManager: LocationManager
    @Environment(\.dismiss) private var dismiss

    var onDismiss: (() -> Void)? = nil

    // MARK: - State

    @State private var selectedTemple: String = "南投受天宮"

    private let availableTemples = [
        "南投受天宮",
        "台北行天宮",
        "龍山寺",
        "關渡宮"
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
                        VStack(spacing: AppTheme.Spacing.md) {
                            Image(systemName: "location.fill.viewfinder")
                                .font(.system(size: 60))
                                .foregroundColor(AppTheme.gold)

                            Text("位置模擬器")
                                .font(.system(size: AppTheme.FontSize.title2, weight: .bold))
                                .foregroundColor(.white)

                            Text("開發測試工具 - 模擬 GPS 位置")
                                .font(.system(size: AppTheme.FontSize.callout))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, AppTheme.Spacing.xl)

                        // 當前狀態
                        VStack(spacing: AppTheme.Spacing.sm) {
                            HStack {
                                Text("當前狀態")
                                    .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                                    .foregroundColor(.white)
                                Spacer()
                            }

                            HStack {
                                Image(systemName: locationManager.isSimulationMode ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(locationManager.isSimulationMode ? .green : .red)

                                Text(locationManager.isSimulationMode ? "模擬模式啟用中" : "使用真實定位")
                                    .font(.system(size: AppTheme.FontSize.callout))
                                    .foregroundColor(.white)

                                Spacer()
                            }
                            .padding(AppTheme.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                    .fill(Color.white.opacity(0.1))
                            )

                            if let location = locationManager.location {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("緯度: \(location.coordinate.latitude, specifier: "%.4f")")
                                    Text("經度: \(location.coordinate.longitude, specifier: "%.4f")")
                                }
                                .font(.system(size: AppTheme.FontSize.caption, design: .monospaced))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(AppTheme.Spacing.sm)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm)
                                        .fill(Color.black.opacity(0.3))
                                )
                            }
                        }
                        .padding(.horizontal, AppTheme.Spacing.xl)

                        // 廟宇選擇
                        VStack(spacing: AppTheme.Spacing.md) {
                            HStack {
                                Text("選擇廟宇位置")
                                    .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                                    .foregroundColor(.white)
                                Spacer()
                            }

                            VStack(spacing: AppTheme.Spacing.sm) {
                                ForEach(availableTemples, id: \.self) { temple in
                                    templeButton(temple: temple)
                                }
                            }
                        }
                        .padding(.horizontal, AppTheme.Spacing.xl)

                        // 操作按鈕
                        VStack(spacing: AppTheme.Spacing.md) {
                            // 啟用模擬
                            if !locationManager.isSimulationMode {
                                Button(action: {
                                    print("🎯 啟用模擬位置: \(selectedTemple)")
                                    locationManager.simulateLocationNearTemple(selectedTemple)
                                    print("✅ 模擬位置已設定")
                                    if let loc = locationManager.location {
                                        print("📍 模擬座標: \(loc.coordinate.latitude), \(loc.coordinate.longitude)")
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "location.fill")
                                        Text("啟用模擬位置")
                                            .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                                    }
                                    .foregroundColor(AppTheme.dark)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(AppTheme.goldGradient)
                                    .cornerRadius(AppTheme.CornerRadius.md)
                                }
                            } else {
                                // 關閉模擬
                                Button(action: {
                                    locationManager.disableSimulationMode()
                                }) {
                                    HStack {
                                        Image(systemName: "location.slash.fill")
                                        Text("關閉模擬位置")
                                            .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(
                                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                            .fill(Color.red.opacity(0.8))
                                    )
                                }
                            }

                            // 關閉按鈕
                            Button(action: {
                                dismiss()
                                onDismiss?()
                            }) {
                                Text("關閉")
                                    .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.8))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                            }
                        }
                        .padding(.horizontal, AppTheme.Spacing.xl)

                        // 說明
                        VStack(spacing: AppTheme.Spacing.sm) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.blue)

                                Text("此工具僅用於開發測試")
                                    .font(.system(size: AppTheme.FontSize.caption))
                                    .foregroundColor(.white.opacity(0.8))

                                Spacer()
                            }

                            Text("啟用模擬模式後，App 將使用模擬的 GPS 座標而非真實位置。這樣您就可以測試打卡功能，無需實際前往廟宇。")
                                .font(.system(size: AppTheme.FontSize.caption))
                                .foregroundColor(.white.opacity(0.7))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(AppTheme.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                .fill(Color.blue.opacity(0.2))
                        )
                        .padding(.horizontal, AppTheme.Spacing.xl)

                        Spacer(minLength: AppTheme.Spacing.xxxl)
                    }
                }
            }
            .navigationTitle("位置模擬器")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Components

    private func templeButton(temple: String) -> some View {
        Button(action: {
            selectedTemple = temple
            // 如果已在模擬模式，立即切換位置
            if locationManager.isSimulationMode {
                locationManager.simulateLocationNearTemple(temple)
            }
        }) {
            HStack {
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 20))
                    .foregroundColor(selectedTemple == temple ? AppTheme.gold : .white.opacity(0.5))

                Text(temple)
                    .font(.system(size: AppTheme.FontSize.callout, weight: selectedTemple == temple ? .bold : .regular))
                    .foregroundColor(.white)

                Spacer()

                if selectedTemple == temple {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding(AppTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                    .fill(selectedTemple == temple ? Color.white.opacity(0.2) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                            .stroke(
                                selectedTemple == temple ? AppTheme.gold : Color.white.opacity(0.2),
                                lineWidth: selectedTemple == temple ? 2 : 1
                            )
                    )
            )
        }
    }
}

// MARK: - Preview

#Preview {
    LocationSimulatorSheet(locationManager: LocationManager())
}
