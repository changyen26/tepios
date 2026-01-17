/**
 * 定位管理器
 * 管理 GPS 定位功能
 */

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    // MARK: - Published Properties

    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLocationEnabled = false
    @Published var errorMessage: String?

    // MARK: - Properties

    private let locationManager = CLLocationManager()

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
