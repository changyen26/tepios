//
//  APIClient.swift
//  tepios
//
//  API 客戶端 - 處理所有網路請求
//

import Foundation
import Combine

class APIClient: ObservableObject {
    static let shared = APIClient()

    // 發布登入狀態
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: APIUser?
    @Published var currentAmuletId: Int?

    private init() {
        // 檢查是否有儲存的 Token
        if token != nil {
            isLoggedIn = true
            // 可以在這裡呼叫 /auth/me 來驗證 token 是否有效
        }
    }

    // MARK: - Token 管理
    private var token: String? {
        get { UserDefaults.standard.string(forKey: "authToken") }
        set {
            UserDefaults.standard.set(newValue, forKey: "authToken")
            isLoggedIn = newValue != nil
        }
    }

    // MARK: - 通用請求方法
    private func request<T: Decodable>(
        url: URL,
        method: String = "GET",
        body: [String: Any]? = nil,
        requiresAuth: Bool = false,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        // 加入 Token
        if requiresAuth, let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // 加入 Body
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        print("🌐 API Request: \(method) \(url.absoluteString)")
        if let body = body {
            print("📦 Body: \(body)")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else {
                print("❌ No Data")
                DispatchQueue.main.async {
                    completion(.failure(APIError.noData))
                }
                return
            }

            // Debug: 印出原始回應
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📥 Response: \(jsonString.prefix(500))...")
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                print("✅ Decode Success")
                DispatchQueue.main.async {
                    completion(.success(decoded))
                }
            } catch {
                print("❌ Decode Error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // MARK: - 登入
    func login(email: String, password: String, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        guard let url = URL(string: APIConfig.baseURL + APIConfig.Endpoints.login) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        let body: [String: Any] = [
            "email": email,
            "password": password,
            "login_type": "public"
        ]

        request(url: url, method: "POST", body: body) { [weak self] (result: Result<APIResponse<LoginData>, Error>) in
            switch result {
            case .success(let response):
                if response.success, let data = response.data {
                    self?.token = data.token
                    self?.currentUser = data.user
                    self?.currentAmuletId = APIConfig.testAmuletId  // 暫時使用測試 ID
                    print("✅ 登入成功: \(data.user.name)")
                    completion(.success(LoginResponse(user: data.user, token: data.token)))
                } else {
                    print("❌ 登入失敗: \(response.message)")
                    completion(.failure(APIError.serverError(response.message)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - 註冊
    func register(name: String, email: String, password: String, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        guard let url = URL(string: APIConfig.baseURL + APIConfig.Endpoints.register) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        let body: [String: Any] = [
            "name": name,
            "email": email,
            "password": password
        ]

        request(url: url, method: "POST", body: body) { [weak self] (result: Result<APIResponse<LoginData>, Error>) in
            switch result {
            case .success(let response):
                if response.success, let data = response.data {
                    self?.token = data.token
                    self?.currentUser = data.user
                    completion(.success(LoginResponse(user: data.user, token: data.token)))
                } else {
                    completion(.failure(APIError.serverError(response.message)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - 登出
    func logout() {
        token = nil
        currentUser = nil
        currentAmuletId = nil
        isLoggedIn = false
        print("👋 已登出")
    }

    // MARK: - 取得當前使用者
    func getCurrentUser(completion: @escaping (Result<APIUser, Error>) -> Void) {
        guard let url = URL(string: APIConfig.baseURL + APIConfig.Endpoints.me) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        request(url: url, requiresAuth: true) { [weak self] (result: Result<APIResponse<UserData>, Error>) in
            switch result {
            case .success(let response):
                if response.success, let data = response.data {
                    self?.currentUser = data.user
                    completion(.success(data.user))
                } else {
                    completion(.failure(APIError.serverError(response.message)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - 取得廟宇列表
    func getTemples(completion: @escaping (Result<[APITemple], Error>) -> Void) {
        guard let url = URL(string: APIConfig.baseURL + APIConfig.Endpoints.temples) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        request(url: url) { (result: Result<APIResponse<TemplesData>, Error>) in
            switch result {
            case .success(let response):
                if response.success, let data = response.data {
                    print("📍 取得 \(data.temples.count) 座廟宇")
                    completion(.success(data.temples))
                } else {
                    completion(.failure(APIError.serverError(response.message)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - 取得廟宇詳情
    func getTempleDetail(templeId: Int, completion: @escaping (Result<APITemple, Error>) -> Void) {
        guard let url = URL(string: APIConfig.templeDetailURL(templeId: templeId)) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        request(url: url) { (result: Result<APIResponse<APITemple>, Error>) in
            switch result {
            case .success(let response):
                if response.success, let temple = response.data {
                    completion(.success(temple))
                } else {
                    completion(.failure(APIError.serverError(response.message)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - 取得附近廟宇
    func getNearbyTemples(latitude: Double, longitude: Double, radius: Double = 10, completion: @escaping (Result<[APITemple], Error>) -> Void) {
        let endpoint = "\(APIConfig.Endpoints.nearbyTemples)?latitude=\(latitude)&longitude=\(longitude)&radius=\(radius)"

        guard let url = URL(string: APIConfig.baseURL + endpoint) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        request(url: url) { (result: Result<APIResponse<NearbyTemplesData>, Error>) in
            switch result {
            case .success(let response):
                if response.success, let data = response.data {
                    print("📍 附近有 \(data.temples.count) 座廟宇")
                    completion(.success(data.temples))
                } else {
                    completion(.failure(APIError.serverError(response.message)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - 廟宇打卡
    func checkin(
        templeId: Int,
        amuletId: Int? = nil,
        latitude: Double,
        longitude: Double,
        notes: String? = nil,
        completion: @escaping (Result<CheckinResponse, Error>) -> Void
    ) {
        guard let url = URL(string: APIConfig.checkinURL(templeId: templeId)) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        let actualAmuletId = amuletId ?? currentAmuletId ?? APIConfig.testAmuletId

        var body: [String: Any] = [
            "amulet_id": actualAmuletId,
            "latitude": latitude,
            "longitude": longitude
        ]

        if let notes = notes {
            body["notes"] = notes
        }

        request(url: url, method: "POST", body: body, requiresAuth: true) { [weak self] (result: Result<APIResponse<CheckinData>, Error>) in
            switch result {
            case .success(let response):
                if response.success, let data = response.data {
                    // 更新使用者功德點
                    self?.currentUser = APIUser(
                        id: self?.currentUser?.id ?? 0,
                        name: self?.currentUser?.name ?? "",
                        email: self?.currentUser?.email ?? "",
                        blessingPoints: data.currentBlessingPoints,
                        isActive: self?.currentUser?.isActive ?? true,
                        createdAt: self?.currentUser?.createdAt,
                        lastLoginAt: self?.currentUser?.lastLoginAt
                    )

                    let checkinResponse = CheckinResponse(
                        checkinId: data.checkin.id,
                        templeName: data.checkin.templeName ?? "",
                        blessingPointsGained: data.blessingPointsGained,
                        currentBlessingPoints: data.currentBlessingPoints,
                        message: response.message
                    )
                    print("✅ 打卡成功: \(checkinResponse.templeName), +\(checkinResponse.blessingPointsGained) 功德")
                    completion(.success(checkinResponse))
                } else {
                    print("❌ 打卡失敗: \(response.message)")
                    completion(.failure(APIError.serverError(response.message)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - QR Code 打卡
    func checkinWithQRCode(
        qrContent: String,
        latitude: Double,
        longitude: Double,
        completion: @escaping (Result<CheckinResponse, Error>) -> Void
    ) {
        guard let qrCode = QRCodeContent.parse(qrContent) else {
            completion(.failure(APIError.invalidQRCode))
            return
        }

        guard let templeId = qrCode.templeId else {
            completion(.failure(APIError.invalidQRCode))
            return
        }

        print("📱 QR Code 打卡: temple_id = \(templeId)")
        checkin(templeId: templeId, latitude: latitude, longitude: longitude, completion: completion)
    }
}

// MARK: - 輔助資料結構
struct UserData: Decodable {
    let user: APIUser
    let accountType: String?

    enum CodingKeys: String, CodingKey {
        case user
        case accountType = "account_type"
    }
}

// MARK: - API Error
enum APIError: LocalizedError {
    case invalidURL
    case noData
    case serverError(String)
    case unauthorized
    case invalidQRCode

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "無效的 URL"
        case .noData:
            return "沒有資料"
        case .serverError(let message):
            return message
        case .unauthorized:
            return "請先登入"
        case .invalidQRCode:
            return "無效的 QR Code"
        }
    }
}
