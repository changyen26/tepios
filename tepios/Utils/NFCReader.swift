/**
 * NFC 讀取管理器
 * 用於讀取平安符上的 NFC 標籤
 */

import Foundation
import CoreNFC
import Combine

class NFCReader: NSObject, ObservableObject {
    // MARK: - Published Properties

    @Published var isScanning = false
    @Published var scannedData: String?
    @Published var errorMessage: String?

    // MARK: - Private Properties

    private var nfcSession: NFCNDEFReaderSession?
    private var onDataScanned: ((String) -> Void)?

    // MARK: - Public Methods

    /// 開始 NFC 掃描
    func startScanning(onDataScanned: @escaping (String) -> Void) {
        // 檢查設備是否支持 NFC
        guard NFCNDEFReaderSession.readingAvailable else {
            errorMessage = "此設備不支援 NFC 功能"
            return
        }

        self.onDataScanned = onDataScanned

        // 創建並啟動 NFC 讀取會話
        nfcSession = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,
            invalidateAfterFirstRead: true
        )

        nfcSession?.alertMessage = "請將您的 iPhone 靠近平安符"
        nfcSession?.begin()

        isScanning = true
        errorMessage = nil
    }

    /// 停止 NFC 掃描
    func stopScanning() {
        nfcSession?.invalidate()
        isScanning = false
    }
}

// MARK: - NFCNDEFReaderSessionDelegate

extension NFCReader: NFCNDEFReaderSessionDelegate {
    /// NFC 會話失效
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            self.isScanning = false

            // 檢查錯誤類型
            if let nfcError = error as? NFCReaderError {
                switch nfcError.code {
                case .readerSessionInvalidationErrorUserCanceled:
                    // 用戶取消，不顯示錯誤
                    break
                case .readerSessionInvalidationErrorSessionTimeout:
                    self.errorMessage = "NFC 掃描超時，請重試"
                case .readerSessionInvalidationErrorSystemIsBusy:
                    self.errorMessage = "系統忙碌中，請稍後再試"
                default:
                    self.errorMessage = "NFC 讀取失敗：\(error.localizedDescription)"
                }
            }
        }
    }

    /// 偵測到 NFC 標籤
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // 處理讀取到的 NDEF 訊息
        guard let firstMessage = messages.first,
              let firstRecord = firstMessage.records.first else {
            DispatchQueue.main.async {
                self.errorMessage = "無法讀取 NFC 標籤資料"
                session.invalidate()
            }
            return
        }

        // 將資料轉換為字串
        let payload = firstRecord.payload
        var amuletCode: String?

        // 嘗試不同的編碼方式解析
        if let text = String(data: payload, encoding: .utf8) {
            amuletCode = text
        } else if let text = String(data: payload, encoding: .ascii) {
            amuletCode = text
        } else {
            // 如果無法解碼，使用十六進制表示
            amuletCode = payload.map { String(format: "%02X", $0) }.joined()
        }

        // 移除可能的 NDEF 文本記錄前綴（語言代碼等）
        if let code = amuletCode, code.count > 3 {
            // NDEF 文本記錄格式：第一個字節是狀態字節，第二個字節是語言代碼長度
            let startIndex = code.index(code.startIndex, offsetBy: 3)
            amuletCode = String(code[startIndex...])
        }

        DispatchQueue.main.async {
            if let code = amuletCode, !code.isEmpty {
                self.scannedData = code
                self.onDataScanned?(code)
                session.alertMessage = "讀取成功！"
                session.invalidate()
            } else {
                self.errorMessage = "無法解析 NFC 標籤資料"
                session.invalidate(errorMessage: "無法解析標籤資料，請重試")
            }
        }
    }

    /// 成為活躍狀態
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        DispatchQueue.main.async {
            self.isScanning = true
        }
    }
}
