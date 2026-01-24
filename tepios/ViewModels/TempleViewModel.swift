/**
 * 廟宇管理 ViewModel
 */

import Foundation
import SwiftUI
import CoreLocation
import Combine

class TempleViewModel: ObservableObject {
    // MARK: - Singleton

    static let shared = TempleViewModel()

    // MARK: - Published Properties

    @Published var temples: [Temple] = []
    @Published var checkInRecords: [CheckInRecord] = []
    @Published var statistics: CheckInStatistics = CheckInStatistics()
    @Published var achievementManager = AchievementManager()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    // MARK: - Private Properties

    private let templesKey = "savedTemples"
    private let checkInsKey = "savedCheckIns"
    private let statisticsKey = "savedStatistics"
    private let currentUserId = "currentUser" // 實際應從 Auth 系統取得

    // MARK: - Initialization

    init() {
        loadTemples()
        loadCheckInRecords()
        loadStatistics()
        // 初始檢查成就
        checkAchievements()
    }

    // MARK: - Temple Management

    /// 載入廟宇資料
    func loadTemples() {
        if let savedData = UserDefaults.standard.data(forKey: templesKey),
           let decoded = try? JSONDecoder().decode([Temple].self, from: savedData) {
            self.temples = decoded
        } else {
            // 使用 mock 資料
            self.temples = Temple.mockTemples
            saveTemples()
        }
    }

    /// 強制重新載入 mock 廟宇資料（開發用）
    func resetToMockTemples() {
        print("🔄 重置廟宇資料到最新 mockTemples")
        self.temples = Temple.mockTemples
        saveTemples()
        print("✅ 廟宇資料已重置，共 \(temples.count) 間廟宇")
    }

    /// 儲存廟宇資料
    private func saveTemples() {
        if let encoded = try? JSONEncoder().encode(temples) {
            UserDefaults.standard.set(encoded, forKey: templesKey)
        }
    }

    /// 根據 ID 取得廟宇
    func getTemple(by id: String) -> Temple? {
        temples.first { $0.id == id }
    }

    /// 取得附近的廟宇
    func getNearbyTemples(from location: CLLocation, radius: Double = 5000) -> [Temple] {
        temples
            .filter { $0.distance(from: location) <= radius }
            .sorted { $0.distance(from: location) < $1.distance(from: location) }
    }

    /// 搜尋廟宇
    func searchTemples(query: String) -> [Temple] {
        if query.isEmpty {
            return temples
        }
        return temples.filter {
            $0.name.contains(query) ||
            $0.address.contains(query) ||
            $0.deity.name.contains(query) ||
            $0.description.contains(query)
        }
    }

    // MARK: - CheckIn Management

    /// 載入打卡紀錄
    private func loadCheckInRecords() {
        if let savedData = UserDefaults.standard.data(forKey: checkInsKey),
           let decoded = try? JSONDecoder().decode([CheckInRecord].self, from: savedData) {
            self.checkInRecords = decoded
        }
    }

    /// 儲存打卡紀錄
    private func saveCheckInRecords() {
        if let encoded = try? JSONEncoder().encode(checkInRecords) {
            UserDefaults.standard.set(encoded, forKey: checkInsKey)
        }
    }

    /// 載入統計資料
    private func loadStatistics() {
        if let savedData = UserDefaults.standard.data(forKey: statisticsKey),
           let decoded = try? JSONDecoder().decode(CheckInStatistics.self, from: savedData) {
            self.statistics = decoded
        }
    }

    /// 儲存統計資料
    private func saveStatistics() {
        if let encoded = try? JSONEncoder().encode(statistics) {
            UserDefaults.standard.set(encoded, forKey: statisticsKey)
        }
    }

    /// 執行打卡
    func performCheckIn(
        at temple: Temple,
        from location: CLLocation,
        photos: [String] = [],
        notes: String = ""
    ) -> CheckInValidationResult {
        isLoading = true
        errorMessage = nil

        // 取得最後一筆打卡紀錄
        let lastCheckIn = checkInRecords.last

        // 驗證是否可以打卡
        let validation = CheckInValidator.canCheckIn(
            at: temple,
            from: location,
            lastCheckIn: lastCheckIn
        )

        guard validation.isValid else {
            isLoading = false
            errorMessage = validation.errorMessage
            return validation
        }

        // 判斷是否為連續打卡
        let isConsecutive = isConsecutiveCheckIn(lastCheckIn: lastCheckIn)
        let consecutiveDays = isConsecutive ? statistics.currentStreak + 1 : 1

        // 判斷打卡類型
        let checkInType = CheckInValidator.determineCheckInType(
            temple: temple,
            previousCheckIns: checkInRecords,
            isConsecutive: isConsecutive
        )

        // 計算福報值
        let earnedPoints = CheckInValidator.calculatePoints(
            temple: temple,
            checkInType: checkInType,
            isConsecutive: isConsecutive,
            consecutiveDays: consecutiveDays
        )

        // 建立打卡紀錄
        let checkIn = CheckInRecord(
            templeId: temple.id,
            templeName: temple.name,
            templeDeity: temple.deity.name,
            userId: currentUserId,
            checkInDate: Date(),
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            earnedPoints: earnedPoints,
            checkInType: checkInType,
            photos: photos,
            notes: notes,
            isConsecutive: isConsecutive,
            consecutiveDays: consecutiveDays
        )

        // 儲存打卡紀錄
        checkInRecords.append(checkIn)
        saveCheckInRecords()

        // 更新統計資料
        statistics.updateWithCheckIn(checkIn)
        saveStatistics()

        // 檢查成就進度
        checkAchievements()

        isLoading = false
        successMessage = "打卡成功！獲得 \(earnedPoints) 福報值"

        return .success
    }

    /// 判斷是否為連續打卡
    private func isConsecutiveCheckIn(lastCheckIn: CheckInRecord?) -> Bool {
        guard let lastCheckIn = lastCheckIn else { return false }

        let calendar = Calendar.current
        let now = Date()

        // 檢查是否為昨天打卡
        if let daysDiff = calendar.dateComponents([.day], from: lastCheckIn.checkInDate, to: now).day {
            return daysDiff == 1
        }

        return false
    }

    /// 取得指定廟宇的打卡紀錄
    func getCheckInRecords(for templeId: String) -> [CheckInRecord] {
        checkInRecords
            .filter { $0.templeId == templeId }
            .sorted { $0.checkInDate > $1.checkInDate }
    }

    /// 取得最近的打卡紀錄
    func getRecentCheckIns(limit: Int = 10) -> [CheckInRecord] {
        Array(checkInRecords
            .sorted { $0.checkInDate > $1.checkInDate }
            .prefix(limit))
    }

    /// 取得今日打卡紀錄
    func getTodayCheckIns() -> [CheckInRecord] {
        let calendar = Calendar.current
        let today = Date()

        return checkInRecords.filter {
            calendar.isDate($0.checkInDate, inSameDayAs: today)
        }
    }

    /// 取得本週打卡紀錄
    func getWeekCheckIns() -> [CheckInRecord] {
        let calendar = Calendar.current
        let now = Date()
        guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) else {
            return []
        }

        return checkInRecords.filter {
            $0.checkInDate >= weekAgo && $0.checkInDate <= now
        }
    }

    /// 取得本月打卡紀錄
    func getMonthCheckIns() -> [CheckInRecord] {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month], from: now)

        return checkInRecords.filter {
            let checkInComponents = calendar.dateComponents([.year, .month], from: $0.checkInDate)
            return checkInComponents.year == components.year &&
                   checkInComponents.month == components.month
        }
    }

    /// 檢查今天是否已在指定廟宇打卡
    func hasCheckedInToday(at temple: Temple) -> Bool {
        let calendar = Calendar.current
        let today = Date()

        return checkInRecords.contains { checkIn in
            checkIn.templeId == temple.id &&
            calendar.isDate(checkIn.checkInDate, inSameDayAs: today)
        }
    }

    /// 取得指定廟宇的拜訪次數
    func getVisitCount(for temple: Temple) -> Int {
        checkInRecords.filter { $0.templeId == temple.id }.count
    }

    /// 判斷是否為最愛廟宇
    func isFavoriteTemple(_ temple: Temple) -> Bool {
        guard let maxCount = statistics.favoriteTemples.values.max() else {
            return false
        }
        return statistics.favoriteTemples[temple.id] == maxCount
    }

    // MARK: - Statistics

    /// 取得福報值歷史資料（用於圖表）
    func getPointsHistory(days: Int = 7) -> [(date: String, points: Int)] {
        let calendar = Calendar.current
        let now = Date()
        var history: [(date: String, points: Int)] = []

        for i in (0..<days).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -i, to: now) else {
                continue
            }

            let dayCheckIns = checkInRecords.filter {
                calendar.isDate($0.checkInDate, inSameDayAs: date)
            }

            let totalPoints = dayCheckIns.reduce(0) { $0 + $1.earnedPoints }

            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd"
            let dateString = formatter.string(from: date)

            history.append((date: dateString, points: totalPoints))
        }

        return history
    }

    /// 清空提示訊息
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }

    /// 重置所有資料（測試用）
    func resetAllData() {
        checkInRecords = []
        statistics = CheckInStatistics()
        saveCheckInRecords()
        saveStatistics()
        achievementManager.resetAllAchievements()
        successMessage = "已重置所有打卡資料"
    }

    // MARK: - Achievement Management

    /// 檢查並更新成就進度
    func checkAchievements() {
        achievementManager.checkAchievements(
            with: statistics,
            checkInRecords: checkInRecords
        )
    }

    /// 取得新解鎖的成就（用於顯示通知）
    func getNewlyUnlockedAchievements() -> [Achievement] {
        achievementManager.newlyUnlockedAchievements
    }

    /// 清除新解鎖成就通知
    func clearNewlyUnlockedAchievements() {
        achievementManager.clearNewlyUnlocked()
    }
}
