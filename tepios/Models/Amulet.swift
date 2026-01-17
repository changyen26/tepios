/**
 * 平安符資料模型
 */

import Foundation

struct Amulet: Codable, Identifiable {
    let id: String
    let templeName: String
    let templeId: String
    let bindDate: Date
    let level: Int
    let currentPoints: Int
    let totalPoints: Int

    var maxPoints: Int {
        // 每級需要 100 點經驗值
        return 100
    }

    var levelTitle: String {
        switch level {
        case 1: return "初階信徒"
        case 2: return "虔誠信徒"
        case 3: return "忠實信徒"
        case 4: return "資深信徒"
        case 5: return "德高望重"
        default: return "信徒"
        }
    }
}

struct AmuletBindRequest: Codable {
    let qrCode: String
    let userId: String
}

struct AmuletBindResponse: Codable {
    let success: Bool
    let message: String
    let amulet: Amulet?
}
