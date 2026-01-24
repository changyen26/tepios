/**
 * 定位打卡頁面
 * 顯示附近廟宇並讓用戶選擇打卡
 */

import SwiftUI
import MapKit

struct LocationCheckInView: View {
    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var templeViewModel = TempleViewModel.shared
    @State private var selectedTemple: Temple?
    @State private var showCheckInSheet = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showLocationSimulator = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // 背景
                AppTheme.darkGradient
                    .ignoresSafeArea()

                if let location = locationManager.location {
                    contentView(userLocation: location)
                } else if locationManager.errorMessage != nil {
                    errorView
                } else {
                    loadingView
                }
            }
            .navigationTitle("定位打卡")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        // 重置廟宇資料按鈕（開發用）
                        Button(action: {
                            print("🔄 重置廟宇資料")
                            templeViewModel.resetToMockTemples()
                        }) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 20))
                                .foregroundColor(.orange)
                        }

                        // 位置模擬器按鈕
                        Button(action: {
                            showLocationSimulator = true
                        }) {
                            Image(systemName: "location.viewfinder")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .sheet(item: $selectedTemple) { temple in
                CheckInSheetView(
                    temple: temple,
                    templeViewModel: templeViewModel,
                    locationManager: locationManager
                )
            }
            .alert("提示", isPresented: $showAlert) {
                Button("確定", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                locationManager.requestLocationPermission()
            }
            .sheet(isPresented: $showLocationSimulator) {
                LocationSimulatorSheet(locationManager: LocationManager.shared)
            }
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.gold))
                .scaleEffect(1.5)

            Text("正在定位中...")
                .font(.system(size: AppTheme.FontSize.headline))
                .foregroundColor(.white)
        }
    }

    // MARK: - Error View

    private var errorView: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Image(systemName: "location.slash.fill")
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.5))

            VStack(spacing: AppTheme.Spacing.sm) {
                Text("無法取得位置")
                    .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                    .foregroundColor(.white)

                Text("請確認已開啟定位權限")
                    .font(.system(size: AppTheme.FontSize.callout))
                    .foregroundColor(.white.opacity(0.7))
            }

            Button(action: {
                locationManager.requestLocationPermission()
            }) {
                Text("重新授權")
                    .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                    .foregroundColor(AppTheme.dark)
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .padding(.vertical, AppTheme.Spacing.md)
                    .background(AppTheme.goldGradient)
                    .cornerRadius(AppTheme.CornerRadius.md)
            }
        }
        .padding(AppTheme.Spacing.xl)
    }

    // MARK: - Content View

    private func contentView(userLocation: CLLocation) -> some View {
        let nearbyTemples = templeViewModel.getNearbyTemples(
            from: userLocation,
            radius: 5000 // 5公里內
        )

        return ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                // 頂部提示
                VStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 50))
                        .foregroundColor(AppTheme.gold)

                    Text("附近廟宇")
                        .font(.system(size: AppTheme.FontSize.title2, weight: .bold))
                        .foregroundColor(.white)

                    if nearbyTemples.isEmpty {
                        Text("5 公里內沒有廟宇")
                            .font(.system(size: AppTheme.FontSize.callout))
                            .foregroundColor(.white.opacity(0.7))
                    } else {
                        Text("找到 \(nearbyTemples.count) 間廟宇在 5 公里內")
                            .font(.system(size: AppTheme.FontSize.callout))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.top, AppTheme.Spacing.xl)

                // 廟宇列表
                if nearbyTemples.isEmpty {
                    emptyStateView
                } else {
                    VStack(spacing: AppTheme.Spacing.md) {
                        ForEach(nearbyTemples) { temple in
                            templeCard(temple: temple, userLocation: userLocation)
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                }

                Spacer(minLength: AppTheme.Spacing.xxxl)
            }
        }
    }

    // MARK: - Empty State View

    private var emptyStateView: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "map")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.3))

            VStack(spacing: AppTheme.Spacing.sm) {
                Text("附近沒有廟宇")
                    .font(.system(size: AppTheme.FontSize.headline, weight: .semibold))
                    .foregroundColor(.white)

                Text("請前往廟宇或使用 QR Code 掃描打卡")
                    .font(.system(size: AppTheme.FontSize.callout))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(AppTheme.Spacing.xxl)
    }

    // MARK: - Temple Card

    private func templeCard(temple: Temple, userLocation: CLLocation) -> some View {
        let distance = temple.distance(from: userLocation)
        let isInRange = distance <= temple.checkInRadius // 使用廟宇設定的打卡範圍

        return Button(action: {
            if isInRange {
                selectedTemple = temple
            } else {
                alertMessage = "您距離廟宇太遠了\n\n請靠近至 \(Int(temple.checkInRadius)) 公尺內才能打卡"
                showAlert = true
            }
        }) {
            VStack(spacing: 0) {
                // 廟宇資訊
                HStack(spacing: AppTheme.Spacing.md) {
                    // 神明圖標
                    ZStack {
                        Circle()
                            .fill(Color(hex: temple.deity.color).opacity(0.2))
                            .frame(width: 60, height: 60)

                        Image(systemName: temple.deity.iconName)
                            .font(.system(size: 28))
                            .foregroundColor(Color(hex: temple.deity.color))
                    }

                    // 廟宇名稱和距離
                    VStack(alignment: .leading, spacing: 6) {
                        Text(temple.name)
                            .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                            .foregroundColor(.white)

                        HStack(spacing: AppTheme.Spacing.sm) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 12))
                            Text("\(Int(distance)) 公尺")
                                .font(.system(size: AppTheme.FontSize.caption))
                        }
                        .foregroundColor(.white.opacity(0.7))

                        Text("主祀：\(temple.deity.displayName)")
                            .font(.system(size: AppTheme.FontSize.caption))
                            .foregroundColor(AppTheme.gold.opacity(0.8))
                    }

                    Spacer()

                    // 狀態圖標
                    VStack(spacing: 4) {
                        if isInRange {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.green)

                            Text("可打卡")
                                .font(.system(size: AppTheme.FontSize.caption2, weight: .semibold))
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "location.circle")
                                .font(.system(size: 28))
                                .foregroundColor(.white.opacity(0.5))

                            Text("太遠")
                                .font(.system(size: AppTheme.FontSize.caption2))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }
                .padding(AppTheme.Spacing.lg)

                // 福報值提示
                if isInRange {
                    HStack {
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.yellow)

                        Text("打卡可獲得 +\(temple.blessPoints) 福報值")
                            .font(.system(size: AppTheme.FontSize.caption))
                            .foregroundColor(.white.opacity(0.8))

                        Spacer()
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.bottom, AppTheme.Spacing.md)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                            .stroke(
                                isInRange ? Color.green.opacity(0.5) : Color.white.opacity(0.2),
                                lineWidth: isInRange ? 2 : 1
                            )
                    )
            )
            .shadow(
                color: isInRange ? Color.green.opacity(0.2) : Color.clear,
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .disabled(!isInRange)
    }
}

// MARK: - Preview

#Preview {
    LocationCheckInView()
}
