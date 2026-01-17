/**
 * 產品特色資料模型
 * 用於官網展示和產品介紹
 */

import Foundation
import SwiftUI

// MARK: - Product Feature

struct ProductFeature: Identifiable {
    let id = UUID()
    let iconName: String
    let title: String
    let description: String
    let color: Color
    let gradientColors: [Color]

    init(
        iconName: String,
        title: String,
        description: String,
        color: Color,
        gradientColors: [Color]? = nil
    ) {
        self.iconName = iconName
        self.title = title
        self.description = description
        self.color = color
        self.gradientColors = gradientColors ?? [color, color.opacity(0.7)]
    }
}

// MARK: - Mock Features

extension ProductFeature {
    static let features: [ProductFeature] = [
        ProductFeature(
            iconName: "qrcode.viewfinder",
            title: "QR Code 打卡",
            description: "持平安符至廟宇過爐打卡或掃描廟宇專屬 QR Code，輕鬆完成打卡，記錄您的參拜足跡，累積福報值。",
            color: AppTheme.gold,
            gradientColors: [AppTheme.gold, Color(hex: "#D4B756")]
        ),
        ProductFeature(
            iconName: "scroll.fill",
            title: "平安符管理",
            description: "數位化管理您的平安符，記錄綁定日期、累積福報值，隨時查看您的守護力量。",
            color: Color(hex: "#10B981"),
            gradientColors: [Color(hex: "#10B981"), Color(hex: "#059669")]
        ),
        ProductFeature(
            iconName: "calendar.badge.clock",
            title: "廟宇活動報名",
            description: "即時掌握廟宇活動資訊，線上報名法會、講座、志工服務等各類活動。",
            color: Color(hex: "#3B82F6"),
            gradientColors: [Color(hex: "#3B82F6"), Color(hex: "#2563EB")]
        ),
        ProductFeature(
            iconName: "sparkles",
            title: "福報值系統",
            description: "透過打卡、祈福、參加活動累積福報值，提升等級解鎖專屬稱號和獎勵。",
            color: Color(hex: "#F59E0B"),
            gradientColors: [Color(hex: "#F59E0B"), Color(hex: "#D97706")]
        ),
        ProductFeature(
            iconName: "bag.fill",
            title: "福報商城",
            description: "使用福報值兌換文創商品、祈福用品、經書典籍等精選好物。",
            color: Color(hex: "#EC4899"),
            gradientColors: [Color(hex: "#EC4899"), Color(hex: "#DB2777")]
        ),
        ProductFeature(
            iconName: "star.fill",
            title: "成就系統",
            description: "完成各類挑戰解鎖成就徽章，展現您的信仰歷程，分享給親朋好友。",
            color: Color(hex: "#8B5CF6"),
            gradientColors: [Color(hex: "#8B5CF6"), Color(hex: "#7C3AED")]
        ),
        ProductFeature(
            iconName: "map.fill",
            title: "廟宇地圖",
            description: "探索周邊廟宇，查看廟宇資訊、活動、交通指引，規劃您的參拜之旅。",
            color: Color(hex: "#06B6D4"),
            gradientColors: [Color(hex: "#06B6D4"), Color(hex: "#0891B2")]
        ),
        ProductFeature(
            iconName: "person.2.fill",
            title: "代為祈福",
            description: "為親友代禱祈福，傳遞祝福與關懷，讓愛與祝福跨越距離。",
            color: Color(hex: "#EF4444"),
            gradientColors: [Color(hex: "#EF4444"), Color(hex: "#DC2626")]
        )
    ]
}
