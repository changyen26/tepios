/**
 * 神明派系模型
 */

import Foundation

struct Deity: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let displayName: String
    let description: String
    let iconName: String
    let color: String // Hex color code
    let attributes: [String]

    init(
        id: String,
        name: String,
        displayName: String,
        description: String,
        iconName: String,
        color: String,
        attributes: [String] = []
    ) {
        self.id = id
        self.name = name
        self.displayName = displayName
        self.description = description
        self.iconName = iconName
        self.color = color
        self.attributes = attributes
    }
}

// MARK: - Predefined Deities

extension Deity {
    static let xuanTian = Deity(
        id: "xuantian",
        name: "玄天上帝",
        displayName: "玄天上帝",
        description: "北極玄天上帝，掌管北方，主司武功、驅邪鎮煞，護佑眾生平安",
        iconName: "shield.fill",
        color: "#1E3A8A", // 深藍色
        attributes: ["武功", "驅邪", "護佑"]
    )

    static let mazu = Deity(
        id: "mazu",
        name: "媽祖",
        displayName: "天上聖母",
        description: "天上聖母媽祖，海上守護神，庇佑航海平安，慈悲濟世",
        iconName: "water.waves",
        color: "#DC2626", // 紅色
        attributes: ["航海", "平安", "慈悲"]
    )

    static let guanGong = Deity(
        id: "guangong",
        name: "關公",
        displayName: "關聖帝君",
        description: "關聖帝君，忠義仁勇，主司正義與財富，護佑商旅平安",
        iconName: "figure.martial.arts",
        color: "#DC2626", // 紅色
        attributes: ["忠義", "正義", "財富"]
    )

    static let guanyin = Deity(
        id: "guanyin",
        name: "觀音",
        displayName: "觀世音菩薩",
        description: "觀世音菩薩，大慈大悲，救苦救難，聞聲救苦，普渡眾生",
        iconName: "hands.sparkles",
        color: "#F59E0B", // 金色
        attributes: ["慈悲", "救苦", "普渡"]
    )

    static let tuDiGong = Deity(
        id: "tudigong",
        name: "土地公",
        displayName: "福德正神",
        description: "福德正神土地公，守護鄉里，庇佑五穀豐收，財源廣進",
        iconName: "house.fill",
        color: "#D97706", // 褐色
        attributes: ["守護", "豐收", "財運"]
    )

    static let wenchang = Deity(
        id: "wenchang",
        name: "文昌帝君",
        displayName: "文昌帝君",
        description: "文昌帝君，主司功名利祿，庇佑學業進步，助學子金榜題名",
        iconName: "book.fill",
        color: "#059669", // 綠色
        attributes: ["功名", "學業", "智慧"]
    )

    static let sanGuan = Deity(
        id: "sanguan",
        name: "三官大帝",
        displayName: "三官大帝",
        description: "三官大帝為天官、地官、水官，天官賜福、地官赦罪、水官解厄，庇佑眾生福祿壽喜",
        iconName: "sparkles",
        color: "#7C3AED", // 紫色
        attributes: ["賜福", "赦罪", "解厄"]
    )

    // 所有預設神明列表
    static let allDeities: [Deity] = [
        xuanTian,
        mazu,
        guanGong,
        guanyin,
        tuDiGong,
        wenchang,
        sanGuan
    ]
}
