/**
 * QR Code 掃描器元件
 * 使用 AVFoundation 掃描 QR Code
 */

import SwiftUI
import AVFoundation

struct QRCodeScannerView: UIViewControllerRepresentable {
    @Binding var scannedCode: String?
    @Binding var isScanning: Bool
    var onCodeScanned: ((String) -> Void)?

    func makeUIViewController(context: Context) -> QRScannerViewController {
        let viewController = QRScannerViewController()
        viewController.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {
        if isScanning {
            uiViewController.startScanning()
        } else {
            uiViewController.stopScanning()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, QRScannerDelegate {
        let parent: QRCodeScannerView

        init(parent: QRCodeScannerView) {
            self.parent = parent
        }

        func didFindCode(_ code: String) {
            parent.scannedCode = code
            parent.isScanning = false
            parent.onCodeScanned?(code)
        }

        func didFailWithError(_ error: Error) {
            print("掃描失敗: \(error.localizedDescription)")
            parent.isScanning = false
        }
    }
}

protocol QRScannerDelegate: AnyObject {
    func didFindCode(_ code: String)
    func didFailWithError(_ error: Error)
}

class QRScannerViewController: UIViewController {
    weak var delegate: QRScannerDelegate?

    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    private func setupCamera() {
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            delegate?.didFailWithError(NSError(domain: "QRScanner", code: -1, userInfo: [NSLocalizedDescriptionKey: "無法存取相機"]))
            return
        }

        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            delegate?.didFailWithError(error)
            return
        }

        if let captureSession = captureSession, captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            delegate?.didFailWithError(NSError(domain: "QRScanner", code: -2, userInfo: [NSLocalizedDescriptionKey: "無法加入視訊輸入"]))
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if let captureSession = captureSession, captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            delegate?.didFailWithError(NSError(domain: "QRScanner", code: -3, userInfo: [NSLocalizedDescriptionKey: "無法加入中繼資料輸出"]))
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer?.frame = view.layer.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer!)
    }

    func startScanning() {
        if captureSession?.isRunning == false {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.startRunning()
            }
        }
    }

    func stopScanning() {
        if captureSession?.isRunning == true {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.stopRunning()
            }
        }
    }
}

extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }

            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            delegate?.didFindCode(stringValue)
        }
    }
}
