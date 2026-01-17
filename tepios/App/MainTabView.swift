/**
 * 主要 Tab 導航視圖
 * 參考：平安符打卡系統 PDF
 */

import SwiftUI

struct MainTabView: View {
    // MARK: - State

    @State private var selectedTab = 0
    @StateObject private var templeViewModel = TempleViewModel()

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedTab) {
            // 雲端護照
            CloudPassportView()
                .tabItem {
                    Label("護照", systemImage: selectedTab == 0 ? "person.text.rectangle.fill" : "person.text.rectangle")
                }
                .tag(0)
                .environmentObject(templeViewModel)

            // 平安符
            AmuletInfoView()
                .tabItem {
                    Label("平安符", systemImage: selectedTab == 1 ? "scroll.fill" : "scroll")
                }
                .tag(1)
                .environmentObject(templeViewModel)

            // 成就
            AchievementView(achievementManager: templeViewModel.achievementManager)
                .tabItem {
                    Label("成就", systemImage: selectedTab == 2 ? "trophy.fill" : "trophy")
                }
                .tag(2)
                .environmentObject(templeViewModel)

            // 地圖搜尋
            MapView()
                .tabItem {
                    Label("地圖", systemImage: selectedTab == 3 ? "map.fill" : "map")
                }
                .tag(3)

            // 設定
            SettingsView()
                .tabItem {
                    Label("設定", systemImage: selectedTab == 4 ? "gearshape.fill" : "gearshape")
                }
                .tag(4)
        }
        .accentColor(AppTheme.gold)
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
}
