/**
 * 用戶個人資料模型
 */

import Foundation
import UIKit

struct UserProfile: Codable {
    var name: String
    var nickname: String
    var birthday: Date?
    var gender: Gender
    var phoneNumber: String
    var email: String
    var address: String // 地址
    var avatarData: Data?
    var deityId: String? // 所信奉的神明ID

    init(
        name: String = "",
        nickname: String = "",
        birthday: Date? = nil,
        gender: Gender = .notSpecified,
        phoneNumber: String = "",
        email: String = "",
        address: String = "",
        avatarData: Data? = nil,
        deityId: String? = nil
    ) {
        self.name = name
        self.nickname = nickname
        self.birthday = birthday
        self.gender = gender
        self.phoneNumber = phoneNumber
        self.email = email
        self.address = address
        self.avatarData = avatarData
        self.deityId = deityId
    }

    // MARK: - Computed Properties

    var avatar: UIImage? {
        guard let data = avatarData else { return nil }
        return UIImage(data: data)
    }

    var age: Int? {
        guard let birthday = birthday else { return nil }
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: Date())
        return ageComponents.year
    }

    var formattedBirthday: String {
        guard let birthday = birthday else { return "未設定" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        formatter.locale = Locale(identifier: "zh_TW")
        return formatter.string(from: birthday)
    }
}

// MARK: - Gender Enum

enum Gender: String, Codable, CaseIterable {
    case male = "男性"
    case female = "女性"
    case other = "其他"
    case notSpecified = "不指定"

    var icon: String {
        switch self {
        case .male:
            return "person.fill"
        case .female:
            return "person.fill"
        case .other:
            return "person.fill"
        case .notSpecified:
            return "person.fill.questionmark"
        }
    }
}
