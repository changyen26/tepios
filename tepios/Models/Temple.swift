/**
 * 廟宇資料模型
 */

import Foundation
import CoreLocation

// MARK: - Temple Model

struct Temple: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var description: String
    var address: String
    var phoneNumber: String
    var latitude: Double
    var longitude: Double
    var deity: Deity // 主祀神明
    var openingHours: OpeningHours
    var images: [String] // 圖片 URL 或本地路徑
    var introduction: String // 詳細介紹
    var history: String // 歷史沿革
    var features: [String] // 特色標籤
    var checkInRadius: Double // 打卡範圍（公尺）
    var blessPoints: Int // 祈福基礎福報值

    init(
        id: String = UUID().uuidString,
        name: String,
        description: String,
        address: String,
        phoneNumber: String = "",
        latitude: Double,
        longitude: Double,
        deity: Deity = Deity.mazu,
        openingHours: OpeningHours = OpeningHours(),
        images: [String] = [],
        introduction: String = "",
        history: String = "",
        features: [String] = [],
        checkInRadius: Double = 100.0,
        blessPoints: Int = 10
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.address = address
        self.phoneNumber = phoneNumber
        self.latitude = latitude
        self.longitude = longitude
        self.deity = deity
        self.openingHours = openingHours
        self.images = images
        self.introduction = introduction
        self.history = history
        self.features = features
        self.checkInRadius = checkInRadius
        self.blessPoints = blessPoints
    }

    // MARK: - Computed Properties

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }

    // 計算與指定位置的距離
    func distance(from location: CLLocation) -> Double {
        self.location.distance(from: location)
    }

    // 判斷是否在打卡範圍內
    func isInCheckInRange(from location: CLLocation) -> Bool {
        distance(from: location) <= checkInRadius
    }

    static func == (lhs: Temple, rhs: Temple) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Opening Hours

struct OpeningHours: Codable, Equatable {
    var weekdayStart: String // 平日開始時間
    var weekdayEnd: String // 平日結束時間
    var weekendStart: String // 假日開始時間
    var weekendEnd: String // 假日結束時間
    var isAlwaysOpen: Bool // 是否24小時開放
    var specialNotes: String // 特別說明

    init(
        weekdayStart: String = "06:00",
        weekdayEnd: String = "21:00",
        weekendStart: String = "06:00",
        weekendEnd: String = "21:00",
        isAlwaysOpen: Bool = false,
        specialNotes: String = ""
    ) {
        self.weekdayStart = weekdayStart
        self.weekdayEnd = weekdayEnd
        self.weekendStart = weekendStart
        self.weekendEnd = weekendEnd
        self.isAlwaysOpen = isAlwaysOpen
        self.specialNotes = specialNotes
    }

    var displayText: String {
        if isAlwaysOpen {
            return "24小時開放"
        } else {
            return "平日 \(weekdayStart) - \(weekdayEnd)\n假日 \(weekendStart) - \(weekendEnd)"
        }
    }

    // 判斷現在是否開放
    func isOpenNow() -> Bool {
        if isAlwaysOpen {
            return true
        }

        let now = Date()
        let calendar = Calendar.current
        let isWeekend = calendar.isDateInWeekend(now)

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let currentTime = formatter.string(from: now)

        let start = isWeekend ? weekendStart : weekdayStart
        let end = isWeekend ? weekendEnd : weekdayEnd

        return currentTime >= start && currentTime <= end
    }
}

// MARK: - Mock Data

extension Temple {
    static let mockTemples: [Temple] = [
        Temple(
            name: "台北行天宮",
            description: "主祀關聖帝君，香火鼎盛",
            address: "台北市中山區民權東路二段109號",
            phoneNumber: "02-2502-7924",
            latitude: 25.0630,
            longitude: 121.5334,
            deity: Deity.guanGong,
            openingHours: OpeningHours(
                weekdayStart: "04:00",
                weekdayEnd: "22:00",
                weekendStart: "04:00",
                weekendEnd: "22:00"
            ),
            images: ["temple_xingtian"],
            introduction: "行天宮，又稱恩主公廟，是台北市著名的廟宇之一，主要供奉關聖帝君。",
            history: "創建於民國46年（1957年），由玄空師父倡建。",
            features: ["無香廟宇", "靈驗著稱", "人文教育", "公益活動"],
            checkInRadius: 50.0,
            blessPoints: 15
        ),
        Temple(
            name: "龍山寺",
            description: "台北最古老的寺廟之一",
            address: "台北市萬華區廣州街211號",
            phoneNumber: "02-2302-5162",
            latitude: 25.0370,
            longitude: 121.5000,
            deity: Deity.guanyin,
            openingHours: OpeningHours(
                weekdayStart: "06:00",
                weekdayEnd: "22:00",
                weekendStart: "06:00",
                weekendEnd: "22:00"
            ),
            images: ["temple_longshan"],
            introduction: "艋舺龍山寺，為台北市著名古蹟，主祀觀世音菩薩。",
            history: "建於清乾隆三年（1738年），至今已有近300年歷史。",
            features: ["國定古蹟", "建築藝術", "多神信仰", "求籤靈驗"],
            checkInRadius: 50.0,
            blessPoints: 20
        ),
        Temple(
            name: "北港朝天宮",
            description: "台灣媽祖信仰重鎮",
            address: "雲林縣北港鎮中山路178號",
            phoneNumber: "05-783-2055",
            latitude: 23.5743,
            longitude: 120.3009,
            deity: Deity.mazu,
            openingHours: OpeningHours(
                weekdayStart: "05:00",
                weekdayEnd: "23:00",
                weekendStart: "05:00",
                weekendEnd: "23:00"
            ),
            introduction: "北港朝天宮，俗稱北港媽祖廟，為台灣媽祖信仰的重要廟宇。",
            history: "創建於清康熙三十三年（1694年），香火鼎盛300餘年。",
            features: ["國定古蹟", "繞境文化", "宗教中心", "建築精美"],
            checkInRadius: 100.0,
            blessPoints: 25
        ),
        Temple(
            name: "大甲鎮瀾宮",
            description: "台灣媽祖進香重鎮",
            address: "台中市大甲區順天路158號",
            phoneNumber: "04-2676-3522",
            latitude: 24.3477,
            longitude: 120.6229,
            deity: Deity.mazu,
            openingHours: OpeningHours(
                isAlwaysOpen: true
            ),
            introduction: "大甲鎮瀾宮，主祀天上聖母媽祖，以大甲媽祖遶境進香活動聞名。",
            history: "創建於清乾隆三十五年（1770年），是台灣重要的媽祖廟之一。",
            features: ["遶境文化", "香火鼎盛", "建築藝術", "24小時開放"],
            checkInRadius: 100.0,
            blessPoints: 25
        ),
        Temple(
            name: "文昌宮",
            description: "求學業功名的聖地",
            address: "台北市大同區重慶北路三段270號",
            phoneNumber: "02-2585-6965",
            latitude: 25.0710,
            longitude: 121.5135,
            deity: Deity.wenchang,
            openingHours: OpeningHours(
                weekdayStart: "07:00",
                weekdayEnd: "20:00",
                weekendStart: "07:00",
                weekendEnd: "20:00"
            ),
            introduction: "文昌宮主祀文昌帝君，為莘莘學子祈求功名、學業進步的聖地。",
            history: "創建於民國初年，香火綿延至今。",
            features: ["求學業", "考試順利", "文運昌隆", "靈驗著稱"],
            checkInRadius: 50.0,
            blessPoints: 12
        ),
        Temple(
            name: "南投受天宮",
            description: "台灣玄天上帝信仰總本山",
            address: "南投縣名間鄉松山村松山街118號",
            phoneNumber: "049-258-1008",
            latitude: 23.83183,
            longitude: 120.63094,
            deity: Deity.xuanTian,
            openingHours: OpeningHours(
                weekdayStart: "05:00",
                weekdayEnd: "21:30",
                weekendStart: "05:00",
                weekendEnd: "21:30"
            ),
            images: ["temple_shoutian"],
            introduction: "南投受天宮，俗稱松柏嶺受天宮，為台灣玄天上帝信仰的總本山，香火鼎盛，信徒遍布全台。",
            history: "創建於清順治十四年（1657年），距今已有360餘年歷史，是台灣最古老的玄天上帝廟宇之一。",
            features: ["玄天上帝總廟", "國家三級古蹟", "建築宏偉", "靈驗著稱"],
            checkInRadius: 100.0,
            blessPoints: 30
        )
    ]
}
