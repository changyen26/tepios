/**
 * 地圖搜尋頁面
 * 參考：平安符打卡系統 PDF 第8頁第3張
 * 整合 GPS 定位功能
 */

import SwiftUI
import MapKit

struct MapView: View {
    // MARK: - State

    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 25.0330, longitude: 121.5654),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    @StateObject private var templeViewModel = TempleViewModel()

    @State private var selectedTemple: Temple?
    @State private var searchText = ""
    @State private var showLocationAlert = false
    @State private var showTempleDetail = false
    @State private var trackingMode: MapUserTrackingMode = .follow
    @FocusState private var isSearchFocused: Bool

    // MARK: - Mock Data

    private let temples = Temple.mockTemples

    // MARK: - Computed Properties

    /// 過濾和排序廟宇列表
    private var filteredTemples: [Temple] {
        let filtered: [Temple]

        // 如果有搜尋文字，先過濾
        if !searchText.isEmpty {
            filtered = temples.filter { temple in
                temple.name.localizedCaseInsensitiveContains(searchText) ||
                temple.address.localizedCaseInsensitiveContains(searchText) ||
                temple.deity.name.localizedCaseInsensitiveContains(searchText)
            }
        } else {
            filtered = temples
        }

        // 如果有用戶位置，按距離排序
        guard let userLocation = locationManager.location else {
            return filtered
        }

        return filtered.sorted {
            $0.distance(from: userLocation) < $1.distance(from: userLocation)
        }
    }

    private var templesWithDistance: [Temple] {
        return filteredTemples
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // 地圖
                Map(
                    coordinateRegion: $region,
                    showsUserLocation: true,
                    userTrackingMode: $trackingMode,
                    annotationItems: templesWithDistance
                ) { temple in
                    MapAnnotation(coordinate: temple.coordinate) {
                        TempleMapMarker(
                            isSelected: selectedTemple?.id == temple.id
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                selectedTemple = temple
                            }
                        }
                    }
                }
                .ignoresSafeArea()

                // 搜尋欄和控制按鈕
                VStack {
                    HStack(spacing: AppTheme.Spacing.md) {
                        searchBar
                            .frame(maxWidth: .infinity)

                        // 定位按鈕
                        locationButton
                    }
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .padding(.top, AppTheme.Spacing.md)

                    // 搜尋結果提示
                    if !searchText.isEmpty {
                        searchResultBanner
                            .padding(.horizontal, AppTheme.Spacing.xl)
                            .padding(.top, AppTheme.Spacing.sm)
                    }

                    Spacer()

                    // 廟宇資訊卡片
                    if let temple = selectedTemple {
                        templeCard(temple: temple)
                            .padding(.horizontal, AppTheme.Spacing.xl)
                            .padding(.bottom, 40)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .onAppear {
                locationManager.checkLocationServices()
                locationManager.requestLocationPermission()
            }
            .onChange(of: locationManager.location) { newLocation in
                if let location = newLocation {
                    // 更新地圖中心到用戶位置
                    withAnimation(.easeInOut(duration: 0.5)) {
                        region.center = location.coordinate
                    }
                }
            }
            .alert("定位提示", isPresented: $showLocationAlert) {
                Button("前往設定", role: .none) {
                    openAppSettings()
                }
                Button("取消", role: .cancel) { }
            } message: {
                Text(locationManager.errorMessage ?? "無法獲取定位")
            }
            .onChange(of: locationManager.errorMessage) { error in
                if error != nil {
                    showLocationAlert = true
                }
            }
            .navigationDestination(isPresented: $showTempleDetail) {
                if let temple = selectedTemple {
                    TempleDetailView(
                        temple: temple,
                        templeViewModel: templeViewModel,
                        locationManager: locationManager
                    )
                }
            }
        }
    }

    // MARK: - Components

    private var searchBar: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18))
                .foregroundColor(AppTheme.gold)

            TextField("", text: $searchText, prompt: Text("搜尋廟宇...").foregroundColor(.gray.opacity(0.6)))
                .font(.system(size: AppTheme.FontSize.callout))
                .foregroundColor(.black)
                .focused($isSearchFocused)
                .submitLabel(.search)
                .onSubmit {
                    isSearchFocused = false
                }

            // 清除按鈕
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    isSearchFocused = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                .fill(Color.white)
                .shadow(
                    color: Color.black.opacity(0.15),
                    radius: 8,
                    x: 0,
                    y: 2
                )
        )
    }

    private var locationButton: some View {
        Button(action: {
            centerOnUserLocation()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                    .fill(locationManager.isLocationEnabled ? AppTheme.goldGradient : LinearGradient(colors: [Color.gray], startPoint: .top, endPoint: .bottom))
                    .frame(width: 44, height: 44)
                    .shadow(
                        color: Color.black.opacity(0.15),
                        radius: 8,
                        x: 0,
                        y: 2
                    )

                Image(systemName: locationManager.isLocationEnabled ? "location.fill" : "location.slash.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
        }
    }

    /// 搜尋結果橫幅
    private var searchResultBanner: some View {
        HStack {
            Image(systemName: filteredTemples.isEmpty ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                .foregroundColor(filteredTemples.isEmpty ? .orange : .green)

            Text(filteredTemples.isEmpty ? "找不到符合的廟宇" : "找到 \(filteredTemples.count) 間廟宇")
                .font(.system(size: AppTheme.FontSize.callout, weight: .medium))
                .foregroundColor(.white)

            Spacer()

            if !filteredTemples.isEmpty {
                Button(action: {
                    // 聚焦到第一個搜尋結果
                    if let firstTemple = filteredTemples.first {
                        withAnimation(.spring(response: 0.3)) {
                            selectedTemple = firstTemple
                            region.center = firstTemple.coordinate
                        }
                    }
                }) {
                    Text("查看第一個")
                        .font(.system(size: AppTheme.FontSize.caption, weight: .semibold))
                        .foregroundColor(AppTheme.gold)
                }
            }
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                .fill(Color.black.opacity(0.7))
        )
    }

    private func templeCard(temple: Temple) -> some View {
        VStack(spacing: 0) {
            // 廟宇圖片
            ZStack(alignment: .topTrailing) {
                ZStack(alignment: .bottomLeading) {
                    // 背景圖片
                    if let firstImageName = temple.images.first, !firstImageName.isEmpty {
                        // 顯示真實圖片
                        Image(firstImageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 180)
                            .clipped()
                    } else {
                        // 沒有圖片時使用漸層
                        LinearGradient(
                            colors: [AppTheme.gold, Color(hex: "D4B756")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 180)
                        .overlay(
                            Image(systemName: "building.columns.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.3))
                        )
                    }

                    // 覆蓋層
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 180)

                    // 廟宇名稱和距離
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        Text(temple.name)
                            .font(.system(size: AppTheme.FontSize.title3, weight: .bold))
                            .foregroundColor(.white)

                        if let userLocation = locationManager.location {
                            HStack(spacing: 4) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 14))
                                Text(String(format: "%.1f km", temple.distance(from: userLocation) / 1000.0))
                                    .font(.system(size: AppTheme.FontSize.callout, weight: .medium))
                            }
                            .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .padding(AppTheme.Spacing.lg)
                }

                // 關閉按鈕
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        selectedTemple = nil
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.6))
                            .frame(width: 32, height: 32)

                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(AppTheme.Spacing.md)
            }

            // 廟宇資訊
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                Text(temple.description)
                    .font(.system(size: AppTheme.FontSize.callout))
                    .foregroundColor(AppTheme.dark.opacity(0.7))
                    .lineLimit(2)

                // 按鈕組
                HStack(spacing: AppTheme.Spacing.md) {
                    // 查看詳情按鈕
                    Button(action: {
                        showTempleDetail = true
                    }) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 18))
                            Text("查看詳情")
                                .font(.system(size: AppTheme.FontSize.body, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                .fill(
                                    LinearGradient(
                                        colors: [AppTheme.dark, AppTheme.dark.opacity(0.8)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        )
                    }

                    // 導航按鈕
                    Button(action: {
                        openInMaps(temple: temple)
                    }) {
                        HStack {
                            Image(systemName: "location.fill")
                                .font(.system(size: 18))
                            Text("前往")
                                .font(.system(size: AppTheme.FontSize.body, weight: .semibold))
                        }
                        .foregroundColor(AppTheme.dark)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                .fill(AppTheme.goldGradient)
                                .shadow(
                                    color: AppTheme.gold.opacity(0.3),
                                    radius: 8,
                                    x: 0,
                                    y: 2
                                )
                        )
                    }
                }
            }
            .padding(AppTheme.Spacing.lg)
        }
        .background(Color.white)
        .cornerRadius(AppTheme.CornerRadius.xl)
        .shadow(
            color: Color.black.opacity(0.2),
            radius: 12,
            x: 0,
            y: 4
        )
    }

    // MARK: - Methods

    private func centerOnUserLocation() {
        if let location = locationManager.location {
            withAnimation(.easeInOut(duration: 0.5)) {
                region.center = location.coordinate
                trackingMode = .follow
            }
        } else {
            locationManager.requestLocationPermission()
        }
    }

    private func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        let distance = fromLocation.distance(from: toLocation) / 1000.0 // 轉換為公里
        return distance
    }

    private func openInMaps(temple: Temple) {
        let coordinate = temple.coordinate
        let mapItem = MKMapItem(
            placemark: MKPlacemark(
                coordinate: coordinate
            )
        )
        mapItem.name = temple.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }

    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Temple Map Marker

struct TempleMapMarker: View {
    let isSelected: Bool

    var body: some View {
        ZStack {
            // 標記底座
            Circle()
                .fill(
                    isSelected ?
                        AppTheme.goldGradient :
                        LinearGradient(
                            colors: [Color.red, Color.red.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                )
                .frame(width: isSelected ? 48 : 40, height: isSelected ? 48 : 40)
                .shadow(
                    color: (isSelected ? AppTheme.gold : Color.red).opacity(0.5),
                    radius: isSelected ? 12 : 8,
                    x: 0,
                    y: 4
                )

            // 圖標
            Image(systemName: "building.columns.fill")
                .font(.system(size: isSelected ? 24 : 20))
                .foregroundColor(.white)
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Preview

#Preview {
    MapView()
}
