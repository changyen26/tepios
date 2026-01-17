/**
 * 家人好友數據模型
 */

import Foundation

// MARK: - Family Friend

struct FamilyFriend: Codable, Identifiable {
    let id: String
    var userId: String           // 對方的用戶 ID
    var displayName: String      // 顯示名稱
    var avatarData: Data?        // 頭像
    var relationship: Relationship  // 關係類型
    var addedDate: Date          // 添加日期

    init(
        id: String = UUID().uuidString,
        userId: String,
        displayName: String,
        avatarData: Data? = nil,
        relationship: Relationship,
        addedDate: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.displayName = displayName
        self.avatarData = avatarData
        self.relationship = relationship
        self.addedDate = addedDate
    }
}

// MARK: - Relationship

enum Relationship: String, Codable, CaseIterable {
    case family = "家人"
    case friend = "好友"

    var iconName: String {
        switch self {
        case .family: return "person.2.fill"
        case .friend: return "person.fill"
        }
    }

    var color: String {
        switch self {
        case .family: return "#EF4444"  // 紅色代表家人
        case .friend: return "#3B82F6"  // 藍色代表好友
        }
    }
}

// MARK: - Prayer Record

struct PrayerRecord: Codable, Identifiable {
    let id: String
    var fromUserId: String       // 祈福者 ID
    var fromUserName: String     // 祈福者名稱
    var toUserId: String         // 接受者 ID
    var toUserName: String       // 接受者名稱
    var message: String?         // 祝福留言
    var meritPoints: Int         // 福報值
    var createdDate: Date        // 創建日期

    init(
        id: String = UUID().uuidString,
        fromUserId: String,
        fromUserName: String,
        toUserId: String,
        toUserName: String,
        message: String? = nil,
        meritPoints: Int = 20,
        createdDate: Date = Date()
    ) {
        self.id = id
        self.fromUserId = fromUserId
        self.fromUserName = fromUserName
        self.toUserId = toUserId
        self.toUserName = toUserName
        self.message = message
        self.meritPoints = meritPoints
        self.createdDate = createdDate
    }
}

// MARK: - User QR Code Data

struct UserQRCodeData: Codable {
    let userId: String
    let displayName: String
    let createdDate: Date

    var qrCodeString: String {
        // 生成 QR Code 的字串格式：tepios://user/{userId}
        return "tepios://user/\(userId)"
    }

    init(userId: String, displayName: String) {
        self.userId = userId
        self.displayName = displayName
        self.createdDate = Date()
    }
}
