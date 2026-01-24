/**
 * 打卡紀錄模型
 */

import Foundation
import CoreLocation

// MARK: - CheckIn Record

struct CheckInRecord: Identifiable, Codable {
    let id: String
    let templeId: String
    let templeName: String
    let templeDeity: String // 神明類型（用於成就系統）
    let userId: String
    let checkInDate: Date
    let latitude: Double
    let longitude: Double
    let earnedPoints: Int // 獲得的福報值
    let checkInType: CheckInType
    let photos: [String] // 打卡照片
    let notes: String // 打卡心得
    var isConsecutive: Bool // 是否為連續打卡
    var consecutiveDays: Int // 連續天數

    init(
        id: String = UUID().uuidString,
        templeId: String,
        templeName: String,
        templeDeity: String,
        userId: String,
        checkInDate: Date = Date(),
        latitude: Double,
        longitude: Double,
        earnedPoints: Int,
        checkInType: CheckInType = .normal,
        photos: [String] = [],
        notes: String = "",
        isConsecutive: Bool = false,
        consecutiveDays: Int = 1
    ) {
        self.id = id
        self.templeId = templeId
        self.templeName = templeName
        self.templeDeity = templeDeity
        self.userId = userId
        self.checkInDate = checkInDate
        self.latitude = latitude
        self.longitude = longitude
        self.earnedPoints = earnedPoints
        self.checkInType = checkInType
        self.photos = photos
        self.notes = notes
        self.isConsecutive = isConsecutive
        self.consecutiveDays = consecutiveDays
    }

    // MARK: - Computed Properties

    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        formatter.locale = Locale(identifier: "zh_TW")
        return formatter.string(from: checkInDate)
    }

    var formattedShortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        formatter.locale = Locale(identifier: "zh_TW")
        return formatter.string(from: checkInDate)
    }

    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "zh_TW")
        return formatter.string(from: checkInDate)
    }
}

// MARK: - CheckIn Type

enum CheckInType: String, Codable {
    case normal = "一般打卡"
    case prayer = "祈福打卡"
    case festival = "節慶打卡"
    case firstVisit = "首次拜訪"
    case consecutive = "連續打卡"

    var pointsMultiplier: Double {
        switch self {
        case .normal:
            return 1.0
        case .prayer:
            return 1.5
        case .festival:
            return 2.0
        case .firstVisit:
            return 2.5
        case .consecutive:
            return 1.2
        }
    }

    var icon: String {
        switch self {
        case .normal:
            return "mappin.circle.fill"
        case .prayer:
            return "hands.sparkles"
        case .festival:
            return "party.popper.fill"
        case .firstVisit:
            return "star.circle.fill"
        case .consecutive:
            return "flame.fill"
        }
    }

    var color: String {
        switch self {
        case .normal:
            return "blue"
        case .prayer:
            return "purple"
        case .festival:
            return "red"
        case .firstVisit:
            return "gold"
        case .consecutive:
            return "orange"
        }
    }
}

// MARK: - CheckIn Statistics

struct CheckInStatistics: Codable {
    var totalCheckIns: Int
    var totalPoints: Int
    var visitedTemples: Set<String> // 拜訪過的廟宇 ID
    var currentStreak: Int // 當前連續天數
    var longestStreak: Int // 最長連續天數
    var lastCheckInDate: Date?
    var checkInsByMonth: [String: Int] // 每月打卡次數
    var favoriteTemples: [String: Int] // 最常拜訪的廟宇 (templeId: count)

    init(
        totalCheckIns: Int = 0,
        totalPoints: Int = 0,
        visitedTemples: Set<String> = [],
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastCheckInDate: Date? = nil,
        checkInsByMonth: [String: Int] = [:],
        favoriteTemples: [String: Int] = [:]
    ) {
        self.totalCheckIns = totalCheckIns
        self.totalPoints = totalPoints
        self.visitedTemples = visitedTemples
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastCheckInDate = lastCheckInDate
        self.checkInsByMonth = checkInsByMonth
        self.favoriteTemples = favoriteTemples
    }

    // 更新統計資料
    mutating func updateWithCheckIn(_ checkIn: CheckInRecord) {
        totalCheckIns += 1
        totalPoints += checkIn.earnedPoints
        visitedTemples.insert(checkIn.templeId)

        // 更新連續打卡天數
        if let lastDate = lastCheckInDate {
            let calendar = Calendar.current
            if calendar.isDate(checkIn.checkInDate, inSameDayAs: lastDate) {
                // 同一天打卡，不更新連續天數
            } else if let daysDiff = calendar.dateComponents([.day], from: lastDate, to: checkIn.checkInDate).day, daysDiff == 1 {
                // 連續打卡
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else {
                // 中斷連續
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }

        lastCheckInDate = checkIn.checkInDate

        // 更新月份統計
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        let monthKey = formatter.string(from: checkIn.checkInDate)
        checkInsByMonth[monthKey, default: 0] += 1

        // 更新最常拜訪的廟宇
        favoriteTemples[checkIn.templeId, default: 0] += 1
    }

    // 計算平均每日福報值
    var averagePointsPerDay: Double {
        guard totalCheckIns > 0 else { return 0 }
        return Double(totalPoints) / Double(totalCheckIns)
    }

    // 本月打卡次數
    var currentMonthCheckIns: Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        let currentMonth = formatter.string(from: Date())
        return checkInsByMonth[currentMonth] ?? 0
    }
}

// MARK: - CheckIn Validator

struct CheckInValidator {
    // 驗證是否可以打卡
    static func canCheckIn(
        at temple: Temple,
        from userLocation: CLLocation,
        lastCheckIn: CheckInRecord?,
        now: Date = Date()
    ) -> CheckInValidationResult {
        // 1. 檢查距離
        if !temple.isInCheckInRange(from: userLocation) {
            let distance = temple.distance(from: userLocation)
            return .failure(reason: "您距離廟宇 \(Int(distance)) 公尺，請靠近至 \(Int(temple.checkInRadius)) 公尺內才能打卡")
        }

        // 2. 檢查是否已在同一廟宇同一天打卡過
        if let lastCheckIn = lastCheckIn {
            let calendar = Calendar.current
            if lastCheckIn.templeId == temple.id &&
               calendar.isDate(lastCheckIn.checkInDate, inSameDayAs: now) {
                return .failure(reason: "您今天已在此廟宇打卡過了，明天再來吧！")
            }
        }

        // 3. 檢查廟宇是否開放（已開放全時段打卡）
        // if !temple.openingHours.isOpenNow() {
        //     return .failure(reason: "此廟宇目前未開放\n開放時間：\(temple.openingHours.displayText)")
        // }

        return .success
    }

    // 計算打卡獲得的福報值
    static func calculatePoints(
        temple: Temple,
        checkInType: CheckInType,
        isConsecutive: Bool,
        consecutiveDays: Int
    ) -> Int {
        var points = Double(temple.blessPoints)

        // 打卡類型加成
        points *= checkInType.pointsMultiplier

        // 連續打卡加成（每連續一天額外 +5%）
        if isConsecutive && consecutiveDays > 1 {
            let consecutiveBonus = 1.0 + (Double(consecutiveDays - 1) * 0.05)
            points *= min(consecutiveBonus, 2.0) // 最高 2 倍
        }

        return Int(points)
    }

    // 判斷打卡類型
    static func determineCheckInType(
        temple: Temple,
        previousCheckIns: [CheckInRecord],
        isConsecutive: Bool
    ) -> CheckInType {
        // 檢查是否為首次拜訪
        let hasVisitedBefore = previousCheckIns.contains { $0.templeId == temple.id }
        if !hasVisitedBefore {
            return .firstVisit
        }

        // 檢查是否為連續打卡
        if isConsecutive {
            return .consecutive
        }

        // 檢查是否為節慶（可以根據日期判斷）
        // TODO: 實作節慶判斷邏輯

        return .normal
    }
}

// MARK: - CheckIn Validation Result

enum CheckInValidationResult {
    case success
    case failure(reason: String)

    var isValid: Bool {
        if case .success = self {
            return true
        }
        return false
    }

    var errorMessage: String? {
        if case .failure(let reason) = self {
            return reason
        }
        return nil
    }
}
