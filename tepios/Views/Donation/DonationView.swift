/**
 * 行動支付捐款頁面
 * 提供台灣常見的行動支付方式進行香油錢捐款
 */

import SwiftUI
import CoreLocation

struct DonationView: View {
    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - ViewModels

    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var templeViewModel = TempleViewModel.shared

    // MARK: - State

    @State private var selectedTemple: Temple?
    @State private var selectedAmount: Int = 100
    @State private var customAmount: String = ""
    @State private var showCustomInput = false
    @State private var selectedPaymentMethod: DonationPaymentMethod?
    @State private var showSuccessAlert = false

    // 預設金額選項
    private let amountOptions = [50, 100, 200, 500, 1000, 2000]

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // 背景
                AppTheme.darkGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        // 頂部說明
                        headerSection

                        // 廟宇選擇
                        templeSelectionSection
                            .padding(.horizontal, AppTheme.Spacing.xl)

                        // 金額選擇
                        amountSelectionSection
                            .padding(.horizontal, AppTheme.Spacing.xl)

                        // 支付方式選擇
                        paymentMethodSection
                            .padding(.horizontal, AppTheme.Spacing.xl)

                        // 確認按鈕
                        confirmButton
                            .padding(.horizontal, AppTheme.Spacing.xl)

                        Spacer(minLength: AppTheme.Spacing.xxxl)
                    }
                }
            }
            .navigationTitle("香油錢捐款")
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
            .alert("捐款成功", isPresented: $showSuccessAlert) {
                Button("確定", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("感謝您的捐款，願神明保佑您！\n\n已捐款 NT$ \(finalAmount) 給 \(selectedTemple?.name ?? "廟宇")")
            }
            .onAppear {
                locationManager.requestLocationPermission()
            }
        }
    }

    // MARK: - Components

    private var templeSelectionSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack {
                Text("選擇廟宇")
                    .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }

            if let location = locationManager.location {
                let nearbyTemples = templeViewModel.getNearbyTemples(from: location, radius: 5000)

                if nearbyTemples.isEmpty {
                    emptyTempleView
                } else {
                    VStack(spacing: AppTheme.Spacing.sm) {
                        ForEach(nearbyTemples) { temple in
                            templeCard(temple: temple, userLocation: location)
                        }
                    }
                }
            } else if locationManager.errorMessage != nil {
                locationErrorView
            } else {
                loadingLocationView
            }
        }
    }

    private var emptyTempleView: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "map")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.5))

            Text("附近 5 公里內沒有廟宇")
                .font(.system(size: AppTheme.FontSize.callout))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                .fill(Color.white.opacity(0.1))
        )
    }

    private var locationErrorView: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "location.slash.fill")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.5))

            Text("無法取得位置")
                .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                .foregroundColor(.white)

            Text("請確認已開啟定位權限")
                .font(.system(size: AppTheme.FontSize.caption))
                .foregroundColor(.white.opacity(0.7))

            Button(action: {
                locationManager.requestLocationPermission()
            }) {
                Text("重新授權")
                    .font(.system(size: AppTheme.FontSize.caption, weight: .semibold))
                    .foregroundColor(AppTheme.dark)
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(AppTheme.goldGradient)
                    .cornerRadius(AppTheme.CornerRadius.sm)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                .fill(Color.white.opacity(0.1))
        )
    }

    private var loadingLocationView: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.gold))
                .scaleEffect(1.2)

            Text("正在定位中...")
                .font(.system(size: AppTheme.FontSize.callout))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                .fill(Color.white.opacity(0.1))
        )
    }

    private func templeCard(temple: Temple, userLocation: CLLocation) -> some View {
        let distance = temple.distance(from: userLocation)
        let isSelected = selectedTemple?.id == temple.id

        return Button(action: {
            selectedTemple = temple
        }) {
            HStack(spacing: AppTheme.Spacing.md) {
                // 神明圖標
                ZStack {
                    Circle()
                        .fill(Color(hex: temple.deity.color).opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: temple.deity.iconName)
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: temple.deity.color))
                }

                // 廟宇資訊
                VStack(alignment: .leading, spacing: 4) {
                    Text(temple.name)
                        .font(.system(size: AppTheme.FontSize.callout, weight: .bold))
                        .foregroundColor(.white)

                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                        Text("\(Int(distance)) 公尺")
                            .font(.system(size: AppTheme.FontSize.caption))
                    }
                    .foregroundColor(.white.opacity(0.7))

                    Text("主祀：\(temple.deity.displayName)")
                        .font(.system(size: AppTheme.FontSize.caption2))
                        .foregroundColor(AppTheme.gold.opacity(0.8))
                }

                Spacer()

                // 選擇指示器
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.green)
                }
            }
            .padding(AppTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                    .fill(Color.white.opacity(isSelected ? 0.15 : 0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                            .stroke(
                                isSelected ? Color.green : Color.white.opacity(0.2),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
    }

    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "hands.sparkles.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppTheme.gold, Color(hex: "#FFD700")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: AppTheme.gold.opacity(0.5), radius: 20, x: 0, y: 10)

            Text("隨喜香油錢")
                .font(.system(size: AppTheme.FontSize.title2, weight: .bold))
                .foregroundColor(.white)

            Text("您的善款將用於廟宇維護與公益活動")
                .font(.system(size: AppTheme.FontSize.callout))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.xl)
        }
        .padding(.top, AppTheme.Spacing.xl)
    }

    private var amountSelectionSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack {
                Text("選擇金額")
                    .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }

            // 預設金額網格
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: AppTheme.Spacing.sm),
                    GridItem(.flexible(), spacing: AppTheme.Spacing.sm),
                    GridItem(.flexible(), spacing: AppTheme.Spacing.sm)
                ],
                spacing: AppTheme.Spacing.sm
            ) {
                ForEach(amountOptions, id: \.self) { amount in
                    amountButton(amount: amount)
                }

                // 自訂金額按鈕
                customAmountButton
            }

            // 自訂金額輸入框
            if showCustomInput {
                HStack {
                    Text("NT$")
                        .foregroundColor(.white)
                        .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))

                    TextField("", text: $customAmount, prompt: Text("輸入金額").foregroundColor(.white.opacity(0.6)))
                        .keyboardType(.numberPad)
                        .font(.system(size: AppTheme.FontSize.callout))
                        .foregroundColor(.white)
                        .padding(.vertical, AppTheme.Spacing.sm)
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm)
                                .fill(Color.white.opacity(0.2))
                        )
                }
                .padding(AppTheme.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                        .fill(Color.white.opacity(0.1))
                )
            }

            // 顯示選擇的金額
            HStack {
                Text("捐款金額：")
                    .foregroundColor(.white.opacity(0.7))
                Text("NT$ \(finalAmount)")
                    .font(.system(size: AppTheme.FontSize.title3, weight: .bold))
                    .foregroundColor(AppTheme.gold)
            }
            .padding(.top, AppTheme.Spacing.sm)
        }
    }

    private func amountButton(amount: Int) -> some View {
        Button(action: {
            selectedAmount = amount
            showCustomInput = false
            customAmount = ""
        }) {
            Text("NT$ \(amount)")
                .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                .foregroundColor(selectedAmount == amount && !showCustomInput ? AppTheme.dark : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                        .fill(
                            selectedAmount == amount && !showCustomInput ?
                            AppTheme.goldGradient :
                            LinearGradient(colors: [Color.white.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                        .stroke(
                            selectedAmount == amount && !showCustomInput ?
                            AppTheme.gold :
                            Color.white.opacity(0.3),
                            lineWidth: selectedAmount == amount && !showCustomInput ? 2 : 1
                        )
                )
        }
    }

    private var customAmountButton: some View {
        Button(action: {
            showCustomInput = true
        }) {
            Text("自訂")
                .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                .foregroundColor(showCustomInput ? AppTheme.dark : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                        .fill(
                            showCustomInput ?
                            AppTheme.goldGradient :
                            LinearGradient(colors: [Color.white.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                        .stroke(
                            showCustomInput ?
                            AppTheme.gold :
                            Color.white.opacity(0.3),
                            lineWidth: showCustomInput ? 2 : 1
                        )
                )
        }
    }

    private var paymentMethodSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack {
                Text("選擇支付方式")
                    .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }

            VStack(spacing: AppTheme.Spacing.sm) {
                paymentMethodCard(method: .linePay)
                paymentMethodCard(method: .jkoPay)
                paymentMethodCard(method: .applePay)
                paymentMethodCard(method: .easyWallet)
                paymentMethodCard(method: .piWallet)
            }
        }
    }

    private func paymentMethodCard(method: DonationPaymentMethod) -> some View {
        Button(action: {
            selectedPaymentMethod = method
        }) {
            HStack(spacing: AppTheme.Spacing.md) {
                // 圖標
                ZStack {
                    Circle()
                        .fill(Color(hex: method.color).opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: method.iconName)
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: method.color))
                }

                // 名稱
                VStack(alignment: .leading, spacing: 4) {
                    Text(method.displayName)
                        .font(.system(size: AppTheme.FontSize.callout, weight: .bold))
                        .foregroundColor(.white)

                    Text(method.description)
                        .font(.system(size: AppTheme.FontSize.caption))
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                // 選擇指示器
                if selectedPaymentMethod == method {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.green)
                }
            }
            .padding(AppTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                            .stroke(
                                selectedPaymentMethod == method ?
                                Color.green :
                                Color.white.opacity(0.2),
                                lineWidth: selectedPaymentMethod == method ? 2 : 1
                            )
                    )
            )
        }
    }

    private var confirmButton: some View {
        let canDonate = selectedTemple != nil && selectedPaymentMethod != nil

        return Button(action: {
            processDonation()
        }) {
            HStack {
                Image(systemName: "creditcard.fill")
                Text("確認捐款 NT$ \(finalAmount)")
                    .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
            }
            .foregroundColor(AppTheme.dark)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                canDonate ?
                AppTheme.goldGradient :
                LinearGradient(colors: [Color.gray], startPoint: .top, endPoint: .bottom)
            )
            .cornerRadius(AppTheme.CornerRadius.md)
            .shadow(
                color: canDonate ? AppTheme.gold.opacity(0.5) : Color.clear,
                radius: 10,
                x: 0,
                y: 5
            )
        }
        .disabled(!canDonate)
    }

    // MARK: - Computed Properties

    private var finalAmount: Int {
        if showCustomInput, let amount = Int(customAmount), amount > 0 {
            return amount
        }
        return selectedAmount
    }

    // MARK: - Methods

    private func processDonation() {
        // TODO: 實際整合支付 API
        // 這裡暫時只顯示成功訊息
        showSuccessAlert = true
    }
}

// MARK: - Donation Payment Method

enum DonationPaymentMethod: String, CaseIterable, Identifiable {
    case linePay = "line_pay"
    case jkoPay = "jko_pay"
    case applePay = "apple_pay"
    case easyWallet = "easy_wallet"
    case piWallet = "pi_wallet"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .linePay: return "LINE Pay"
        case .jkoPay: return "街口支付"
        case .applePay: return "Apple Pay"
        case .easyWallet: return "悠遊付"
        case .piWallet: return "Pi 拍錢包"
        }
    }

    var description: String {
        switch self {
        case .linePay: return "使用 LINE Pay 快速付款"
        case .jkoPay: return "街口支付，方便快速"
        case .applePay: return "Apple Pay 安全付款"
        case .easyWallet: return "悠遊付電子錢包"
        case .piWallet: return "全盈支付 Pi 拍錢包"
        }
    }

    var iconName: String {
        switch self {
        case .linePay: return "message.fill"
        case .jkoPay: return "bag.fill"
        case .applePay: return "apple.logo"
        case .easyWallet: return "tram.fill"
        case .piWallet: return "chart.pie.fill"
        }
    }

    var color: String {
        switch self {
        case .linePay: return "#00B900"  // LINE 綠
        case .jkoPay: return "#FF6B00"   // 街口橘
        case .applePay: return "#000000" // Apple 黑
        case .easyWallet: return "#0072E3" // 悠遊藍
        case .piWallet: return "#FF6B6B" // Pi 紅
        }
    }
}

// MARK: - Preview

#Preview {
    DonationView()
}
