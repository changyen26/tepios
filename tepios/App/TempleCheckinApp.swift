/**
 * Temple Check-in App 主程式入口
 */

import SwiftUI

@main
struct TempleCheckinApp: App {
    // MARK: - State

    @AppStorage("isLoggedIn") private var isLoggedIn = false

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            // 登入流程
            if isLoggedIn {
                MainTabView()
            } else {
                LoginView(isLoggedIn: $isLoggedIn)
            }
        }
    }
}
