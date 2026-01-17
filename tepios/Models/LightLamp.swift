/**
 * 點燈祈福資料模型
 */

import Foundation

// MARK: - Light Lamp Model

struct LightLamp: Identifiable, Codable {
    let id: String
    var lampType: LampType
    var templeName: String
    var templeId: String
    var beneficiaryName: String // 祈福對象姓名
    var beneficiaryBirthday: Date? // 生辰
    var duration: LampDuration
    var startDate: Date
    var endDate: Date
    var purpose: String // 祈福目的
    var status: LampStatus
    var price: Int
    var createdDate: Date

    init(
        id: String = UUID().uuidString,
        lampType: LampType,
        templeName: String,
        templeId: String,
        beneficiaryName: String,
        beneficiaryBirthday: Date? = nil,
        duration: LampDuration,
        startDate: Date = Date(),
        purpose: String = "",
        status: LampStatus = .active,
        createdDate: Date = Date()
    ) {
        self.id = id
        self.lampType = lampType
        self.templeName = templeName
        self.templeId = templeId
        self.beneficiaryName = beneficiaryName
        self.beneficiaryBirthday = beneficiaryBirthday
        self.duration = duration
        self.startDate = startDate
        self.endDate = duration.calculateEndDate(from: startDate)
        self.purpose = purpose
        self.status = status
        self.price = duration.price(for: lampType)
        self.createdDate = createdDate
    }

    var daysRemaining: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let end = calendar.startOfDay(for: endDate)
        let components = calendar.dateComponents([.day], from: today, to: end)
        return max(0, components.day ?? 0)
    }

    var isExpired: Bool {
        return endDate < Date()
    }
}

// MARK: - Lamp Type

enum LampType: String, Codable, CaseIterable {
    case brightness = "光明燈"
    case peace = "平安燈"
    case wealth = "財運燈"
    case career = "事業燈"
    case study = "學業燈"
    case health = "健康燈"
    case marriage = "姻緣燈"
    case family = "闔家平安燈"

    var icon: String {
        switch self {
        case .brightness:
            return "sun.max.fill"
        case .peace:
            return "shield.fill"
        case .wealth:
            return "dollarsign.circle.fill"
        case .career:
            return "briefcase.fill"
        case .study:
            return "book.fill"
        case .health:
            return "heart.fill"
        case .marriage:
            return "heart.circle.fill"
        case .family:
            return "house.fill"
        }
    }

    var color: String {
        switch self {
        case .brightness:
            return "FFD700"
        case .peace:
            return "4A90E2"
        case .wealth:
            return "E74C3C"
        case .career:
            return "9B59B6"
        case .study:
            return "3498DB"
        case .health:
            return "E67E22"
        case .marriage:
            return "E91E63"
        case .family:
            return "27AE60"
        }
    }

    var description: String {
        switch self {
        case .brightness:
            return "祈求前途光明，事事順利"
        case .peace:
            return "保佑平安健康，出入平安"
        case .wealth:
            return "招財進寶，財源廣進"
        case .career:
            return "事業順利，步步高升"
        case .study:
            return "學業進步，考試順利"
        case .health:
            return "身體健康，延年益壽"
        case .marriage:
            return "良緣早至，婚姻美滿"
        case .family:
            return "闔家平安，家庭和樂"
        }
    }
}

// MARK: - Lamp Duration

enum LampDuration: String, Codable, CaseIterable {
    case oneMonth = "一個月"
    case threeMonths = "三個月"
    case sixMonths = "半年"
    case oneYear = "一年"

    var months: Int {
        switch self {
        case .oneMonth:
            return 1
        case .threeMonths:
            return 3
        case .sixMonths:
            return 6
        case .oneYear:
            return 12
        }
    }

    func calculateEndDate(from startDate: Date) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .month, value: months, to: startDate) ?? startDate
    }

    func price(for lampType: LampType) -> Int {
        let basePrice: Int
        switch lampType {
        case .brightness, .peace:
            basePrice = 300
        case .wealth, .career:
            basePrice = 500
        case .study, .health:
            basePrice = 400
        case .marriage:
            basePrice = 600
        case .family:
            basePrice = 800
        }

        return basePrice * months
    }
}

// MARK: - Lamp Status

enum LampStatus: String, Codable {
    case active = "點燈中"
    case expired = "已到期"
    case cancelled = "已取消"

    var color: String {
        switch self {
        case .active:
            return "27AE60"
        case .expired:
            return "95A5A6"
        case .cancelled:
            return "E74C3C"
        }
    }
}

// MARK: - Mock Data

extension LightLamp {
    static let mockLamps: [LightLamp] = [
        LightLamp(
            lampType: .brightness,
            templeName: "受天宮",
            templeId: "temple_001",
            beneficiaryName: "朝陽",
            beneficiaryBirthday: Date().addingTimeInterval(-60 * 60 * 24 * 365 * 30),
            duration: .oneYear,
            startDate: Date().addingTimeInterval(-60 * 60 * 24 * 60),
            purpose: "祈求事業順利，前途光明"
        ),
        LightLamp(
            lampType: .family,
            templeName: "台北行天宮",
            templeId: "temple_002",
            beneficiaryName: "闔家",
            duration: .oneYear,
            startDate: Date().addingTimeInterval(-60 * 60 * 24 * 30),
            purpose: "闔家平安健康"
        )
    ]
}
