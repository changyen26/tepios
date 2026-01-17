/**
 * 用戶資料模型
 */

import Foundation

struct User: Codable, Identifiable {
    let id: String
    var profile: UserProfile
    var accountSettings: AccountSettings
    var statistics: UserStatistics
    var cloudPassport: CloudPassport
    var familyFriends: [FamilyFriend]
    var prayerRecords: [PrayerRecord]
    var amulets: [Amulet]
    var collectedCards: [CollectedCard] // 收集的神明卡牌
    var eventRegistrations: [EventRegistration]?
    var purchaseRecords: [PurchaseRecord]?

    init(
        id: String = UUID().uuidString,
        profile: UserProfile = UserProfile(),
        accountSettings: AccountSettings = AccountSettings(),
        statistics: UserStatistics = UserStatistics(),
        cloudPassport: CloudPassport = CloudPassport(),
        familyFriends: [FamilyFriend] = [],
        prayerRecords: [PrayerRecord] = [],
        amulets: [Amulet] = [],
        collectedCards: [CollectedCard] = [],
        eventRegistrations: [EventRegistration]? = nil,
        purchaseRecords: [PurchaseRecord]? = nil
    ) {
        self.id = id
        self.profile = profile
        self.accountSettings = accountSettings
        self.statistics = statistics
        self.cloudPassport = cloudPassport
        self.familyFriends = familyFriends
        self.prayerRecords = prayerRecords
        self.amulets = amulets
        self.collectedCards = collectedCards
        self.eventRegistrations = eventRegistrations
        self.purchaseRecords = purchaseRecords
    }
}

// MARK: - User Statistics

struct UserStatistics: Codable {
    var totalCheckIns: Int
    var totalPrayers: Int
    var totalPoints: Int
    var memberSince: Date
    var lastLoginDate: Date

    init(
        totalCheckIns: Int = 0,
        totalPrayers: Int = 0,
        totalPoints: Int = 0,
        memberSince: Date = Date(),
        lastLoginDate: Date = Date()
    ) {
        self.totalCheckIns = totalCheckIns
        self.totalPrayers = totalPrayers
        self.totalPoints = totalPoints
        self.memberSince = memberSince
        self.lastLoginDate = lastLoginDate
    }
}
