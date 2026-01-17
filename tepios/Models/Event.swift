/**
 * 活動資料模型
 */

import Foundation

// MARK: - Event

struct Event: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let imageUrl: String?
    let category: EventCategory
    let startDate: Date
    let endDate: Date
    let location: String
    let templeId: String?
    let templeName: String?
    let maxParticipants: Int?
    let currentParticipants: Int
    let fee: Int // 0 表示免費
    let meritPointsReward: Int // 參加可獲得的福報值
    let requirements: [String] // 報名條件
    let organizer: String
    let contactInfo: String

    init(
        id: String = UUID().uuidString,
        title: String,
        description: String,
        imageUrl: String? = nil,
        category: EventCategory,
        startDate: Date,
        endDate: Date,
        location: String,
        templeId: String? = nil,
        templeName: String? = nil,
        maxParticipants: Int? = nil,
        currentParticipants: Int = 0,
        fee: Int = 0,
        meritPointsReward: Int = 0,
        requirements: [String] = [],
        organizer: String,
        contactInfo: String
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.imageUrl = imageUrl
        self.category = category
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.templeId = templeId
        self.templeName = templeName
        self.maxParticipants = maxParticipants
        self.currentParticipants = currentParticipants
        self.fee = fee
        self.meritPointsReward = meritPointsReward
        self.requirements = requirements
        self.organizer = organizer
        self.contactInfo = contactInfo
    }

    /// 活動狀態
    var status: EventStatus {
        let now = Date()
        if now < startDate {
            return .upcoming
        } else if now >= startDate && now <= endDate {
            return .ongoing
        } else {
            return .ended
        }
    }

    /// 是否已額滿
    var isFull: Bool {
        guard let max = maxParticipants else { return false }
        return currentParticipants >= max
    }

    /// 是否可報名
    var canRegister: Bool {
        return status == .upcoming && !isFull
    }

    /// 剩餘名額
    var remainingSlots: Int? {
        guard let maxCount = maxParticipants else { return nil }
        return Swift.max(0, maxCount - currentParticipants)
    }

    /// 格式化日期範圍
    var dateRangeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"

        let startString = formatter.string(from: startDate)
        let endString = formatter.string(from: endDate)

        if startString == endString {
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
            return formatter.string(from: startDate)
        } else {
            return "\(startString) - \(endString)"
        }
    }
}

// MARK: - Event Category

enum EventCategory: String, Codable, CaseIterable {
    case ceremony = "法會儀式"
    case festival = "廟會慶典"
    case lecture = "講座課程"
    case volunteer = "志工服務"
    case pilgrimage = "進香參拜"
    case charity = "公益活動"
    case cultural = "文化體驗"

    var iconName: String {
        switch self {
        case .ceremony: return "flame.fill"
        case .festival: return "party.popper.fill"
        case .lecture: return "book.fill"
        case .volunteer: return "hands.and.sparkles.fill"
        case .pilgrimage: return "figure.walk"
        case .charity: return "heart.fill"
        case .cultural: return "theatermasks.fill"
        }
    }

    var color: String {
        switch self {
        case .ceremony: return "#F59E0B"
        case .festival: return "#EF4444"
        case .lecture: return "#3B82F6"
        case .volunteer: return "#10B981"
        case .pilgrimage: return "#8B5CF6"
        case .charity: return "#EC4899"
        case .cultural: return "#06B6D4"
        }
    }
}

// MARK: - Event Status

enum EventStatus: String {
    case upcoming = "即將開始"
    case ongoing = "進行中"
    case ended = "已結束"

    var color: String {
        switch self {
        case .upcoming: return "#3B82F6"
        case .ongoing: return "#10B981"
        case .ended: return "#6B7280"
        }
    }
}

// MARK: - Event Registration

struct EventRegistration: Codable, Identifiable {
    let id: String
    let eventId: String
    let eventTitle: String
    let userId: String
    let userName: String
    let registrationDate: Date
    let status: RegistrationStatus
    let notes: String?

    init(
        id: String = UUID().uuidString,
        eventId: String,
        eventTitle: String,
        userId: String,
        userName: String,
        registrationDate: Date = Date(),
        status: RegistrationStatus = .confirmed,
        notes: String? = nil
    ) {
        self.id = id
        self.eventId = eventId
        self.eventTitle = eventTitle
        self.userId = userId
        self.userName = userName
        self.registrationDate = registrationDate
        self.status = status
        self.notes = notes
    }
}

// MARK: - Registration Status

enum RegistrationStatus: String, Codable {
    case pending = "待確認"
    case confirmed = "已確認"
    case attended = "已參加"
    case cancelled = "已取消"

    var color: String {
        switch self {
        case .pending: return "#F59E0B"
        case .confirmed: return "#10B981"
        case .attended: return "#3B82F6"
        case .cancelled: return "#6B7280"
        }
    }
}

// MARK: - Mock Events

extension Event {
    static let mockEvents: [Event] = [
        Event(
            title: "新春祈福法會",
            description: "農曆新年祈福法會，祈求新的一年平安順利、闔家安康。法會由資深法師主持，包含祈福儀式、點燈祈願等環節。",
            category: .ceremony,
            startDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!.addingTimeInterval(3 * 60 * 60),
            location: "艋舺龍山寺 大殿",
            templeId: "temple_001",
            templeName: "艋舺龍山寺",
            maxParticipants: 100,
            currentParticipants: 67,
            meritPointsReward: 50,
            requirements: ["年滿18歲", "需提前報名"],
            organizer: "艋舺龍山寺",
            contactInfo: "02-2302-5162"
        ),
        Event(
            title: "關聖帝君聖誕慶典",
            description: "慶祝關聖帝君聖誕千秋，舉辦盛大廟會活動。包含神明遶境、傳統戲曲表演、美食市集等精彩節目。",
            category: .festival,
            startDate: Calendar.current.date(byAdding: .day, value: 14, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: 16, to: Date())!,
            location: "行天宮及周邊",
            templeId: "temple_002",
            templeName: "行天宮",
            currentParticipants: 234,
            meritPointsReward: 30,
            requirements: [],
            organizer: "行天宮管理委員會",
            contactInfo: "02-2502-7924"
        ),
        Event(
            title: "道德經研讀班",
            description: "由資深道長帶領研讀《道德經》，深入探討道家智慧。適合對傳統文化有興趣的信眾參加。",
            category: .lecture,
            startDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!.addingTimeInterval(2 * 60 * 60),
            location: "指南宮 講經堂",
            templeId: "temple_003",
            templeName: "指南宮",
            maxParticipants: 50,
            currentParticipants: 28,
            fee: 200,
            meritPointsReward: 40,
            requirements: ["對道家文化有基本了解"],
            organizer: "指南宮文教基金會",
            contactInfo: "02-2939-9922"
        ),
        Event(
            title: "環境清潔志工日",
            description: "招募志工協助廟宇周邊環境清潔，為社區環境盡一份心力。提供午餐及志工證明。",
            category: .volunteer,
            startDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!.addingTimeInterval(4 * 60 * 60),
            location: "龍山寺周邊",
            templeId: "temple_001",
            templeName: "艋舺龍山寺",
            maxParticipants: 30,
            currentParticipants: 18,
            meritPointsReward: 80,
            requirements: ["年滿16歲", "自備手套"],
            organizer: "龍山寺志工團",
            contactInfo: "02-2302-5162"
        ),
        Event(
            title: "北港媽祖進香團",
            description: "組團前往北港朝天宮進香參拜，體驗傳統宗教文化。包含遊覽車接送及導覽解說。",
            category: .pilgrimage,
            startDate: Calendar.current.date(byAdding: .day, value: 21, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: 22, to: Date())!,
            location: "北港朝天宮",
            maxParticipants: 40,
            currentParticipants: 35,
            fee: 1500,
            meritPointsReward: 100,
            requirements: ["身體健康", "需繳交訂金"],
            organizer: "信眾進香團",
            contactInfo: "0912-345-678"
        ),
        Event(
            title: "冬令救濟物資發放",
            description: "協助弱勢家庭冬令物資發放，需要志工協助整理及發放物資。",
            category: .charity,
            startDate: Calendar.current.date(byAdding: .day, value: 10, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: 10, to: Date())!.addingTimeInterval(5 * 60 * 60),
            location: "社區活動中心",
            maxParticipants: 20,
            currentParticipants: 12,
            meritPointsReward: 120,
            requirements: ["有愛心", "能配合時間"],
            organizer: "慈善基金會",
            contactInfo: "02-2345-6789"
        )
    ]
}
