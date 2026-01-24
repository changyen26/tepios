/**
 * 添加家人好友頁面
 */

import SwiftUI

struct AddFriendView: View {
    // MARK: - State

    @Environment(\.dismiss) private var dismiss
    @StateObject private var userViewModel = UserProfileViewModel.shared
    @State private var searchText = ""
    @State private var selectedRelationship: Relationship = .friend
    @State private var showQRScanner = false
    @State private var showMyQRCode = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.darkGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        // 搜尋區域
                        searchSection

                        // 分隔線
                        divider

                        // QR Code 區域
                        qrCodeSection

                        Spacer(minLength: AppTheme.Spacing.xxxl)
                    }
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .padding(.top, AppTheme.Spacing.lg)
                }
            }
            .navigationTitle("添加家人好友")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("關閉") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.gold)
                }
            }
            .sheet(isPresented: $showQRScanner) {
                QRCodeScannerView(
                    scannedCode: .constant(nil),
                    isScanning: .constant(true),
                    onCodeScanned: { code in
                        handleQRCode(code)
                    }
                )
            }
            .sheet(isPresented: $showMyQRCode) {
                MyQRCodeView()
            }
            .alert("提示", isPresented: $showAlert) {
                Button("確定", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - Components

    /// 搜尋區域
    private var searchSection: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // 標題
            HStack {
                Text("搜尋好友")
                    .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }

            // 搜尋框
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.6))

                TextField("", text: $searchText, prompt: Text("輸入用戶 ID 或暱稱").foregroundColor(.white.opacity(0.6)))
                    .font(.system(size: AppTheme.FontSize.body))
                    .foregroundColor(.white)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .padding(AppTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                    .fill(Color.white.opacity(0.1))
            )

            // 關係選擇
            HStack(spacing: AppTheme.Spacing.md) {
                Text("關係：")
                    .font(.system(size: AppTheme.FontSize.callout))
                    .foregroundColor(.white.opacity(0.8))

                ForEach(Relationship.allCases, id: \.self) { relationship in
                    relationshipChip(relationship)
                }

                Spacer()
            }

            // 搜尋按鈕
            Button(action: performSearch) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("搜尋")
                        .font(.system(size: AppTheme.FontSize.headline, weight: .semibold))
                }
                .foregroundColor(AppTheme.dark)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                        .fill(searchText.isEmpty ? LinearGradient(colors: [Color.gray], startPoint: .leading, endPoint: .trailing) : AppTheme.goldGradient)
                )
            }
            .disabled(searchText.isEmpty)
        }
    }

    /// 關係選擇 chip
    private func relationshipChip(_ relationship: Relationship) -> some View {
        Button(action: {
            selectedRelationship = relationship
        }) {
            HStack(spacing: 4) {
                Image(systemName: relationship.iconName)
                    .font(.system(size: 14))
                Text(relationship.rawValue)
                    .font(.system(size: AppTheme.FontSize.callout, weight: .medium))
            }
            .foregroundColor(selectedRelationship == relationship ? AppTheme.dark : .white)
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                    .fill(
                        selectedRelationship == relationship
                            ? AppTheme.goldGradient
                            : LinearGradient(colors: [Color.white.opacity(0.1)], startPoint: .leading, endPoint: .trailing)
                    )
            )
        }
    }

    /// 分隔線
    private var divider: some View {
        HStack {
            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(height: 1)

            Text("或")
                .font(.system(size: AppTheme.FontSize.callout))
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal, AppTheme.Spacing.md)

            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(height: 1)
        }
    }

    /// QR Code 區域
    private var qrCodeSection: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // 標題
            HStack {
                Text("QR Code")
                    .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }

            // 掃描 QR Code 按鈕
            Button(action: { showQRScanner = true }) {
                HStack(spacing: AppTheme.Spacing.md) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.gold.opacity(0.2))
                            .frame(width: 50, height: 50)

                        Image(systemName: "qrcode.viewfinder")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.gold)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("掃描 QR Code")
                            .font(.system(size: AppTheme.FontSize.headline, weight: .semibold))
                            .foregroundColor(.white)

                        Text("掃描對方的 QR Code 快速添加")
                            .font(.system(size: AppTheme.FontSize.caption))
                            .foregroundColor(.white.opacity(0.6))
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(AppTheme.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                        .fill(Color.white.opacity(0.1))
                )
            }

            // 分享我的 QR Code 按鈕
            Button(action: { showMyQRCode = true }) {
                HStack(spacing: AppTheme.Spacing.md) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 50, height: 50)

                        Image(systemName: "qrcode")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("我的 QR Code")
                            .font(.system(size: AppTheme.FontSize.headline, weight: .semibold))
                            .foregroundColor(.white)

                        Text("分享給朋友讓他們添加你")
                            .font(.system(size: AppTheme.FontSize.caption))
                            .foregroundColor(.white.opacity(0.6))
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(AppTheme.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                        .fill(Color.white.opacity(0.1))
                )
            }
        }
    }

    // MARK: - Methods

    /// 執行搜尋
    private func performSearch() {
        // TODO: 實際應該呼叫後端 API 搜尋
        // 這裡模擬搜尋結果
        alertMessage = "搜尋功能開發中\n將在後端 API 完成後啟用"
        showAlert = true
    }

    /// 處理掃描到的 QR Code
    private func handleQRCode(_ code: String) {
        // 解析 QR Code：tepios://user/{userId}
        if code.hasPrefix("tepios://user/") {
            let userId = code.replacingOccurrences(of: "tepios://user/", with: "")

            // TODO: 實際應該呼叫後端 API 獲取用戶資料並添加好友
            // 這裡模擬添加成功
            alertMessage = "已發送好友申請\n待對方同意後成為好友"
            showAlert = true
            showQRScanner = false
        } else {
            alertMessage = "無效的 QR Code"
            showAlert = true
        }
    }
}

// MARK: - Preview

#Preview {
    AddFriendView()
}
