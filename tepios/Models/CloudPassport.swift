/**
 * 雲端護照數據模型
 * 遊戲化系統：等級、福報值、成就
 */

import Foundation

// MARK: - Cloud Passport

struct CloudPassport: Codable {
    var level: Int
    var currentMeritPoints: Int
    var totalMeritPoints: Int
    var title: String
    var achievements: [PassportAchievement]
    var visitedTemples: [String] // Temple IDs
    var checkInStreak: Int // 連續打卡天數
    var lastCheckInDate: Date?

    init(
        level: Int = 1,
        currentMeritPoints: Int = 0,
        totalMeritPoints: Int = 0,
        title: String = "初心信徒",
        achievements: [PassportAchievement] = [],
        visitedTemples: [String] = [],
        checkInStreak: Int = 0,
        lastCheckInDate: Date? = nil
    ) {
        self.level = level
        self.currentMeritPoints = currentMeritPoints
        self.totalMeritPoints = totalMeritPoints
        self.title = title
        self.achievements = achievements
        self.visitedTemples = visitedTemples
        self.checkInStreak = checkInStreak
        self.lastCheckInDate = lastCheckInDate
    }

    /// 計算升級所需的福報值
    var meritPointsNeededForNextLevel: Int {
        return level * 100
    }

    /// 計算升級進度百分比
    var levelProgress: Double {
        let needed = meritPointsNeededForNextLevel
        return needed > 0 ? Double(currentMeritPoints) / Double(needed) : 0
    }

    /// 增加福報值並處理升級
    mutating func addMeritPoints(_ points: Int) {
        currentMeritPoints += points
        totalMeritPoints += points

        // 檢查是否升級
        while currentMeritPoints >= meritPointsNeededForNextLevel {
            currentMeritPoints -= meritPointsNeededForNextLevel
            level += 1
            updateTitle()
        }
    }

    /// 更新打卡連續天數
    mutating func updateCheckInStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastCheckIn = lastCheckInDate {
            let lastCheckInDay = calendar.startOfDay(for: lastCheckIn)
            let daysDifference = calendar.dateComponents([.day], from: lastCheckInDay, to: today).day ?? 0

            if daysDifference == 1 {
                // 連續打卡
                checkInStreak += 1
            } else if daysDifference > 1 {
                // 中斷連續打卡
                checkInStreak = 1
            }
            // daysDifference == 0 代表今天已經打卡過，不更新
        } else {
            // 第一次打卡
            checkInStreak = 1
        }

        lastCheckInDate = today
    }

    /// 根據等級更新稱號
    private mutating func updateTitle() {
        switch level {
        case 1...5:
            title = "初心信徒"
        case 6...10:
            title = "虔誠弟子"
        case 11...20:
            title = "敬神居士"
        case 21...30:
            title = "德行善士"
        case 31...40:
            title = "福德使者"
        case 41...50:
            title = "神明侍者"
        case 51...60:
            title = "護法金剛"
        case 61...70:
            title = "天庭使節"
        case 71...80:
            title = "仙家護法"
        case 81...90:
            title = "道德真人"
        case 91...99:
            title = "位列仙班"
        default:
            title = "功德圓滿"
        }
    }
}

// MARK: - Passport Achievement

struct PassportAchievement: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let iconName: String
    let category: PassportAchievementCategory
    let requirement: Int
    var currentProgress: Int
    var isUnlocked: Bool
    let rewardPoints: Int

    init(
        id: String = UUID().uuidString,
        name: String,
        description: String,
        iconName: String,
        category: PassportAchievementCategory,
        requirement: Int,
        currentProgress: Int = 0,
        isUnlocked: Bool = false,
        rewardPoints: Int
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.iconName = iconName
        self.category = category
        self.requirement = requirement
        self.currentProgress = currentProgress
        self.isUnlocked = isUnlocked
        self.rewardPoints = rewardPoints
    }

    /// 進度百分比
    var progress: Double {
        return requirement > 0 ? Double(currentProgress) / Double(requirement) : 0
    }

    /// 更新進度
    mutating func updateProgress(_ value: Int) {
        currentProgress = value
        if currentProgress >= requirement {
            isUnlocked = true
        }
    }
}

// MARK: - Passport Achievement Category

enum PassportAchievementCategory: String, Codable, CaseIterable {
    case checkIn = "打卡達人"
    case prayer = "虔誠祈福"
    case temple = "走遍廟宇"
    case streak = "連續不斷"
    case special = "特殊成就"

    var iconName: String {
        switch self {
        case .checkIn: return "checkmark.circle.fill"
        case .prayer: return "flame.fill"
        case .temple: return "building.columns.fill"
        case .streak: return "calendar.badge.clock"
        case .special: return "star.fill"
        }
    }

    var color: String {
        switch self {
        case .checkIn: return "#10B981"
        case .prayer: return "#F59E0B"
        case .temple: return "#8B5CF6"
        case .streak: return "#EF4444"
        case .special: return "#BDA138"
        }
    }
}

// MARK: - Predefined Achievements

extension PassportAchievement {
    static let allAchievements: [PassportAchievement] = [
        // 打卡成就
        PassportAchievement(
            name: "初來乍到",
            description: "完成第一次打卡",
            iconName: "1.circle.fill",
            category: .checkIn,
            requirement: 1,
            rewardPoints: 10
        ),
        PassportAchievement(
            name: "打卡新手",
            description: "累計打卡 10 次",
            iconName: "10.circle.fill",
            category: .checkIn,
            requirement: 10,
            rewardPoints: 50
        ),
        PassportAchievement(
            name: "打卡達人",
            description: "累計打卡 50 次",
            iconName: "50.circle.fill",
            category: .checkIn,
            requirement: 50,
            rewardPoints: 200
        ),
        PassportAchievement(
            name: "打卡宗師",
            description: "累計打卡 100 次",
            iconName: "100.circle.fill",
            category: .checkIn,
            requirement: 100,
            rewardPoints: 500
        ),

        // 祈福成就
        PassportAchievement(
            name: "誠心祈福",
            description: "完成 10 次祈福",
            iconName: "hands.sparkles.fill",
            category: .prayer,
            requirement: 10,
            rewardPoints: 50
        ),
        PassportAchievement(
            name: "虔誠信徒",
            description: "完成 50 次祈福",
            iconName: "heart.fill",
            category: .prayer,
            requirement: 50,
            rewardPoints: 200
        ),

        // 廟宇探訪成就
        PassportAchievement(
            name: "探索之旅",
            description: "拜訪 5 間不同的廟宇",
            iconName: "map.fill",
            category: .temple,
            requirement: 5,
            rewardPoints: 100
        ),
        PassportAchievement(
            name: "廟宇行者",
            description: "拜訪 20 間不同的廟宇",
            iconName: "location.fill",
            category: .temple,
            requirement: 20,
            rewardPoints: 500
        ),

        // 連續打卡成就
        PassportAchievement(
            name: "持之以恆",
            description: "連續打卡 7 天",
            iconName: "7.circle.fill",
            category: .streak,
            requirement: 7,
            rewardPoints: 100
        ),
        PassportAchievement(
            name: "堅持不懈",
            description: "連續打卡 30 天",
            iconName: "30.circle.fill",
            category: .streak,
            requirement: 30,
            rewardPoints: 500
        ),

        // 特殊成就
        PassportAchievement(
            name: "綁定平安符",
            description: "綁定你的第一個平安符",
            iconName: "tag.fill",
            category: .special,
            requirement: 1,
            rewardPoints: 50
        ),
        PassportAchievement(
            name: "信仰之路",
            description: "選擇你的信仰神明",
            iconName: "sparkles",
            category: .special,
            requirement: 1,
            rewardPoints: 30
        )
    ]
}
