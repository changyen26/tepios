/**
 * 神明卡牌模型
 * 寶可夢風格的神明收集卡牌系統
 */

import Foundation

// MARK: - Deity Card

struct DeityCard: Identifiable, Codable, Hashable {
    let id: String
    let deityId: String // 關聯的神明 ID
    let name: String // 神明名稱
    let title: String // 稱號
    let description: String // 神明介紹
    let rarity: CardRarity // 稀有度
    let type: DeityType // 神明類型
    let blessings: [BlessingType] // 保佑類型
    let imageName: String // 卡牌圖片
    let templeIds: [String] // 關聯廟宇 ID
    let power: Int // 神力值（用於展示）
    let wisdom: Int // 智慧值
    let fortune: Int // 福運值

    // 卡牌編號
    var cardNumber: String {
        let rarityPrefix: String
        switch rarity {
        case .common: rarityPrefix = "C"
        case .rare: rarityPrefix = "R"
        case .epic: rarityPrefix = "E"
        case .legendary: rarityPrefix = "L"
        case .mythical: rarityPrefix = "M"
        }
        return "\(rarityPrefix)-\(String(format: "%03d", id.hashValue % 1000))"
    }
}

// MARK: - Card Rarity

enum CardRarity: String, Codable, CaseIterable {
    case common = "普通"
    case rare = "稀有"
    case epic = "史詩"
    case legendary = "傳說"
    case mythical = "神話"

    var color: String {
        switch self {
        case .common: return "9E9E9E" // 灰色
        case .rare: return "2196F3" // 藍色
        case .epic: return "9C27B0" // 紫色
        case .legendary: return "FF9800" // 橙色
        case .mythical: return "FF1744" // 紅色
        }
    }

    var glowColor: String {
        switch self {
        case .common: return "BDBDBD"
        case .rare: return "64B5F6"
        case .epic: return "BA68C8"
        case .legendary: return "FFB74D"
        case .mythical: return "FF5252"
        }
    }

    var icon: String {
        switch self {
        case .common: return "circle.fill"
        case .rare: return "diamond.fill"
        case .epic: return "star.fill"
        case .legendary: return "crown.fill"
        case .mythical: return "sparkles"
        }
    }

    // 抽卡機率（百分比）
    var dropRate: Double {
        switch self {
        case .common: return 50.0
        case .rare: return 30.0
        case .epic: return 15.0
        case .legendary: return 4.5
        case .mythical: return 0.5
        }
    }
}

// MARK: - Deity Type

enum DeityType: String, Codable, CaseIterable {
    case supreme = "至高神明" // 玉皇大帝等
    case warrior = "武財神" // 關聖帝君、趙公明
    case civilWealth = "文財神" // 文昌帝君、比干
    case seaGoddess = "海上女神" // 媽祖
    case medicine = "醫藥之神" // 保生大帝
    case matchmaker = "月老姻緣" // 月下老人
    case guardian = "護法神將" // 玄天上帝、哪吒
    case scholar = "文運之神" // 文昌帝君、魁星
    case local = "地方守護" // 土地公、城隍爺
    case ancestor = "祖先聖賢" // 孔子等

    var icon: String {
        switch self {
        case .supreme: return "crown.fill"
        case .warrior: return "shield.fill"
        case .civilWealth: return "books.vertical.fill"
        case .seaGoddess: return "water.waves"
        case .medicine: return "cross.case.fill"
        case .matchmaker: return "heart.fill"
        case .guardian: return "bolt.shield.fill"
        case .scholar: return "book.fill"
        case .local: return "house.fill"
        case .ancestor: return "person.fill"
        }
    }

    var color: String {
        switch self {
        case .supreme: return "FFD700" // 金色
        case .warrior: return "DC143C" // 紅色
        case .civilWealth: return "4169E1" // 藍色
        case .seaGoddess: return "1E90FF" // 海藍
        case .medicine: return "32CD32" // 綠色
        case .matchmaker: return "FF69B4" // 粉紅
        case .guardian: return "FF4500" // 橘紅
        case .scholar: return "9370DB" // 紫色
        case .local: return "8B4513" // 棕色
        case .ancestor: return "696969" // 灰色
        }
    }
}

// MARK: - Blessing Type

enum BlessingType: String, Codable, CaseIterable {
    case wealth = "財運亨通"
    case health = "健康平安"
    case career = "事業順利"
    case study = "學業進步"
    case love = "姻緣美滿"
    case family = "家庭和睦"
    case protection = "驅邪避凶"
    case wisdom = "智慧增長"
    case longevity = "延年益壽"
    case travel = "出入平安"

    var icon: String {
        switch self {
        case .wealth: return "dollarsign.circle.fill"
        case .health: return "heart.circle.fill"
        case .career: return "briefcase.fill"
        case .study: return "book.circle.fill"
        case .love: return "heart.fill"
        case .family: return "house.fill"
        case .protection: return "shield.fill"
        case .wisdom: return "brain.head.profile"
        case .longevity: return "infinity.circle.fill"
        case .travel: return "car.circle.fill"
        }
    }
}

// MARK: - Collected Card

struct CollectedCard: Identifiable, Codable {
    let id: String
    let cardId: String // 關聯的 DeityCard ID
    let obtainedDate: Date // 獲得日期
    let obtainMethod: ObtainMethod // 獲得方式
    var level: Int // 卡牌等級（重複獲得可升級）
    var isFavorite: Bool // 是否最愛

    init(cardId: String, obtainMethod: ObtainMethod, level: Int = 1) {
        self.id = UUID().uuidString
        self.cardId = cardId
        self.obtainedDate = Date()
        self.obtainMethod = obtainMethod
        self.level = level
        self.isFavorite = false
    }
}

// MARK: - Obtain Method

enum ObtainMethod: String, Codable {
    case checkIn = "廟宇打卡"
    case gacha = "福報抽卡"
    case achievement = "成就解鎖"
    case event = "活動獎勵"
    case purchase = "商城購買"
    case gift = "系統贈送"
    case exchange = "好友交換"

    var icon: String {
        switch self {
        case .checkIn: return "location.fill"
        case .gacha: return "gift.fill"
        case .achievement: return "trophy.fill"
        case .event: return "calendar.badge.clock"
        case .purchase: return "cart.fill"
        case .gift: return "gift.fill"
        case .exchange: return "arrow.left.arrow.right"
        }
    }
}

// MARK: - Mock Data

extension DeityCard {
    static let mockCards: [DeityCard] = [
        // 傳說級 - 關聖帝君
        DeityCard(
            id: "card_001",
            deityId: "deity_guandi",
            name: "關聖帝君",
            title: "武財神・忠義之神",
            description: "關羽，字雲長，三國時期蜀漢名將。以忠義仁勇著稱，被尊為武財神，保佑信眾財運亨通、事業有成。",
            rarity: .legendary,
            type: .warrior,
            blessings: [.wealth, .career, .protection],
            imageName: "card_guandi",
            templeIds: ["temple_xingtian"],
            power: 98,
            wisdom: 90,
            fortune: 95
        ),

        // 史詩級 - 媽祖
        DeityCard(
            id: "card_002",
            deityId: "deity_mazu",
            name: "天上聖母",
            title: "媽祖・海上女神",
            description: "林默娘，宋代福建莆田人。一生救人無數，被尊為海上守護神，庇佑航海平安、漁業豐收。",
            rarity: .epic,
            type: .seaGoddess,
            blessings: [.travel, .protection, .family],
            imageName: "card_mazu",
            templeIds: ["temple_longshan"],
            power: 92,
            wisdom: 88,
            fortune: 90
        ),

        // 傳說級 - 玄天上帝
        DeityCard(
            id: "card_003",
            deityId: "deity_xuantian",
            name: "玄天上帝",
            title: "北極大帝・真武大帝",
            description: "道教重要神祇，統領北方，具有消災解厄、驅邪鎮煞的神力，為武當山主神。",
            rarity: .legendary,
            type: .guardian,
            blessings: [.protection, .health, .wisdom],
            imageName: "card_xuantian",
            templeIds: ["temple_shoutian"],
            power: 96,
            wisdom: 85,
            fortune: 88
        ),

        // 稀有級 - 月下老人
        DeityCard(
            id: "card_004",
            deityId: "deity_yuelao",
            name: "月下老人",
            title: "姻緣之神",
            description: "掌管世間男女姻緣，以紅線牽引有緣人，保佑信眾覓得良緣、婚姻美滿。",
            rarity: .rare,
            type: .matchmaker,
            blessings: [.love, .family],
            imageName: "card_yuelao",
            templeIds: [],
            power: 70,
            wisdom: 92,
            fortune: 85
        ),

        // 史詩級 - 文昌帝君
        DeityCard(
            id: "card_005",
            deityId: "deity_wenchang",
            name: "文昌帝君",
            title: "文運之神・梓潼帝君",
            description: "掌管功名利祿、文運學業，保佑學子考試順利、金榜題名。",
            rarity: .epic,
            type: .scholar,
            blessings: [.study, .wisdom, .career],
            imageName: "card_wenchang",
            templeIds: [],
            power: 75,
            wisdom: 98,
            fortune: 88
        ),

        // 普通級 - 土地公
        DeityCard(
            id: "card_006",
            deityId: "deity_tudgong",
            name: "福德正神",
            title: "土地公",
            description: "守護地方的神明，保佑當地居民平安、農作豐收、生意興隆。",
            rarity: .common,
            type: .local,
            blessings: [.wealth, .protection, .family],
            imageName: "card_tudgong",
            templeIds: [],
            power: 65,
            wisdom: 70,
            fortune: 80
        ),

        // 稀有級 - 保生大帝
        DeityCard(
            id: "card_007",
            deityId: "deity_baosheng",
            name: "保生大帝",
            title: "醫神・大道公",
            description: "宋代名醫吳夲，醫術高超、濟世救人，被尊為醫藥之神，保佑眾生健康平安。",
            rarity: .rare,
            type: .medicine,
            blessings: [.health, .longevity, .protection],
            imageName: "card_baosheng",
            templeIds: [],
            power: 80,
            wisdom: 90,
            fortune: 82
        ),

        // 神話級 - 玉皇大帝（隱藏卡）
        DeityCard(
            id: "card_008",
            deityId: "deity_yuhuang",
            name: "玉皇大帝",
            title: "天公・昊天上帝",
            description: "道教最高神祇，統領三界，掌管天地萬物，具有至高無上的神力。",
            rarity: .mythical,
            type: .supreme,
            blessings: [.wealth, .health, .career, .wisdom, .protection],
            imageName: "card_yuhuang",
            templeIds: [],
            power: 100,
            wisdom: 100,
            fortune: 100
        )
    ]

    // 根據稀有度獲取卡牌
    static func cardsByRarity(_ rarity: CardRarity) -> [DeityCard] {
        return mockCards.filter { $0.rarity == rarity }
    }

    // 根據類型獲取卡牌
    static func cardsByType(_ type: DeityType) -> [DeityCard] {
        return mockCards.filter { $0.type == type }
    }
}
