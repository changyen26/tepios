/**
 * 帳號設定模型
 */

import Foundation

struct AccountSettings: Codable {
    var username: String
    var passwordHash: String
    var isTwoFactorEnabled: Bool
    var notificationsEnabled: Bool
    var emailNotificationsEnabled: Bool

    init(
        username: String = "",
        passwordHash: String = "",
        isTwoFactorEnabled: Bool = false,
        notificationsEnabled: Bool = true,
        emailNotificationsEnabled: Bool = true
    ) {
        self.username = username
        self.passwordHash = passwordHash
        self.isTwoFactorEnabled = isTwoFactorEnabled
        self.notificationsEnabled = notificationsEnabled
        self.emailNotificationsEnabled = emailNotificationsEnabled
    }

    // MARK: - Password Validation

    static func validatePassword(_ password: String) -> PasswordValidation {
        var issues: [String] = []

        if password.count < 8 {
            issues.append("密碼長度至少需要 8 個字元")
        }

        let hasUppercase = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasLowercase = password.range(of: "[a-z]", options: .regularExpression) != nil
        let hasNumber = password.range(of: "[0-9]", options: .regularExpression) != nil

        if !hasUppercase {
            issues.append("需包含至少一個大寫字母")
        }

        if !hasLowercase {
            issues.append("需包含至少一個小寫字母")
        }

        if !hasNumber {
            issues.append("需包含至少一個數字")
        }

        let strength: PasswordStrength
        if issues.isEmpty {
            strength = .strong
        } else if issues.count <= 2 {
            strength = .medium
        } else {
            strength = .weak
        }

        return PasswordValidation(strength: strength, issues: issues)
    }

    static func hashPassword(_ password: String) -> String {
        // 簡單的雜湊（實際應用中應使用 bcrypt 或類似的安全雜湊）
        // 這裡僅用於示範
        return password.data(using: .utf8)?.base64EncodedString() ?? ""
    }
}

// MARK: - Password Validation

struct PasswordValidation {
    let strength: PasswordStrength
    let issues: [String]

    var isValid: Bool {
        return issues.isEmpty
    }
}

enum PasswordStrength: String {
    case weak = "弱"
    case medium = "中等"
    case strong = "強"

    var color: String {
        switch self {
        case .weak:
            return "red"
        case .medium:
            return "orange"
        case .strong:
            return "green"
        }
    }
}
