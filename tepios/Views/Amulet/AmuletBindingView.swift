/**
 * 平安符綁定頁面
 * 提供掃描 QR Code 或手動輸入來綁定平安符
 */

import SwiftUI
import CoreNFC

struct AmuletBindingView: View {
    // MARK: - State

    @Environment(\.dismiss) private var dismiss
    @StateObject private var nfcReader = NFCReader()
    @State private var showScanner = false
    @State private var isScanning = false
    @State private var scannedCode: String?
    @State private var nfcCode: String?
    @State private var manualCode = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var bindingSuccess = false
    @State private var isBinding = false
    @FocusState private var isInputFocused: Bool

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // 背景漸層
                AppTheme.darkGradient
                    .ignoresSafeArea()
                    .onTapGesture {
                        hideKeyboard()
                    }

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xxxl) {
                        // 標題區域
                        headerSection
                            .padding(.top, AppTheme.Spacing.xxl)

                        // 綁定選項區域
                        bindingOptionsSection
                            .padding(.horizontal, AppTheme.Spacing.xl)

                        // 分隔線
                        divider

                        // 手動輸入區域
                        manualInputSection
                            .padding(.horizontal, AppTheme.Spacing.xl)

                        // 綁定按鈕
                        bindButton
                            .padding(.horizontal, AppTheme.Spacing.xl)
                            .padding(.bottom, AppTheme.Spacing.xxxl)
                    }
                }
            }
            .navigationTitle("綁定平安符")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("關閉") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.gold)
                }
            }
            .sheet(isPresented: $showScanner) {
                scannerSheet
            }
            .alert("綁定結果", isPresented: $showAlert) {
                Button("確定", role: .cancel) {
                    if bindingSuccess {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .onChange(of: nfcReader.errorMessage) { errorMessage in
                if let error = errorMessage {
                    alertMessage = error
                    showAlert = true
                }
            }
        }
    }

    // MARK: - Components

    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // 圖標
            ZStack {
                Circle()
                    .fill(AppTheme.goldGradient)
                    .frame(width: 100, height: 100)
                    .shadow(
                        color: AppTheme.gold.opacity(0.4),
                        radius: 20,
                        x: 0,
                        y: 10
                    )

                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 50))
                    .foregroundColor(AppTheme.dark)
            }

            Text("綁定您的平安符")
                .font(.system(size: AppTheme.FontSize.title2, weight: .bold))
                .foregroundColor(.white)

            Text(NFCNDEFReaderSession.readingAvailable ? "掃描 QR Code、NFC 感應或手動輸入編號" : "掃描 QR Code 或手動輸入編號")
                .font(.system(size: AppTheme.FontSize.callout))
                .foregroundColor(AppTheme.whiteAlpha06)
                .multilineTextAlignment(.center)
        }
        .onTapGesture {
            hideKeyboard()
        }
    }

    private var bindingOptionsSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.md) {
                // QR Code 掃描按鈕
                qrCodeButton

                // NFC 感應按鈕（僅在支援時顯示）
                if NFCNDEFReaderSession.readingAvailable {
                    nfcButton
                }
            }

            // 已掃描/感應的代碼顯示
            if let code = scannedCode ?? nfcCode {
                codeDisplayCard(code: code, type: scannedCode != nil ? "QR Code" : "NFC")
            }
        }
    }

    private var qrCodeButton: some View {
        Button(action: {
            showScanner = true
            isScanning = true
        }) {
            VStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: "qrcode")
                    .font(.system(size: 32))
                    .foregroundColor(AppTheme.gold)

                Text("QR Code")
                    .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                    .foregroundColor(.white)

                Text("掃描條碼")
                    .font(.system(size: AppTheme.FontSize.caption2))
                    .foregroundColor(AppTheme.whiteAlpha06)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.xl)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                            .stroke(AppTheme.gold.opacity(0.3), lineWidth: 2)
                    )
            )
        }
    }

    private var nfcButton: some View {
        Button(action: {
            startNFCScanning()
        }) {
            VStack(spacing: AppTheme.Spacing.md) {
                ZStack {
                    if nfcReader.isScanning {
                        // 掃描動畫
                        Circle()
                            .stroke(AppTheme.gold.opacity(0.3), lineWidth: 2)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Circle()
                                    .trim(from: 0, to: 0.7)
                                    .stroke(AppTheme.gold, lineWidth: 3)
                                    .frame(width: 50, height: 50)
                                    .rotationEffect(.degrees(-90))
                            )
                    }

                    Image(systemName: "wave.3.right")
                        .font(.system(size: 32))
                        .foregroundColor(nfcReader.isScanning ? AppTheme.gold : AppTheme.gold.opacity(0.8))
                }
                .frame(height: 40)

                Text("NFC 感應")
                    .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                    .foregroundColor(.white)

                Text(nfcReader.isScanning ? "感應中..." : "靠近標籤")
                    .font(.system(size: AppTheme.FontSize.caption2))
                    .foregroundColor(AppTheme.whiteAlpha06)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.xl)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                    .fill(Color.white.opacity(nfcReader.isScanning ? 0.1 : 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                            .stroke(
                                nfcReader.isScanning ? AppTheme.gold : AppTheme.gold.opacity(0.3),
                                lineWidth: nfcReader.isScanning ? 2 : 2
                            )
                    )
            )
        }
        .disabled(nfcReader.isScanning)
    }

    private func codeDisplayCard(code: String, type: String) -> some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            VStack(alignment: .leading, spacing: 4) {
                Text("已\(type == "QR Code" ? "掃描" : "感應"): \(code)")
                    .font(.system(size: AppTheme.FontSize.callout, weight: .medium))
                    .foregroundColor(AppTheme.whiteAlpha08)
                Text("透過 \(type)")
                    .font(.system(size: AppTheme.FontSize.caption2))
                    .foregroundColor(AppTheme.whiteAlpha06)
            }
            Spacer()
        }
        .padding(AppTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                .fill(Color.green.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private var divider: some View {
        HStack {
            Rectangle()
                .fill(AppTheme.whiteAlpha06)
                .frame(height: 1)

            Text("或")
                .font(.system(size: AppTheme.FontSize.callout))
                .foregroundColor(AppTheme.whiteAlpha06)
                .padding(.horizontal, AppTheme.Spacing.md)

            Rectangle()
                .fill(AppTheme.whiteAlpha06)
                .frame(height: 1)
        }
        .padding(.horizontal, AppTheme.Spacing.xl)
    }

    private var manualInputSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("手動輸入編號")
                .font(.system(size: AppTheme.FontSize.headline, weight: .semibold))
                .foregroundColor(.white)

            // 輸入框
            TextField("", text: $manualCode, prompt: Text("請輸入平安符編號").foregroundColor(.white.opacity(0.6)))
                .font(.system(size: AppTheme.FontSize.body))
                .foregroundColor(.white)
                .padding(AppTheme.Spacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                        .fill(Color.white.opacity(isInputFocused ? 0.1 : 0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                .stroke(
                                    isInputFocused ? AppTheme.gold : AppTheme.gold.opacity(0.3),
                                    lineWidth: isInputFocused ? 2 : 1
                                )
                        )
                )
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .focused($isInputFocused)
                .submitLabel(.done)
                .onSubmit {
                    hideKeyboard()
                }

            Text("平安符編號通常為 8-12 位的英數字組合")
                .font(.system(size: AppTheme.FontSize.caption))
                .foregroundColor(AppTheme.whiteAlpha06)
        }
    }

    private var bindButton: some View {
        Button(action: performBinding) {
            HStack {
                if isBinding {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.dark))
                } else {
                    Image(systemName: "link.circle.fill")
                        .font(.system(size: 20))
                    Text("綁定平安符")
                        .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                }
            }
            .foregroundColor(AppTheme.dark)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                    .fill(canBind ? AppTheme.goldGradient : LinearGradient(colors: [Color.gray], startPoint: .leading, endPoint: .trailing))
                    .shadow(
                        color: canBind ? AppTheme.gold.opacity(0.3) : Color.clear,
                        radius: 12,
                        x: 0,
                        y: 4
                    )
            )
        }
        .disabled(!canBind || isBinding)
    }

    private var scannerSheet: some View {
        NavigationStack {
            ZStack {
                QRCodeScannerView(
                    scannedCode: $scannedCode,
                    isScanning: $isScanning,
                    onCodeScanned: { code in
                        scannedCode = code
                        showScanner = false
                    }
                )

                // 掃描框
                VStack {
                    Spacer()

                    // 掃描區域框
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AppTheme.gold, lineWidth: 3)
                        .frame(width: 250, height: 250)

                    Spacer()

                    // 提示文字
                    Text("將 QR Code 放在框內")
                        .font(.system(size: AppTheme.FontSize.headline, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(AppTheme.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                .fill(Color.black.opacity(0.7))
                        )
                        .padding(.bottom, AppTheme.Spacing.xxxl)
                }
            }
            .navigationTitle("掃描 QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消") {
                        isScanning = false
                        showScanner = false
                    }
                    .foregroundColor(AppTheme.gold)
                }
            }
        }
    }

    // MARK: - Computed Properties

    private var canBind: Bool {
        return scannedCode != nil || nfcCode != nil || !manualCode.isEmpty
    }

    private var codeToBinding: String? {
        if let scannedCode = scannedCode {
            return scannedCode
        } else if let nfcCode = nfcCode {
            return nfcCode
        } else if !manualCode.isEmpty {
            return manualCode
        }
        return nil
    }

    // MARK: - Methods

    private func performBinding() {
        guard let code = codeToBinding else { return }

        hideKeyboard()
        isBinding = true

        // 模擬 API 呼叫
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isBinding = false

            // 簡單驗證（實際應該呼叫後端 API）
            if code.count >= 8 {
                bindingSuccess = true
                alertMessage = "平安符綁定成功！\n編號：\(code)\n您可以開始累積福報值了。"
            } else {
                bindingSuccess = false
                alertMessage = "綁定失敗\n請確認平安符編號是否正確。"
            }

            showAlert = true
        }
    }

    private func hideKeyboard() {
        isInputFocused = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func startNFCScanning() {
        hideKeyboard()

        // 清除之前的掃描結果
        scannedCode = nil
        nfcCode = nil

        nfcReader.startScanning { code in
            nfcCode = code
        }
    }
}

// MARK: - NFC Error Handling

extension AmuletBindingView {
    /// 監聽 NFC 錯誤
    private func setupNFCErrorHandling() -> some View {
        self.onChange(of: nfcReader.errorMessage) { errorMessage in
            if let error = errorMessage {
                alertMessage = error
                showAlert = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    AmuletBindingView()
}
