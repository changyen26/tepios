//
//  APIModels.swift
//  tepios
//
//  API 資料模型
//

import Foundation

// MARK: - 通用 API 回應
struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let message: String
    let data: T?
}

// MARK: - 登入相關
struct LoginData: Decodable {
    let user: APIUser
    let token: String
    let accountType: String

    enum CodingKeys: String, CodingKey {
        case user, token
        case accountType = "account_type"
    }
}

struct APIUser: Decodable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let blessingPoints: Int
    let isActive: Bool
    let createdAt: String?
    let lastLoginAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, email
        case blessingPoints = "blessing_points"
        case isActive = "is_active"
        case createdAt = "created_at"
        case lastLoginAt = "last_login_at"
    }
}

struct LoginResponse {
    let user: APIUser
    let token: String
}

// MARK: - 廟宇相關
struct TemplesData: Decodable {
    let temples: [APITemple]
    let total: Int?
    let limit: Int?
    let offset: Int?
}

struct NearbyTemplesData: Decodable {
    let temples: [APITemple]
    let count: Int?
    let searchCenter: SearchCenter?
    let radius: Double?

    enum CodingKeys: String, CodingKey {
        case temples, count, radius
        case searchCenter = "search_center"
    }
}

struct SearchCenter: Decodable {
    let latitude: Double
    let longitude: Double
}

struct APITemple: Decodable, Identifiable {
    let id: Int
    let name: String
    let address: String?
    let latitude: Double?
    let longitude: Double?
    let mainDeity: String?
    let description: String?
    let phone: String?
    let email: String?
    let website: String?
    let images: [String]?
    let openingHours: [String: String]?
    let checkinRadius: Int?
    let checkinMeritPoints: Int?
    let nfcUid: String?
    let isActive: Bool?
    var distance: Double?  // 附近廟宇時會有

    enum CodingKeys: String, CodingKey {
        case id, name, address, latitude, longitude, description, phone, email, website, images, distance
        case mainDeity = "main_deity"
        case openingHours = "opening_hours"
        case checkinRadius = "checkin_radius"
        case checkinMeritPoints = "checkin_merit_points"
        case nfcUid = "nfc_uid"
        case isActive = "is_active"
    }
}

// MARK: - 打卡相關
struct CheckinData: Decodable {
    let checkin: CheckinInfo
    let amulet: AmuletInfo?
    let blessingPointsGained: Int
    let currentBlessingPoints: Int
    let temple: APITemple?

    enum CodingKeys: String, CodingKey {
        case checkin, amulet, temple
        case blessingPointsGained = "blessing_points_gained"
        case currentBlessingPoints = "current_blessing_points"
    }
}

struct CheckinInfo: Decodable, Identifiable {
    let id: Int
    let userId: Int?
    let amuletId: Int?
    let templeId: Int?
    let templeName: String?
    let latitude: Double?
    let longitude: Double?
    let notes: String?
    let blessingPoints: Int
    let timestamp: String

    enum CodingKeys: String, CodingKey {
        case id, latitude, longitude, notes, timestamp
        case userId = "user_id"
        case amuletId = "amulet_id"
        case templeId = "temple_id"
        case templeName = "temple_name"
        case blessingPoints = "blessing_points"
    }
}

struct AmuletInfo: Decodable {
    let id: Int
    let energy: Int
}

struct CheckinResponse {
    let checkinId: Int
    let templeName: String
    let blessingPointsGained: Int
    let currentBlessingPoints: Int
    let message: String
}

// MARK: - 護身符相關
struct AmuletsData: Decodable {
    let amulets: [APIAmulet]?
    let count: Int?
}

struct APIAmulet: Decodable, Identifiable {
    let id: Int
    let userId: Int
    let energy: Int
    let status: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, energy, status
        case userId = "user_id"
        case createdAt = "created_at"
    }
}

// MARK: - QR Code 解析
struct QRCodeContent {
    let type: String
    let templeId: Int?

    // 解析 QR Code 內容
    // 格式: "temple:25"
    static func parse(_ content: String) -> QRCodeContent? {
        let parts = content.split(separator: ":")
        guard parts.count == 2 else { return nil }

        let type = String(parts[0])
        let value = String(parts[1])

        if type == "temple", let templeId = Int(value) {
            return QRCodeContent(type: type, templeId: templeId)
        }

        return nil
    }
}
