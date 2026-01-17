/**
 * 成就系統數據模型
 */

import Foundation

// MARK: - Achievement Model

struct Achievement: Identifiable, Equatable {
    var id: String
    var title: String
    var description: String
    var icon: String
    var type: AchievementType
    var rarity: AchievementRarity
    var requirement: AchievementRequirement
    var rewardPoints: Int
    var progress: Int
    var unlocked: Bool
    var unlockedDate: Date?

    var maxProgress: Int {
        requirement.targetValue
    }

    var progressPercentage: Double {
        guard maxProgress > 0 else { return 0 }
        return min(Double(progress) / Double(maxProgress), 1.0)
    }

    var isComplete: Bool {
        progress >= maxProgress
    }

    mutating func updateProgress(_ newProgress: Int) {
        progress = newProgress
        if isComplete && !unlocked {
            unlocked = true
            unlockedDate = Date()
        }
    }
}

// MARK: - Achievement Type

enum AchievementType: String, Codable, CaseIterable {
    case checkIn = "打卡成就"
    case prayer = "祈福成就"
    case exploration = "探索成就"
    case blessPoints = "福報成就"
    case social = "社交成就"
    case collection = "收藏成就"
    case special = "特殊成就"

    var icon: String {
        switch self {
        case .checkIn: return "calendar.badge.checkmark"
        case .prayer: return "hands.sparkles"
        case .exploration: return "map"
        case .blessPoints: return "star.fill"
        case .social: return "person.3"
        case .collection: return "scroll"
        case .special: return "crown"
        }
    }

    var color: String {
        switch self {
        case .checkIn: return "#4A90E2"
        case .prayer: return "#9B59B6"
        case .exploration: return "#E67E22"
        case .blessPoints: return "#F1C40F"
        case .social: return "#1ABC9C"
        case .collection: return "#E74C3C"
        case .special: return "#FFD700"
        }
    }
}

// MARK: - Achievement Rarity

enum AchievementRarity: String, Codable, CaseIterable {
    case bronze = "青銅"
    case silver = "白銀"
    case gold = "黃金"
    case diamond = "鑽石"

    var icon: String {
        switch self {
        case .bronze: return "⚫️"
        case .silver: return "⚪️"
        case .gold: return "🟡"
        case .diamond: return "💎"
        }
    }

    var multiplier: Double {
        switch self {
        case .bronze: return 1.0
        case .silver: return 1.5
        case .gold: return 2.0
        case .diamond: return 3.0
        }
    }
}

// MARK: - Achievement Requirement

enum AchievementRequirement: Equatable {
    case firstCheckIn
    case consecutiveDays(Int)
    case totalCheckIns(Int)
    case visitTemples(Int)
    case earnPoints(Int)
    case totalPoints(Int)
    case prayerCount(Int)
    case visitAllDeityTypes
    case checkInAllTemples
    case perfectWeek  // 一週打卡7天
    case earlyBird(Int)  // 早上6-9點打卡N次
    case nightOwl(Int)  // 晚上9-12點打卡N次
    case inviteFriends(Int)
    case shareCheckIns(Int)

    var targetValue: Int {
        switch self {
        case .firstCheckIn: return 1
        case .consecutiveDays(let days): return days
        case .totalCheckIns(let count): return count
        case .visitTemples(let count): return count
        case .earnPoints(let points): return points
        case .totalPoints(let points): return points
        case .prayerCount(let count): return count
        case .visitAllDeityTypes: return 10  // 假設有10種神明
        case .checkInAllTemples: return 5  // 目前有5間廟
        case .perfectWeek: return 7
        case .earlyBird(let count): return count
        case .nightOwl(let count): return count
        case .inviteFriends(let count): return count
        case .shareCheckIns(let count): return count
        }
    }

    var displayText: String {
        switch self {
        case .firstCheckIn:
            return "完成第一次打卡"
        case .consecutiveDays(let days):
            return "連續打卡 \(days) 天"
        case .totalCheckIns(let count):
            return "累計打卡 \(count) 次"
        case .visitTemples(let count):
            return "拜訪 \(count) 間不同廟宇"
        case .earnPoints(let points):
            return "單次獲得 \(points) 福報值"
        case .totalPoints(let points):
            return "累積 \(points) 福報值"
        case .prayerCount(let count):
            return "祈福 \(count) 次"
        case .visitAllDeityTypes:
            return "拜訪所有類型的神明"
        case .checkInAllTemples:
            return "打卡所有廟宇"
        case .perfectWeek:
            return "一週內每天都打卡"
        case .earlyBird(let count):
            return "早上 6-9 點打卡 \(count) 次"
        case .nightOwl(let count):
            return "晚上 9-12 點打卡 \(count) 次"
        case .inviteFriends(let count):
            return "邀請 \(count) 位好友"
        case .shareCheckIns(let count):
            return "分享打卡 \(count) 次"
        }
    }
}

// MARK: - Codable Implementation for Achievement

extension Achievement: Codable {
    enum CodingKeys: String, CodingKey {
        case id, title, description, icon, type, rarity, requirement, rewardPoints, progress, unlocked, unlockedDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        icon = try container.decode(String.self, forKey: .icon)
        type = try container.decode(AchievementType.self, forKey: .type)
        rarity = try container.decode(AchievementRarity.self, forKey: .rarity)
        requirement = try container.decode(AchievementRequirement.self, forKey: .requirement)
        rewardPoints = try container.decode(Int.self, forKey: .rewardPoints)
        progress = try container.decode(Int.self, forKey: .progress)
        unlocked = try container.decode(Bool.self, forKey: .unlocked)
        unlockedDate = try container.decodeIfPresent(Date.self, forKey: .unlockedDate)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(icon, forKey: .icon)
        try container.encode(type, forKey: .type)
        try container.encode(rarity, forKey: .rarity)
        try container.encode(requirement, forKey: .requirement)
        try container.encode(rewardPoints, forKey: .rewardPoints)
        try container.encode(progress, forKey: .progress)
        try container.encode(unlocked, forKey: .unlocked)
        try container.encodeIfPresent(unlockedDate, forKey: .unlockedDate)
    }
}

// MARK: - Codable Implementation for AchievementRequirement

extension AchievementRequirement: Codable {
    enum CodingKeys: String, CodingKey {
        case type, value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "firstCheckIn":
            self = .firstCheckIn
        case "consecutiveDays":
            let value = try container.decode(Int.self, forKey: .value)
            self = .consecutiveDays(value)
        case "totalCheckIns":
            let value = try container.decode(Int.self, forKey: .value)
            self = .totalCheckIns(value)
        case "visitTemples":
            let value = try container.decode(Int.self, forKey: .value)
            self = .visitTemples(value)
        case "earnPoints":
            let value = try container.decode(Int.self, forKey: .value)
            self = .earnPoints(value)
        case "totalPoints":
            let value = try container.decode(Int.self, forKey: .value)
            self = .totalPoints(value)
        case "prayerCount":
            let value = try container.decode(Int.self, forKey: .value)
            self = .prayerCount(value)
        case "visitAllDeityTypes":
            self = .visitAllDeityTypes
        case "checkInAllTemples":
            self = .checkInAllTemples
        case "perfectWeek":
            self = .perfectWeek
        case "earlyBird":
            let value = try container.decode(Int.self, forKey: .value)
            self = .earlyBird(value)
        case "nightOwl":
            let value = try container.decode(Int.self, forKey: .value)
            self = .nightOwl(value)
        case "inviteFriends":
            let value = try container.decode(Int.self, forKey: .value)
            self = .inviteFriends(value)
        case "shareCheckIns":
            let value = try container.decode(Int.self, forKey: .value)
            self = .shareCheckIns(value)
        default:
            self = .firstCheckIn
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .firstCheckIn:
            try container.encode("firstCheckIn", forKey: .type)
        case .consecutiveDays(let value):
            try container.encode("consecutiveDays", forKey: .type)
            try container.encode(value, forKey: .value)
        case .totalCheckIns(let value):
            try container.encode("totalCheckIns", forKey: .type)
            try container.encode(value, forKey: .value)
        case .visitTemples(let value):
            try container.encode("visitTemples", forKey: .type)
            try container.encode(value, forKey: .value)
        case .earnPoints(let value):
            try container.encode("earnPoints", forKey: .type)
            try container.encode(value, forKey: .value)
        case .totalPoints(let value):
            try container.encode("totalPoints", forKey: .type)
            try container.encode(value, forKey: .value)
        case .prayerCount(let value):
            try container.encode("prayerCount", forKey: .type)
            try container.encode(value, forKey: .value)
        case .visitAllDeityTypes:
            try container.encode("visitAllDeityTypes", forKey: .type)
        case .checkInAllTemples:
            try container.encode("checkInAllTemples", forKey: .type)
        case .perfectWeek:
            try container.encode("perfectWeek", forKey: .type)
        case .earlyBird(let value):
            try container.encode("earlyBird", forKey: .type)
            try container.encode(value, forKey: .value)
        case .nightOwl(let value):
            try container.encode("nightOwl", forKey: .type)
            try container.encode(value, forKey: .value)
        case .inviteFriends(let value):
            try container.encode("inviteFriends", forKey: .type)
            try container.encode(value, forKey: .value)
        case .shareCheckIns(let value):
            try container.encode("shareCheckIns", forKey: .type)
            try container.encode(value, forKey: .value)
        }
    }
}

// MARK: - Predefined Achievements

extension Achievement {
    static let allAchievements: [Achievement] = [
        // 青銅成就 - 新手入門
        Achievement(
            id: "bronze_1",
            title: "初心者",
            description: "完成第一次打卡，踏上信仰之路",
            icon: "flame",
            type: .checkIn,
            rarity: .bronze,
            requirement: .firstCheckIn,
            rewardPoints: 50,
            progress: 0,
            unlocked: false
        ),
        Achievement(
            id: "bronze_2",
            title: "虔誠信徒",
            description: "連續打卡7天，展現你的虔誠",
            icon: "calendar.badge.checkmark",
            type: .checkIn,
            rarity: .bronze,
            requirement: .consecutiveDays(7),
            rewardPoints: 100,
            progress: 0,
            unlocked: false
        ),
        Achievement(
            id: "bronze_3",
            title: "初探廟宇",
            description: "拜訪3間不同的廟宇",
            icon: "building.2",
            type: .exploration,
            rarity: .bronze,
            requirement: .visitTemples(3),
            rewardPoints: 75,
            progress: 0,
            unlocked: false
        ),
        Achievement(
            id: "bronze_4",
            title: "福報萌芽",
            description: "累積100點福報值",
            icon: "star.fill",
            type: .blessPoints,
            rarity: .bronze,
            requirement: .totalPoints(100),
            rewardPoints: 50,
            progress: 0,
            unlocked: false
        ),

        // 白銀成就 - 進階修行
        Achievement(
            id: "silver_1",
            title: "修行者",
            description: "連續打卡30天，修行日益精進",
            icon: "calendar.circle.fill",
            type: .checkIn,
            rarity: .silver,
            requirement: .consecutiveDays(30),
            rewardPoints: 300,
            progress: 0,
            unlocked: false
        ),
        Achievement(
            id: "silver_2",
            title: "探索者",
            description: "拜訪所有類型的神明廟宇",
            icon: "map.fill",
            type: .exploration,
            rarity: .silver,
            requirement: .visitAllDeityTypes,
            rewardPoints: 250,
            progress: 0,
            unlocked: false
        ),
        Achievement(
            id: "silver_3",
            title: "福報滿滿",
            description: "累積500點福報值",
            icon: "sparkles",
            type: .blessPoints,
            rarity: .silver,
            requirement: .totalPoints(500),
            rewardPoints: 150,
            progress: 0,
            unlocked: false
        ),
        Achievement(
            id: "silver_4",
            title: "勤勉信徒",
            description: "累計打卡50次",
            icon: "checkmark.seal.fill",
            type: .checkIn,
            rarity: .silver,
            requirement: .totalCheckIns(50),
            rewardPoints: 200,
            progress: 0,
            unlocked: false
        ),
        Achievement(
            id: "silver_5",
            title: "完美一週",
            description: "一週內每天都打卡",
            icon: "7.circle.fill",
            type: .checkIn,
            rarity: .silver,
            requirement: .perfectWeek,
            rewardPoints: 180,
            progress: 0,
            unlocked: false
        ),

        // 黃金成就 - 資深信眾
        Achievement(
            id: "gold_1",
            title: "虔誠使者",
            description: "連續打卡100天，虔誠之心堅若磐石",
            icon: "flame.fill",
            type: .checkIn,
            rarity: .gold,
            requirement: .consecutiveDays(100),
            rewardPoints: 800,
            progress: 0,
            unlocked: false
        ),
        Achievement(
            id: "gold_2",
            title: "廟宇大師",
            description: "打卡所有廟宇",
            icon: "building.columns.fill",
            type: .exploration,
            rarity: .gold,
            requirement: .checkInAllTemples,
            rewardPoints: 500,
            progress: 0,
            unlocked: false
        ),
        Achievement(
            id: "gold_3",
            title: "福報千里",
            description: "累積1000點福報值",
            icon: "star.circle.fill",
            type: .blessPoints,
            rarity: .gold,
            requirement: .totalPoints(1000),
            rewardPoints: 400,
            progress: 0,
            unlocked: false
        ),
        Achievement(
            id: "gold_4",
            title: "百里挑一",
            description: "累計打卡100次",
            icon: "100.circle.fill",
            type: .checkIn,
            rarity: .gold,
            requirement: .totalCheckIns(100),
            rewardPoints: 600,
            progress: 0,
            unlocked: false
        ),
        Achievement(
            id: "gold_5",
            title: "早起鳥",
            description: "早上6-9點打卡20次",
            icon: "sunrise.fill",
            type: .special,
            rarity: .gold,
            requirement: .earlyBird(20),
            rewardPoints: 350,
            progress: 0,
            unlocked: false
        ),

        // 鑽石成就 - 傳奇信眾
        Achievement(
            id: "diamond_1",
            title: "信仰之光",
            description: "連續打卡365天，一整年的堅持",
            icon: "crown.fill",
            type: .checkIn,
            rarity: .diamond,
            requirement: .consecutiveDays(365),
            rewardPoints: 3000,
            progress: 0,
            unlocked: false
        ),
        Achievement(
            id: "diamond_2",
            title: "福報萬千",
            description: "累積5000點福報值",
            icon: "sparkle",
            type: .blessPoints,
            rarity: .diamond,
            requirement: .totalPoints(5000),
            rewardPoints: 2000,
            progress: 0,
            unlocked: false
        ),
        Achievement(
            id: "diamond_3",
            title: "傳奇信徒",
            description: "累計打卡365次",
            icon: "medal.fill",
            type: .checkIn,
            rarity: .diamond,
            requirement: .totalCheckIns(365),
            rewardPoints: 2500,
            progress: 0,
            unlocked: false
        ),
        Achievement(
            id: "diamond_4",
            title: "夜間守護者",
            description: "晚上9-12點打卡30次",
            icon: "moon.stars.fill",
            type: .special,
            rarity: .diamond,
            requirement: .nightOwl(30),
            rewardPoints: 1500,
            progress: 0,
            unlocked: false
        )
    ]
}
