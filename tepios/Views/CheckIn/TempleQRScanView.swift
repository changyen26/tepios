/**
 * 廟宇 QR Code 掃描頁面
 * 用於掃描廟宇 QR Code 進行打卡
 */

import SwiftUI

struct TempleQRScanView: View {
    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    @State private var isScanning = true
    @State private var scannedCode: String?
    @State private var showAlert = false
    @State private var alertMessage = ""

    // MARK: - Body

    var body: some View {
        ZStack {
            // 相機預覽
            QRCodeScannerView(
                scannedCode: $scannedCode,
                isScanning: $isScanning,
                onCodeScanned: handleCodeScanned
            )
            .ignoresSafeArea()

            // 覆蓋層
            VStack {
                // 頂部工具列
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .padding()

                    Spacer()
                }

                Spacer()

                // 掃描框
                VStack(spacing: AppTheme.Spacing.xl) {
                    ZStack {
                        // 半透明背景
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(AppTheme.gold, lineWidth: 3)
                            .frame(width: 250, height: 250)

                        // 四個角落的裝飾
                        ForEach(0..<4) { index in
                            cornerDecoration(at: index)
                        }
                    }

                    // 提示文字
                    VStack(spacing: AppTheme.Spacing.sm) {
                        Text("對準廟宇的 QR Code")
                            .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                            .foregroundColor(.white)

                        Text("將 QR Code 放入框內即可自動掃描")
                            .font(.system(size: AppTheme.FontSize.callout))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .multilineTextAlignment(.center)
                }

                Spacer()

                // 底部說明
                VStack(spacing: AppTheme.Spacing.md) {
                    HStack(spacing: AppTheme.Spacing.md) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(AppTheme.gold)

                        Text("請確保光線充足以獲得最佳掃描效果")
                            .font(.system(size: AppTheme.FontSize.caption))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(AppTheme.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                            .fill(Color.black.opacity(0.5))
                    )
                }
                .padding(.horizontal, AppTheme.Spacing.xl)
                .padding(.bottom, AppTheme.Spacing.xxxl)
            }
        }
        .alert("提示", isPresented: $showAlert) {
            Button("確定", role: .cancel) {
                // 重新開始掃描
                isScanning = true
            }
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - Components

    private func cornerDecoration(at index: Int) -> some View {
        let positions: [(x: CGFloat, y: CGFloat)] = [
            (-125, -125), // 左上
            (125, -125),  // 右上
            (-125, 125),  // 左下
            (125, 125)    // 右下
        ]

        let rotations: [Double] = [0, 90, 270, 180]

        return Image(systemName: "l.square.fill")
            .font(.system(size: 24))
            .foregroundColor(AppTheme.gold)
            .rotationEffect(.degrees(rotations[index]))
            .offset(x: positions[index].x, y: positions[index].y)
    }

    // MARK: - Methods

    private func handleCodeScanned(_ code: String) {
        // 停止掃描
        isScanning = false

        // 處理掃描結果
        // 這裡應該驗證 QR Code 並導航到打卡確認頁面
        // 目前先顯示提示
        alertMessage = "掃描成功！\n廟宇代碼：\(code)\n\n此功能開發中"
        showAlert = true

        // TODO: 實際應該要：
        // 1. 驗證 QR Code 是否為有效的廟宇代碼
        // 2. 獲取廟宇資訊
        // 3. 導航到 CheckInSheetView 進行打卡確認
    }
}

// MARK: - Preview

#Preview {
    TempleQRScanView()
}
