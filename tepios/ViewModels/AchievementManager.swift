/**
 * 成就系統管理器
 * 負責追蹤、解鎖和獎勵成就
 */

import Foundation
import SwiftUI
import Combine

class AchievementManager: ObservableObject {
    // MARK: - Published Properties

    @Published var achievements: [Achievement] = []
    @Published var newlyUnlockedAchievements: [Achievement] = []

    // MARK: - Properties

    private let userDefaultsKey = "savedAchievements"

    // MARK: - Computed Properties

    var unlockedAchievements: [Achievement] {
        achievements.filter { $0.unlocked }
    }

    var lockedAchievements: [Achievement] {
        achievements.filter { !$0.unlocked }
    }

    var totalRewardsEarned: Int {
        unlockedAchievements.reduce(0) { $0 + $1.rewardPoints }
    }

    var achievementsByType: [AchievementType: [Achievement]] {
        Dictionary(grouping: achievements) { $0.type }
    }

    var achievementsByRarity: [AchievementRarity: [Achievement]] {
        Dictionary(grouping: achievements) { $0.rarity }
    }

    // MARK: - Initialization

    init() {
        loadAchievements()
    }

    // MARK: - Public Methods

    /// 檢查並更新所有成就進度
    func checkAchievements(with statistics: CheckInStatistics, checkInRecords: [CheckInRecord]) {
        var unlockedThisTime: [Achievement] = []

        for index in achievements.indices {
            let achievement = achievements[index]
            guard !achievement.unlocked else { continue }

            let newProgress = calculateProgress(
                for: achievement.requirement,
                statistics: statistics,
                checkInRecords: checkInRecords
            )

            if newProgress != achievement.progress {
                achievements[index].updateProgress(newProgress)

                // 如果剛解鎖，添加到新解鎖列表
                if achievements[index].unlocked {
                    unlockedThisTime.append(achievements[index])
                }
            }
        }

        // 更新新解鎖成就
        if !unlockedThisTime.isEmpty {
            newlyUnlockedAchievements = unlockedThisTime
            saveAchievements()
        }
    }

    /// 計算特定成就的進度
    func calculateProgress(
        for requirement: AchievementRequirement,
        statistics: CheckInStatistics,
        checkInRecords: [CheckInRecord]
    ) -> Int {
        switch requirement {
        case .firstCheckIn:
            return statistics.totalCheckIns > 0 ? 1 : 0

        case .consecutiveDays:
            return statistics.currentStreak

        case .totalCheckIns:
            return statistics.totalCheckIns

        case .visitTemples:
            return statistics.visitedTemples.count

        case .earnPoints(let targetPoints):
            // 檢查是否有任何一次打卡獲得該點數
            let maxEarned = checkInRecords.map { $0.earnedPoints }.max() ?? 0
            return maxEarned >= targetPoints ? targetPoints : maxEarned

        case .totalPoints:
            return statistics.totalPoints

        case .prayerCount:
            // 計算祈福類型的打卡次數
            return checkInRecords.filter { $0.checkInType == .prayer }.count

        case .visitAllDeityTypes:
            // 計算拜訪過的不同神明類型數量
            let visitedDeities = Set(checkInRecords.map { $0.templeDeity })
            return visitedDeities.count

        case .checkInAllTemples:
            return statistics.visitedTemples.count

        case .perfectWeek:
            // 檢查最近7天是否每天都有打卡
            return checkPerfectWeek(checkInRecords: checkInRecords) ? 7 : 0

        case .earlyBird:
            // 統計早上6-9點的打卡次數
            return countCheckInsByTimeRange(checkInRecords: checkInRecords, startHour: 6, endHour: 9)

        case .nightOwl:
            // 統計晚上9-12點的打卡次數
            return countCheckInsByTimeRange(checkInRecords: checkInRecords, startHour: 21, endHour: 24)

        case .inviteFriends:
            // 暫時返回0，待社交功能開發
            return 0

        case .shareCheckIns:
            // 暫時返回0，待分享功能開發
            return 0
        }
    }

    /// 手動解鎖成就（用於測試或特殊事件）
    func unlockAchievement(id: String) {
        if let index = achievements.firstIndex(where: { $0.id == id }) {
            achievements[index].unlocked = true
            achievements[index].unlockedDate = Date()
            achievements[index].progress = achievements[index].maxProgress
            newlyUnlockedAchievements.append(achievements[index])
            saveAchievements()
        }
    }

    /// 重置所有成就（用於測試）
    func resetAllAchievements() {
        achievements = Achievement.allAchievements
        newlyUnlockedAchievements = []
        saveAchievements()
    }

    /// 清除新解鎖成就通知
    func clearNewlyUnlocked() {
        newlyUnlockedAchievements = []
    }

    // MARK: - Private Methods

    /// 檢查是否有完美一週
    private func checkPerfectWeek(checkInRecords: [CheckInRecord]) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now

        let recentRecords = checkInRecords.filter { $0.checkInDate >= sevenDaysAgo }

        var daysWithCheckIns = Set<Int>()
        for record in recentRecords {
            let day = calendar.component(.day, from: record.checkInDate)
            daysWithCheckIns.insert(day)
        }

        return daysWithCheckIns.count >= 7
    }

    /// 統計特定時間範圍的打卡次數
    private func countCheckInsByTimeRange(
        checkInRecords: [CheckInRecord],
        startHour: Int,
        endHour: Int
    ) -> Int {
        let calendar = Calendar.current
        return checkInRecords.filter { record in
            let hour = calendar.component(.hour, from: record.checkInDate)
            return hour >= startHour && hour < endHour
        }.count
    }

    // MARK: - Persistence

    private func loadAchievements() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = decoded
        } else {
            // 首次啟動，載入預設成就
            achievements = Achievement.allAchievements
            saveAchievements()
        }
    }

    private func saveAchievements() {
        if let encoded = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
}

// MARK: - Achievement Statistics

extension AchievementManager {
    /// 獲取成就統計資訊
    func getAchievementStats() -> AchievementStats {
        let byRarity = achievementsByRarity.mapValues { achievements in
            (
                total: achievements.count,
                unlocked: achievements.filter { $0.unlocked }.count
            )
        }

        return AchievementStats(
            totalAchievements: achievements.count,
            unlockedCount: unlockedAchievements.count,
            totalRewards: totalRewardsEarned,
            byRarity: byRarity,
            completionRate: Double(unlockedAchievements.count) / Double(achievements.count)
        )
    }
}

// MARK: - Achievement Stats Model

struct AchievementStats {
    let totalAchievements: Int
    let unlockedCount: Int
    let totalRewards: Int
    let byRarity: [AchievementRarity: (total: Int, unlocked: Int)]
    let completionRate: Double

    var completionPercentage: Int {
        Int(completionRate * 100)
    }
}
