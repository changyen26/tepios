/**
 * 商品資料模型
 */

import Foundation

// MARK: - Product

struct Product: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let imageUrl: String?
    let category: ProductCategory
    let price: Int // 現金價格（0 表示僅限兌換）
    let meritPointsPrice: Int? // 福報值兌換價格（nil 表示不可兌換）
    let stock: Int
    let isAvailable: Bool
    let tags: [String]
    let templeId: String? // 關聯廟宇 ID
    let templeName: String? // 關聯廟宇名稱

    init(
        id: String = UUID().uuidString,
        name: String,
        description: String,
        imageUrl: String? = nil,
        category: ProductCategory,
        price: Int = 0,
        meritPointsPrice: Int? = nil,
        stock: Int = 0,
        isAvailable: Bool = true,
        tags: [String] = [],
        templeId: String? = nil,
        templeName: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.imageUrl = imageUrl
        self.category = category
        self.price = price
        self.meritPointsPrice = meritPointsPrice
        self.stock = stock
        self.isAvailable = isAvailable
        self.tags = tags
        self.templeId = templeId
        self.templeName = templeName
    }

    /// 是否有庫存
    var inStock: Bool {
        return stock > 0
    }

    /// 是否可購買
    var canPurchase: Bool {
        return isAvailable && inStock && price > 0
    }

    /// 是否可兌換
    var canRedeem: Bool {
        return isAvailable && inStock && meritPointsPrice != nil
    }

    /// 購買方式文字
    var purchaseOptionsText: String {
        if canPurchase && canRedeem {
            return "可購買或兌換"
        } else if canPurchase {
            return "現金購買"
        } else if canRedeem {
            return "福報值兌換"
        } else {
            return "暫不可購買"
        }
    }
}

// MARK: - Product Category

enum ProductCategory: String, Codable, CaseIterable {
    case cultural = "文創商品"
    case blessing = "祈福用品"
    case souvenir = "廟宇紀念品"
    case amulet = "平安符周邊"
    case limited = "限定商品"
    case book = "經書典籍"

    var iconName: String {
        switch self {
        case .cultural: return "paintpalette.fill"
        case .blessing: return "hands.sparkles.fill"
        case .souvenir: return "gift.fill"
        case .amulet: return "scroll.fill"
        case .limited: return "star.fill"
        case .book: return "book.fill"
        }
    }

    var color: String {
        switch self {
        case .cultural: return "#EC4899"
        case .blessing: return "#F59E0B"
        case .souvenir: return "#3B82F6"
        case .amulet: return "#10B981"
        case .limited: return "#EF4444"
        case .book: return "#8B5CF6"
        }
    }
}

// MARK: - Purchase Record

struct PurchaseRecord: Codable, Identifiable {
    let id: String
    let productId: String
    let productName: String
    let userId: String
    let userName: String
    let purchaseDate: Date
    let quantity: Int
    let paymentMethod: PaymentMethod
    let totalPrice: Int // 實際支付金額
    let meritPointsUsed: Int // 使用的福報值
    let status: PurchaseStatus
    let shippingAddress: String?
    let notes: String?

    init(
        id: String = UUID().uuidString,
        productId: String,
        productName: String,
        userId: String,
        userName: String,
        purchaseDate: Date = Date(),
        quantity: Int = 1,
        paymentMethod: PaymentMethod,
        totalPrice: Int,
        meritPointsUsed: Int = 0,
        status: PurchaseStatus = .pending,
        shippingAddress: String? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.productId = productId
        self.productName = productName
        self.userId = userId
        self.userName = userName
        self.purchaseDate = purchaseDate
        self.quantity = quantity
        self.paymentMethod = paymentMethod
        self.totalPrice = totalPrice
        self.meritPointsUsed = meritPointsUsed
        self.status = status
        self.shippingAddress = shippingAddress
        self.notes = notes
    }
}

// MARK: - Payment Method

enum PaymentMethod: String, Codable {
    case cash = "現金購買"
    case meritPoints = "福報值兌換"

    var iconName: String {
        switch self {
        case .cash: return "dollarsign.circle.fill"
        case .meritPoints: return "sparkles"
        }
    }

    var color: String {
        switch self {
        case .cash: return "#10B981"
        case .meritPoints: return "#F59E0B"
        }
    }
}

// MARK: - Purchase Status

enum PurchaseStatus: String, Codable {
    case pending = "待付款"
    case paid = "已付款"
    case shipped = "已出貨"
    case completed = "已完成"
    case cancelled = "已取消"

    var color: String {
        switch self {
        case .pending: return "#F59E0B"
        case .paid: return "#3B82F6"
        case .shipped: return "#8B5CF6"
        case .completed: return "#10B981"
        case .cancelled: return "#6B7280"
        }
    }
}

// MARK: - Mock Products

extension Product {
    static let mockProducts: [Product] = [
        // 文創商品
        Product(
            name: "龍山寺紀念馬克杯",
            description: "精美陶瓷馬克杯，印有艋舺龍山寺經典建築圖樣，適合收藏或日常使用。",
            category: .cultural,
            price: 350,
            meritPointsPrice: 200,
            stock: 50,
            tags: ["熱門", "龍山寺"],
            templeId: "temple_001",
            templeName: "艋舺龍山寺"
        ),
        Product(
            name: "行天宮典藏筆記本",
            description: "精裝筆記本，封面採用行天宮特色圖騰設計，內頁使用環保紙張。",
            category: .cultural,
            price: 280,
            meritPointsPrice: 150,
            stock: 100,
            tags: ["文具", "行天宮"],
            templeId: "temple_002",
            templeName: "行天宮"
        ),
        Product(
            name: "廟宇建築明信片組",
            description: "12張一組，收錄台灣知名廟宇建築攝影作品，附贈精美收藏盒。",
            category: .cultural,
            price: 180,
            meritPointsPrice: 100,
            stock: 80,
            tags: ["明信片", "收藏"]
        ),

        // 祈福用品
        Product(
            name: "平安香包",
            description: "手工縫製香包，內含天然香料，可隨身攜帶或掛於車內，祈求平安順利。",
            category: .blessing,
            price: 150,
            meritPointsPrice: 80,
            stock: 200,
            tags: ["熱門", "平安"]
        ),
        Product(
            name: "祈福吊飾",
            description: "精緻金屬吊飾，可掛於包包或鑰匙圈，象徵神明庇佑、出入平安。",
            category: .blessing,
            price: 200,
            meritPointsPrice: 120,
            stock: 150,
            tags: ["吊飾", "平安"]
        ),
        Product(
            name: "開運手環",
            description: "天然水晶手環，搭配開運寶石，祈求好運連連、事事順心。",
            category: .blessing,
            price: 500,
            meritPointsPrice: 300,
            stock: 60,
            tags: ["開運", "水晶"]
        ),

        // 廟宇紀念品
        Product(
            name: "媽祖文化T恤",
            description: "純棉材質，印有媽祖文化創意圖樣，舒適透氣，展現台灣信仰文化。",
            category: .souvenir,
            price: 480,
            meritPointsPrice: 280,
            stock: 120,
            tags: ["服飾", "媽祖"]
        ),
        Product(
            name: "關聖帝君書籤",
            description: "金屬鏤空書籤，雕刻關聖帝君形象，精緻典雅，適合愛書人收藏。",
            category: .souvenir,
            price: 120,
            meritPointsPrice: 60,
            stock: 180,
            tags: ["書籤", "關聖帝君"]
        ),

        // 平安符周邊
        Product(
            name: "平安符收納袋",
            description: "絨布材質收納袋，專為平安符設計，可妥善保護您的平安符。",
            category: .amulet,
            price: 100,
            meritPointsPrice: 50,
            stock: 250,
            tags: ["周邊", "收納"]
        ),
        Product(
            name: "平安符展示框",
            description: "木質展示框，可將平安符裱框展示，兼具保護與裝飾功能。",
            category: .amulet,
            price: 380,
            meritPointsPrice: 220,
            stock: 40,
            tags: ["周邊", "展示"]
        ),

        // 限定商品
        Product(
            name: "龍年限定紅包袋",
            description: "龍年特別版紅包袋，10入一組，精美燙金設計，送禮自用兩相宜。",
            category: .limited,
            price: 150,
            stock: 500,
            tags: ["限定", "龍年", "熱門"]
        ),
        Product(
            name: "新春福袋",
            description: "新春特別企劃福袋，內含多項精選商品，總值超過千元，限量發售。",
            category: .limited,
            price: 688,
            stock: 30,
            tags: ["限定", "福袋", "新春"]
        ),

        // 經書典籍
        Product(
            name: "心經抄寫本",
            description: "精裝抄寫本，內含心經原文與解說，適合靜心抄寫修行。",
            category: .book,
            price: 0,
            meritPointsPrice: 100,
            stock: 150,
            tags: ["經書", "抄寫"]
        ),
        Product(
            name: "道德經典藏版",
            description: "精裝典藏版道德經，附注釋與白話翻譯，是研讀道家思想的最佳選擇。",
            category: .book,
            price: 580,
            meritPointsPrice: 350,
            stock: 80,
            tags: ["經書", "道德經", "典藏"]
        )
    ]
}
