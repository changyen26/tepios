/**
 * 用戶資料管理 ViewModel
 */

import Foundation
import SwiftUI
import Combine

class UserProfileViewModel: ObservableObject {
    // MARK: - Singleton

    static let shared = UserProfileViewModel()

    // MARK: - Published Properties

    @Published var user: User
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    // MARK: - Private Properties

    private let userDefaultsKey = "savedUser"

    // MARK: - Initialization

    init() {
        // 從 UserDefaults 載入用戶資料
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedUser = try? JSONDecoder().decode(User.self, from: savedData) {
            self.user = decodedUser
        } else {
            // 建立預設用戶
            self.user = User(
                profile: UserProfile(
                    name: "朝陽",
                    nickname: "信友",
                    email: "user@example.com"
                ),
                accountSettings: AccountSettings(
                    username: "user@example.com"
                ),
                cloudPassport: CloudPassport(
                    level: 5,
                    currentMeritPoints: 80,
                    totalMeritPoints: 580,
                    title: "初心信徒",
                    achievements: [
                        // 已解鎖的成就
                        PassportAchievement(
                            name: "初來乍到",
                            description: "完成第一次打卡",
                            iconName: "1.circle.fill",
                            category: .checkIn,
                            requirement: 1,
                            currentProgress: 1,
                            isUnlocked: true,
                            rewardPoints: 10
                        ),
                        PassportAchievement(
                            name: "打卡新手",
                            description: "累計打卡 10 次",
                            iconName: "10.circle.fill",
                            category: .checkIn,
                            requirement: 10,
                            currentProgress: 10,
                            isUnlocked: true,
                            rewardPoints: 50
                        ),
                        // 進行中的成就
                        PassportAchievement(
                            name: "打卡達人",
                            description: "累計打卡 50 次",
                            iconName: "50.circle.fill",
                            category: .checkIn,
                            requirement: 50,
                            currentProgress: 23,
                            isUnlocked: false,
                            rewardPoints: 200
                        ),
                        PassportAchievement(
                            name: "打卡宗師",
                            description: "累計打卡 100 次",
                            iconName: "100.circle.fill",
                            category: .checkIn,
                            requirement: 100,
                            currentProgress: 23,
                            isUnlocked: false,
                            rewardPoints: 500
                        ),
                        // 祈福成就
                        PassportAchievement(
                            name: "誠心祈福",
                            description: "完成 10 次祈福",
                            iconName: "hands.sparkles.fill",
                            category: .prayer,
                            requirement: 10,
                            currentProgress: 5,
                            isUnlocked: false,
                            rewardPoints: 50
                        ),
                        PassportAchievement(
                            name: "虔誠信徒",
                            description: "完成 50 次祈福",
                            iconName: "heart.fill",
                            category: .prayer,
                            requirement: 50,
                            currentProgress: 5,
                            isUnlocked: false,
                            rewardPoints: 200
                        ),
                        // 廟宇探訪成就
                        PassportAchievement(
                            name: "探索之旅",
                            description: "拜訪 5 間不同的廟宇",
                            iconName: "map.fill",
                            category: .temple,
                            requirement: 5,
                            currentProgress: 3,
                            isUnlocked: false,
                            rewardPoints: 100
                        ),
                        PassportAchievement(
                            name: "廟宇行者",
                            description: "拜訪 20 間不同的廟宇",
                            iconName: "location.fill",
                            category: .temple,
                            requirement: 20,
                            currentProgress: 3,
                            isUnlocked: false,
                            rewardPoints: 500
                        ),
                        // 連續打卡成就 - 已解鎖
                        PassportAchievement(
                            name: "持之以恆",
                            description: "連續打卡 7 天",
                            iconName: "7.circle.fill",
                            category: .streak,
                            requirement: 7,
                            currentProgress: 7,
                            isUnlocked: true,
                            rewardPoints: 100
                        ),
                        PassportAchievement(
                            name: "堅持不懈",
                            description: "連續打卡 30 天",
                            iconName: "30.circle.fill",
                            category: .streak,
                            requirement: 30,
                            currentProgress: 15,
                            isUnlocked: false,
                            rewardPoints: 500
                        ),
                        // 特殊成就 - 已解鎖
                        PassportAchievement(
                            name: "綁定平安符",
                            description: "綁定你的第一個平安符",
                            iconName: "tag.fill",
                            category: .special,
                            requirement: 1,
                            currentProgress: 1,
                            isUnlocked: true,
                            rewardPoints: 50
                        ),
                        PassportAchievement(
                            name: "信仰之路",
                            description: "選擇你的信仰神明",
                            iconName: "sparkles",
                            category: .special,
                            requirement: 1,
                            currentProgress: 1,
                            isUnlocked: true,
                            rewardPoints: 30
                        )
                    ],
                    visitedTemples: ["temple_001", "temple_002", "temple_003"],
                    checkInStreak: 15,
                    lastCheckInDate: Date()
                ),
                familyFriends: [
                    // 家人假資料
                    FamilyFriend(
                        userId: "user_001",
                        displayName: "王媽媽",
                        relationship: .family,
                        addedDate: Date().addingTimeInterval(-60 * 60 * 24 * 180) // 180天前
                    ),
                    FamilyFriend(
                        userId: "user_002",
                        displayName: "王爸爸",
                        relationship: .family,
                        addedDate: Date().addingTimeInterval(-60 * 60 * 24 * 180) // 180天前
                    ),
                    FamilyFriend(
                        userId: "user_003",
                        displayName: "王小華",
                        relationship: .family,
                        addedDate: Date().addingTimeInterval(-60 * 60 * 24 * 90) // 90天前
                    ),
                    // 好友假資料
                    FamilyFriend(
                        userId: "user_004",
                        displayName: "陳大明",
                        relationship: .friend,
                        addedDate: Date().addingTimeInterval(-60 * 60 * 24 * 60) // 60天前
                    ),
                    FamilyFriend(
                        userId: "user_005",
                        displayName: "李小美",
                        relationship: .friend,
                        addedDate: Date().addingTimeInterval(-60 * 60 * 24 * 45) // 45天前
                    ),
                    FamilyFriend(
                        userId: "user_006",
                        displayName: "張志明",
                        relationship: .friend,
                        addedDate: Date().addingTimeInterval(-60 * 60 * 24 * 30) // 30天前
                    ),
                    FamilyFriend(
                        userId: "user_007",
                        displayName: "林美玲",
                        relationship: .friend,
                        addedDate: Date().addingTimeInterval(-60 * 60 * 24 * 15) // 15天前
                    ),
                    FamilyFriend(
                        userId: "user_008",
                        displayName: "黃建國",
                        relationship: .friend,
                        addedDate: Date().addingTimeInterval(-60 * 60 * 24 * 7) // 7天前
                    )
                ],
                prayerRecords: [],
                amulets: [
                    // 預設平安符 1 - 受天宮
                    Amulet(
                        id: UUID().uuidString,
                        templeName: "受天宮",
                        templeId: "temple_001",
                        bindDate: Date().addingTimeInterval(-60 * 60 * 24 * 30), // 30天前
                        level: 3,
                        currentPoints: 45,
                        totalPoints: 245
                    ),
                    // 預設平安符 2 - 行天宮
                    Amulet(
                        id: UUID().uuidString,
                        templeName: "行天宮",
                        templeId: "temple_002",
                        bindDate: Date().addingTimeInterval(-60 * 60 * 24 * 15), // 15天前
                        level: 2,
                        currentPoints: 67,
                        totalPoints: 167
                    ),
                    // 預設平安符 3 - 指南宮
                    Amulet(
                        id: UUID().uuidString,
                        templeName: "指南宮",
                        templeId: "temple_003",
                        bindDate: Date().addingTimeInterval(-60 * 60 * 24 * 7), // 7天前
                        level: 1,
                        currentPoints: 23,
                        totalPoints: 23
                    )
                ],
                collectedCards: [
                    // 初始收集的卡牌 - 土地公（普通）
                    CollectedCard(
                        cardId: "card_006",
                        obtainMethod: .checkIn,
                        level: 3
                    ),
                    // 關聖帝君（傳說）
                    CollectedCard(
                        cardId: "card_001",
                        obtainMethod: .checkIn,
                        level: 2
                    ),
                    // 月下老人（稀有）
                    CollectedCard(
                        cardId: "card_004",
                        obtainMethod: .gacha,
                        level: 1
                    ),
                    // 媽祖（史詩）
                    CollectedCard(
                        cardId: "card_002",
                        obtainMethod: .checkIn,
                        level: 1
                    )
                ],
                eventRegistrations: [
                    // 已報名的活動範例
                    EventRegistration(
                        eventId: Event.mockEvents[0].id, // 新春祈福法會
                        eventTitle: Event.mockEvents[0].title,
                        userId: UUID().uuidString,
                        userName: "王曉明",
                        registrationDate: Date().addingTimeInterval(-60 * 60 * 24 * 3), // 3天前報名
                        status: .confirmed
                    )
                ],
                purchaseRecords: [
                    // 購買記錄範例
                    PurchaseRecord(
                        productId: Product.mockProducts[0].id,
                        productName: Product.mockProducts[0].name,
                        userId: UUID().uuidString,
                        userName: "王曉明",
                        purchaseDate: Date().addingTimeInterval(-60 * 60 * 24 * 7), // 7天前購買
                        quantity: 1,
                        paymentMethod: .cash,
                        totalPrice: 350,
                        status: .completed
                    ),
                    PurchaseRecord(
                        productId: Product.mockProducts[3].id,
                        productName: Product.mockProducts[3].name,
                        userId: UUID().uuidString,
                        userName: "王曉明",
                        purchaseDate: Date().addingTimeInterval(-60 * 60 * 24 * 5), // 5天前兌換
                        quantity: 2,
                        paymentMethod: .meritPoints,
                        totalPrice: 0,
                        meritPointsUsed: 160,
                        status: .completed
                    )
                ]
            )
        }
    }

    // MARK: - Public Methods

    /// 儲存用戶資料
    func saveUser() {
        isLoading = true
        errorMessage = nil

        // 模擬網路延遲
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }

            do {
                let encoded = try JSONEncoder().encode(self.user)
                UserDefaults.standard.set(encoded, forKey: self.userDefaultsKey)
                self.successMessage = "資料已成功儲存"
                self.isLoading = false
            } catch {
                self.errorMessage = "儲存失敗：\(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }

    /// 更新個人資料
    func updateProfile(
        name: String? = nil,
        nickname: String? = nil,
        birthday: Date? = nil,
        gender: Gender? = nil,
        phoneNumber: String? = nil,
        email: String? = nil,
        address: String? = nil,
        avatarData: Data? = nil,
        deityId: String? = nil
    ) {
        if let name = name {
            user.profile.name = name
        }
        if let nickname = nickname {
            user.profile.nickname = nickname
        }
        if let birthday = birthday {
            user.profile.birthday = birthday
        }
        if let gender = gender {
            user.profile.gender = gender
        }
        if let phoneNumber = phoneNumber {
            user.profile.phoneNumber = phoneNumber
        }
        if let email = email {
            user.profile.email = email
        }
        if let address = address {
            user.profile.address = address
        }
        if let avatarData = avatarData {
            user.profile.avatarData = avatarData
        }
        if deityId != nil {
            user.profile.deityId = deityId
        }

        saveUser()
    }

    /// 獲取當前選擇的神明
    func getCurrentDeity() -> Deity? {
        guard let deityId = user.profile.deityId else { return nil }
        return Deity.allDeities.first { $0.id == deityId }
    }

    /// 更新頭像
    func updateAvatar(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            errorMessage = "無法處理圖片"
            return
        }

        user.profile.avatarData = imageData
        saveUser()
    }

    /// 修改密碼
    func changePassword(oldPassword: String, newPassword: String, confirmPassword: String) -> Bool {
        // 驗證舊密碼
        let oldPasswordHash = AccountSettings.hashPassword(oldPassword)
        guard oldPasswordHash == user.accountSettings.passwordHash else {
            errorMessage = "舊密碼不正確"
            return false
        }

        // 驗證新密碼
        guard newPassword == confirmPassword else {
            errorMessage = "新密碼與確認密碼不一致"
            return false
        }

        // 驗證密碼強度
        let validation = AccountSettings.validatePassword(newPassword)
        guard validation.isValid else {
            errorMessage = validation.issues.first ?? "密碼不符合要求"
            return false
        }

        // 更新密碼
        user.accountSettings.passwordHash = AccountSettings.hashPassword(newPassword)
        saveUser()
        successMessage = "密碼已成功更新"
        return true
    }

    /// 驗證輸入格式
    func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    func validatePhoneNumber(_ phone: String) -> Bool {
        let phoneRegex = "^09[0-9]{8}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phone)
    }

    /// 清空提示訊息
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }

    /// 登出
    func logout() {
        // 清除用戶資料
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)

        // 重設為預設用戶
        self.user = User()
    }
}
