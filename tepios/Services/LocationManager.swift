/**
 * 定位管理器
 * 管理 GPS 定位功能
 */

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    // MARK: - Singleton

    static let shared = LocationManager()

    // MARK: - Published Properties

    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLocationEnabled = false
    @Published var errorMessage: String?
    @Published var isSimulationMode = false

    // MARK: - Properties

    private let locationManager = CLLocationManager()

    // 模擬位置資料
    private var simulatedLocation: CLLocation?

    // MARK: - Initialization

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // 移動 10 公尺才更新
    }

    // MARK: - Public Methods

    /// 請求定位權限並開始定位
    func requestLocationPermission() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            errorMessage = "定位權限被拒絕，請到設定中開啟定位權限"
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
        @unknown default:
            break
        }
    }

    /// 開始更新位置
    func startUpdatingLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            errorMessage = "請在設定中開啟定位服務"
            isLocationEnabled = false
            return
        }

        isLocationEnabled = true
        locationManager.startUpdatingLocation()
    }

    /// 停止更新位置
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        isLocationEnabled = false
    }

    /// 檢查定位服務是否可用
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            checkLocationAuthorization()
        } else {
            errorMessage = "定位服務未開啟，請到設定中開啟"
            isLocationEnabled = false
        }
    }

    // MARK: - Simulation Methods (開發用)

    /// 啟用模擬模式並設定位置（開發測試用）
    func enableSimulationMode(latitude: Double, longitude: Double) {
        isSimulationMode = true
        simulatedLocation = CLLocation(latitude: latitude, longitude: longitude)
        location = simulatedLocation
        errorMessage = nil
        isLocationEnabled = true
    }

    /// 快速設定到特定廟宇附近（開發測試用）
    func simulateLocationNearTemple(_ templeName: String) {
        switch templeName {
        case "台北行天宮":
            enableSimulationMode(latitude: 25.0630, longitude: 121.5334)
        case "龍山寺":
            enableSimulationMode(latitude: 25.0370, longitude: 121.5000)
        case "關渡宮":
            enableSimulationMode(latitude: 25.1177, longitude: 121.4649)
        case "南投受天宮":
            enableSimulationMode(latitude: 23.8318, longitude: 120.6313)
        default:
            // 預設使用台北行天宮
            enableSimulationMode(latitude: 25.0630, longitude: 121.5334)
        }
    }

    /// 關閉模擬模式，恢復真實定位
    func disableSimulationMode() {
        isSimulationMode = false
        simulatedLocation = nil
        location = nil
        requestLocationPermission()
    }

    // MARK: - Private Methods

    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            errorMessage = "定位功能受到限制"
        case .denied:
            errorMessage = "定位權限被拒絕，請到設定中開啟"
        case .authorizedAlways, .authorizedWhenInUse:
            startUpdatingLocation()
        @unknown default:
            break
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 如果在模擬模式下，不更新真實位置
        guard !isSimulationMode else { return }
        guard let location = locations.last else { return }
        self.location = location
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "定位失敗: \(error.localizedDescription)"
        print("定位錯誤: \(error)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
        case .denied, .restricted:
            stopUpdatingLocation()
            errorMessage = "定位權限被拒絕，請到設定中開啟定位權限"
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
}
