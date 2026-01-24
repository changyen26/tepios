//
//  APIConfig.swift
//  tepios
//
//  API 設定檔
//

import Foundation

struct APIConfig {
    // ⚠️ 請改成您電腦的 IP 位址
    // 可在終端機執行 ipconfig 查看
    static let baseURL = "http://192.168.254.48:5000/api"

    // 測試用護身符 ID（登入後應從 API 取得）
    static let testAmuletId = 3

    // API 端點
    struct Endpoints {
        static let login = "/auth/login"
        static let register = "/auth/register"
        static let me = "/auth/me"
        static let changePassword = "/auth/change-password"
        static let temples = "/temples"
        static let nearbyTemples = "/temples/nearby"
        static let products = "/products"
        static let amulets = "/amulets"
        static let redemptions = "/redemptions"
    }

    // 打卡端點（需要 temple_id）
    static func checkinURL(templeId: Int) -> String {
        return "\(baseURL)/temples/\(templeId)/checkin"
    }

    // 廟宇詳情端點
    static func templeDetailURL(templeId: Int) -> String {
        return "\(baseURL)/temples/\(templeId)"
    }
}
