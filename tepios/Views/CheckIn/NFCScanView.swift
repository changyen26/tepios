/**
 * NFC 感應打卡頁面
 * 使用 NFC 標籤進行廟宇打卡
 */

import SwiftUI
import CoreNFC
import Combine

struct NFCScanView: View {
    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    @StateObject private var nfcManager = NFCManager()
    @StateObject private var templeViewModel = TempleViewModel.shared
    @StateObject private var locationManager = LocationManager.shared
    @State private var selectedTemple: Temple?
    @State private var showCheckInSheet = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // 背景
                AppTheme.darkGradient
                    .ignoresSafeArea()

                VStack(spacing: AppTheme.Spacing.xl) {
                    Spacer()

                    // NFC 圖標和說明
                    VStack(spacing: AppTheme.Spacing.lg) {
                        // NFC 波紋動畫
                        ZStack {
                            // 外圈波紋
                            Circle()
                                .stroke(AppTheme.gold.opacity(0.2), lineWidth: 2)
                                .frame(width: 200, height: 200)
                                .scaleEffect(nfcManager.isScanning ? 1.2 : 1.0)
                                .opacity(nfcManager.isScanning ? 0 : 1)
                                .animation(
                                    nfcManager.isScanning ?
                                        Animation.easeOut(duration: 1.5).repeatForever(autoreverses: false) :
                                        .default,
                                    value: nfcManager.isScanning
                                )

                            // 中圈波紋
                            Circle()
                                .stroke(AppTheme.gold.opacity(0.3), lineWidth: 2)
                                .frame(width: 160, height: 160)
                                .scaleEffect(nfcManager.isScanning ? 1.2 : 1.0)
                                .opacity(nfcManager.isScanning ? 0 : 1)
                                .animation(
                                    nfcManager.isScanning ?
                                        Animation.easeOut(duration: 1.5).repeatForever(autoreverses: false).delay(0.3) :
                                        .default,
                                    value: nfcManager.isScanning
                                )

                            // 內圈波紋
                            Circle()
                                .stroke(AppTheme.gold.opacity(0.4), lineWidth: 2)
                                .frame(width: 120, height: 120)
                                .scaleEffect(nfcManager.isScanning ? 1.2 : 1.0)
                                .opacity(nfcManager.isScanning ? 0 : 1)
                                .animation(
                                    nfcManager.isScanning ?
                                        Animation.easeOut(duration: 1.5).repeatForever(autoreverses: false).delay(0.6) :
                                        .default,
                                    value: nfcManager.isScanning
                                )

                            // 主圖標
                            ZStack {
                                Circle()
                                    .fill(AppTheme.goldGradient)
                                    .frame(width: 100, height: 100)
                                    .shadow(
                                        color: AppTheme.gold.opacity(0.5),
                                        radius: 20,
                                        x: 0,
                                        y: 10
                                    )

                                Image(systemName: "wave.3.right")
                                    .font(.system(size: 50))
                                    .foregroundColor(AppTheme.dark)
                            }
                        }

                        // 標題
                        Text(nfcManager.isScanning ? "請將手機靠近 NFC 標籤" : "NFC 感應打卡")
                            .font(.system(size: AppTheme.FontSize.title2, weight: .bold))
                            .foregroundColor(.white)

                        // 說明
                        Text(nfcManager.isScanning ? "保持手機靠近標籤直到感應成功" : "輕觸下方按鈕開始感應")
                            .font(.system(size: AppTheme.FontSize.callout))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppTheme.Spacing.xl)

                        // 狀態訊息
                        if let message = nfcManager.statusMessage {
                            Text(message)
                                .font(.system(size: AppTheme.FontSize.caption))
                                .foregroundColor(nfcManager.isSuccess ? .green : .yellow)
                                .padding(.horizontal, AppTheme.Spacing.xl)
                        }
                    }

                    Spacer()

                    // 操作按鈕
                    VStack(spacing: AppTheme.Spacing.md) {
                        if !nfcManager.isScanning {
                            // 開始掃描按鈕
                            Button(action: {
                                startNFCScan()
                            }) {
                                HStack {
                                    Image(systemName: "wave.3.right")
                                    Text("開始感應")
                                        .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                                }
                                .foregroundColor(AppTheme.dark)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(AppTheme.goldGradient)
                                .cornerRadius(AppTheme.CornerRadius.md)
                            }
                        } else {
                            // 取消掃描按鈕
                            Button(action: {
                                nfcManager.stopScanning()
                            }) {
                                HStack {
                                    Image(systemName: "xmark.circle.fill")
                                    Text("取消感應")
                                        .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                        .fill(Color.red.opacity(0.8))
                                )
                            }
                        }

                        // 關閉按鈕
                        Button(action: {
                            dismiss()
                        }) {
                            Text("關閉")
                                .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .padding(.bottom, AppTheme.Spacing.xxl)
                }
            }
            .navigationTitle("NFC 感應")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(item: $selectedTemple) { temple in
                CheckInSheetView(
                    temple: temple,
                    templeViewModel: templeViewModel,
                    locationManager: locationManager
                )
            }
            .alert(alertTitle, isPresented: $showAlert) {
                Button("確定", role: .cancel) {
                    if nfcManager.isSuccess {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .onChange(of: nfcManager.scannedTempleId) { _, newValue in
                handleNFCResult(templeId: newValue)
            }
        }
    }

    // MARK: - Methods

    private func startNFCScan() {
        nfcManager.startScanning()
    }

    private func handleNFCResult(templeId: String?) {
        guard let templeId = templeId else { return }

        // 尋找對應的廟宇
        if let temple = templeViewModel.getTemple(by: templeId) {
            selectedTemple = temple
        } else {
            alertTitle = "無法識別"
            alertMessage = "找不到對應的廟宇資訊\n\n請確認 NFC 標籤是否正確"
            showAlert = true
        }
    }
}

// MARK: - NFC Manager

class NFCManager: NSObject, ObservableObject {
    @Published var isScanning = false
    @Published var statusMessage: String?
    @Published var scannedTempleId: String?
    @Published var isSuccess = false

    private var nfcSession: NFCNDEFReaderSession?

    func startScanning() {
        guard NFCNDEFReaderSession.readingAvailable else {
            statusMessage = "此裝置不支援 NFC 功能"
            return
        }

        isScanning = true
        isSuccess = false
        statusMessage = "準備感應中..."
        scannedTempleId = nil

        nfcSession = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,
            invalidateAfterFirstRead: true
        )

        nfcSession?.alertMessage = "請將 iPhone 靠近廟宇的 NFC 標籤"
        nfcSession?.begin()
    }

    func stopScanning() {
        nfcSession?.invalidate()
        isScanning = false
        statusMessage = nil
    }
}

// MARK: - NFCNDEFReaderSessionDelegate

extension NFCManager: NFCNDEFReaderSessionDelegate {
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        for message in messages {
            for record in message.records {
                if let payload = String(data: record.payload, encoding: .utf8) {
                    // 解析 NFC 標籤中的廟宇 ID
                    DispatchQueue.main.async {
                        self.scannedTempleId = payload
                        self.isSuccess = true
                        self.statusMessage = "感應成功！"
                        self.isScanning = false
                    }
                }
            }
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            self.isScanning = false

            if let readerError = error as? NFCReaderError {
                switch readerError.code {
                case .readerSessionInvalidationErrorUserCanceled:
                    self.statusMessage = "已取消感應"
                case .readerSessionInvalidationErrorSessionTimeout:
                    self.statusMessage = "感應逾時，請重試"
                default:
                    self.statusMessage = "感應失敗: \(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NFCScanView()
}
