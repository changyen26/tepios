/**
 * 附近廟宇列表頁面
 * 自動定位顯示附近的廟宇
 */

import SwiftUI
import CoreLocation

struct NearbyTemplesView: View {
    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - ViewModels

    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var templeViewModel = TempleViewModel.shared

    // MARK: - State

    @State private var selectedTemple: Temple?
    @State private var searchRadius: Double = 5000 // 預設 5 公里

    // 搜尋範圍選項
    private let radiusOptions: [(String, Double)] = [
        ("1 公里", 1000),
        ("3 公里", 3000),
        ("5 公里", 5000),
        ("10 公里", 10000),
        ("20 公里", 20000)
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
                        // 頂部說明
                        headerSection

                        // 搜尋範圍選擇
                        radiusSelectionSection
                            .padding(.horizontal, AppTheme.Spacing.xl)

                        // 廟宇列表
                        templesListSection
                            .padding(.horizontal, AppTheme.Spacing.xl)

                        Spacer(minLength: AppTheme.Spacing.xxxl)
                    }
                }
            }
            .navigationTitle("附近廟宇")
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
            }
            .sheet(item: $selectedTemple) { temple in
                TempleDetailView(
                    temple: temple,
                    templeViewModel: templeViewModel,
                    locationManager: locationManager
                )
            }
            .onAppear {
                locationManager.requestLocationPermission()
            }
        }
    }

    // MARK: - Components

    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "map.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .shadow(color: Color.blue.opacity(0.5), radius: 20, x: 0, y: 10)

            Text("探索附近廟宇")
                .font(.system(size: AppTheme.FontSize.title2, weight: .bold))
                .foregroundColor(.white)

            if let location = locationManager.location {
                Text("當前位置：\(String(format: "%.4f, %.4f", location.coordinate.latitude, location.coordinate.longitude))")
                    .font(.system(size: AppTheme.FontSize.caption, design: .monospaced))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(.top, AppTheme.Spacing.xl)
    }

    private var radiusSelectionSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            HStack {
                Text("搜尋範圍")
                    .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(radiusOptions, id: \.1) { option in
                        radiusButton(title: option.0, radius: option.1)
                    }
                }
            }
        }
    }

    private func radiusButton(title: String, radius: Double) -> some View {
        Button(action: {
            searchRadius = radius
        }) {
            Text(title)
                .font(.system(size: AppTheme.FontSize.caption, weight: .semibold))
                .foregroundColor(searchRadius == radius ? .white : .white.opacity(0.7))
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm)
                        .fill(searchRadius == radius ? Color.blue : Color.white.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm)
                        .stroke(searchRadius == radius ? Color.blue : Color.white.opacity(0.3), lineWidth: 1)
                )
        }
    }

    private var templesListSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            if let location = locationManager.location {
                let nearbyTemples = templeViewModel.getNearbyTemples(from: location, radius: searchRadius)

                if nearbyTemples.isEmpty {
                    emptyStateView
                } else {
                    // 標題列
                    HStack {
                        Text("找到 \(nearbyTemples.count) 間廟宇")
                            .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }

                    // 廟宇列表
                    VStack(spacing: AppTheme.Spacing.md) {
                        ForEach(nearbyTemples) { temple in
                            templeCard(temple: temple, userLocation: location)
                        }
                    }
                }
            } else if locationManager.errorMessage != nil {
                locationErrorView
            } else {
                loadingLocationView
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "map")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.3))

            VStack(spacing: AppTheme.Spacing.sm) {
                Text("附近沒有廟宇")
                    .font(.system(size: AppTheme.FontSize.headline, weight: .semibold))
                    .foregroundColor(.white)

                Text("試試擴大搜尋範圍")
                    .font(.system(size: AppTheme.FontSize.callout))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.xxl)
    }

    private var locationErrorView: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "location.slash.fill")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.5))

            VStack(spacing: AppTheme.Spacing.sm) {
                Text("無法取得位置")
                    .font(.system(size: AppTheme.FontSize.headline, weight: .semibold))
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
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.xxl)
    }

    private var loadingLocationView: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(1.5)

            Text("正在定位中...")
                .font(.system(size: AppTheme.FontSize.callout))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.xxl)
    }

    private func templeCard(temple: Temple, userLocation: CLLocation) -> some View {
        let distance = temple.distance(from: userLocation)

        return Button(action: {
            selectedTemple = temple
        }) {
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

                // 廟宇資訊
                VStack(alignment: .leading, spacing: 6) {
                    Text(temple.name)
                        .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                        .foregroundColor(.white)

                    HStack(spacing: AppTheme.Spacing.sm) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 12))

                        Text(formatDistance(distance))
                            .font(.system(size: AppTheme.FontSize.caption))
                    }
                    .foregroundColor(.white.opacity(0.7))

                    Text("主祀：\(temple.deity.displayName)")
                        .font(.system(size: AppTheme.FontSize.caption))
                        .foregroundColor(Color(hex: temple.deity.color).opacity(0.8))
                }

                Spacer()

                // 箭頭圖標
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(AppTheme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                            .stroke(Color(hex: temple.deity.color).opacity(0.3), lineWidth: 1)
                    )
            )
            .shadow(
                color: Color(hex: temple.deity.color).opacity(0.1),
                radius: 8,
                x: 0,
                y: 4
            )
        }
    }

    // MARK: - Helper Methods

    private func formatDistance(_ distance: Double) -> String {
        if distance < 1000 {
            return "\(Int(distance)) 公尺"
        } else {
            return String(format: "%.1f 公里", distance / 1000)
        }
    }
}

// MARK: - Preview

#Preview {
    NearbyTemplesView()
}
