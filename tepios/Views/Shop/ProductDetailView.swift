/**
 * 商品詳情頁面
 * 顯示商品的完整資訊和購買/兌換按鈕
 */

import SwiftUI

struct ProductDetailView: View {
    // MARK: - Properties

    let product: Product

    @StateObject private var userViewModel = UserProfileViewModel.shared
    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    @State private var quantity: Int = 1
    @State private var showPurchaseConfirm = false
    @State private var showRedeemConfirm = false
    @State private var selectedPaymentMethod: PaymentMethod? = nil

    // MARK: - Computed Properties

    private var availableMeritPoints: Int {
        return userViewModel.user.cloudPassport.currentMeritPoints
    }

    private var canAffordWithMerit: Bool {
        guard let meritPrice = product.meritPointsPrice else { return false }
        return availableMeritPoints >= meritPrice * quantity
    }

    private var totalPrice: Int {
        return product.price * quantity
    }

    private var totalMeritPoints: Int {
        return (product.meritPointsPrice ?? 0) * quantity
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // 背景漸層
            AppTheme.darkGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    // 商品圖片區域
                    productImageSection

                    // 商品資訊區域
                    productInfoSection
                        .padding(.horizontal, AppTheme.Spacing.xl)

                    // 關聯廟宇
                    if product.templeName != nil {
                        templeSection
                            .padding(.horizontal, AppTheme.Spacing.xl)
                    }

                    // 底部間距
                    Color.clear
                        .frame(height: 160)
                }
            }

            // 底部操作按鈕
            VStack {
                Spacer()
                actionButtons
            }
            .ignoresSafeArea(.keyboard)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .alert("確認購買", isPresented: $showPurchaseConfirm) {
            Button("取消", role: .cancel) {}
            Button("確認購買") {
                purchaseProduct()
            }
        } message: {
            Text("確定要購買 \(quantity) 件「\(product.name)」嗎？\n總金額：NT$ \(totalPrice)")
        }
        .alert("確認兌換", isPresented: $showRedeemConfirm) {
            Button("取消", role: .cancel) {}
            Button("確認兌換") {
                redeemProduct()
            }
        } message: {
            Text("確定要兌換 \(quantity) 件「\(product.name)」嗎？\n所需福報值：\(totalMeritPoints)")
        }
    }

    // MARK: - Components

    /// 商品圖片區域
    private var productImageSection: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.white.opacity(0.1))
                .frame(height: 280)
                .overlay(
                    Image(systemName: product.category.iconName)
                        .font(.system(size: 80))
                        .foregroundColor(Color(hex: product.category.color).opacity(0.5))
                )

            // 標籤
            if !product.tags.isEmpty {
                HStack(spacing: AppTheme.Spacing.xs) {
                    ForEach(product.tags.prefix(2), id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: AppTheme.FontSize.caption, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(AppTheme.gold)
                            )
                    }
                }
                .padding(AppTheme.Spacing.lg)
            }
        }
    }

    /// 商品資訊區域
    private var productInfoSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            // 分類標籤
            HStack(spacing: 6) {
                Image(systemName: product.category.iconName)
                    .font(.system(size: 14))
                Text(product.category.rawValue)
                    .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(
                Capsule()
                    .fill(Color(hex: product.category.color))
            )

            // 商品名稱
            Text(product.name)
                .font(.system(size: AppTheme.FontSize.title1, weight: .bold))
                .foregroundColor(.white)

            // 價格資訊
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                if product.canPurchase {
                    priceRow(
                        icon: "dollarsign.circle.fill",
                        label: "購買價格",
                        value: "NT$ \(product.price)",
                        color: .green
                    )
                }

                if product.canRedeem {
                    priceRow(
                        icon: "sparkles",
                        label: "兌換價格",
                        value: "\(product.meritPointsPrice ?? 0) 福報值",
                        color: AppTheme.gold
                    )
                }

                Divider()
                    .background(Color.white.opacity(0.2))

                // 庫存狀態
                HStack {
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.6))

                    if product.inStock {
                        Text("庫存：\(product.stock) 件")
                            .font(.system(size: AppTheme.FontSize.callout))
                            .foregroundColor(.white.opacity(0.8))
                    } else {
                        Text("已售完")
                            .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                            .foregroundColor(.red)
                    }

                    Spacer()
                }
            }
            .padding(AppTheme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )

            // 商品說明
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                Text("商品說明")
                    .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                    .foregroundColor(.white)

                Text(product.description)
                    .font(.system(size: AppTheme.FontSize.callout))
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(6)
            }
            .padding(AppTheme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }

    /// 關聯廟宇區域
    private var templeSection: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "building.columns.fill")
                .font(.system(size: 20))
                .foregroundColor(AppTheme.gold)

            VStack(alignment: .leading, spacing: 4) {
                Text("關聯廟宇")
                    .font(.system(size: AppTheme.FontSize.caption))
                    .foregroundColor(.white.opacity(0.6))

                Text(product.templeName ?? "")
                    .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                    .foregroundColor(.white)
            }

            Spacer()
        }
        .padding(AppTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }

    /// 底部操作按鈕
    private var actionButtons: some View {
        VStack(spacing: 0) {
            // 漸層遮罩
            LinearGradient(
                colors: [Color.clear, AppTheme.dark],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 20)

            // 按鈕區域
            VStack(spacing: AppTheme.Spacing.md) {
                // 數量選擇
                HStack {
                    Text("數量")
                        .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    HStack(spacing: AppTheme.Spacing.md) {
                        Button(action: { if quantity > 1 { quantity -= 1 } }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(quantity > 1 ? .white : .white.opacity(0.3))
                        }
                        .disabled(quantity <= 1)

                        Text("\(quantity)")
                            .font(.system(size: AppTheme.FontSize.title3, weight: .bold))
                            .foregroundColor(.white)
                            .frame(minWidth: 40)

                        Button(action: { if quantity < product.stock { quantity += 1 } }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(quantity < product.stock ? .white : .white.opacity(0.3))
                        }
                        .disabled(quantity >= product.stock)
                    }
                }

                // 購買和兌換按鈕
                HStack(spacing: AppTheme.Spacing.md) {
                    // 現金購買按鈕
                    if product.canPurchase {
                        Button(action: { showPurchaseConfirm = true }) {
                            VStack(spacing: 4) {
                                HStack(spacing: 4) {
                                    Image(systemName: "dollarsign.circle.fill")
                                        .font(.system(size: 16))
                                    Text("購買")
                                        .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                                }

                                Text("NT$ \(totalPrice)")
                                    .font(.system(size: AppTheme.FontSize.caption, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 64)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                    .fill(LinearGradient(
                                        colors: [Color.green, Color.green.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                            )
                        }
                        .disabled(!product.inStock)
                    }

                    // 福報值兌換按鈕
                    if product.canRedeem {
                        Button(action: { showRedeemConfirm = true }) {
                            VStack(spacing: 4) {
                                HStack(spacing: 4) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 16))
                                    Text("兌換")
                                        .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                                }

                                Text("\(totalMeritPoints) 福報值")
                                    .font(.system(size: AppTheme.FontSize.caption, weight: .medium))
                            }
                            .foregroundColor(canAffordWithMerit ? AppTheme.dark : .white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 64)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                    .fill(canAffordWithMerit ? AppTheme.goldGradient : LinearGradient(colors: [Color.gray], startPoint: .leading, endPoint: .trailing))
                                    .shadow(
                                        color: canAffordWithMerit ? AppTheme.gold.opacity(0.3) : Color.clear,
                                        radius: 12,
                                        x: 0,
                                        y: 4
                                    )
                            )
                        }
                        .disabled(!product.inStock || !canAffordWithMerit)
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.xl)
            .padding(.vertical, AppTheme.Spacing.lg)
            .background(AppTheme.dark)
        }
    }

    // MARK: - Helper Components

    private func priceRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)

            Text(label)
                .font(.system(size: AppTheme.FontSize.callout))
                .foregroundColor(.white.opacity(0.6))

            Spacer()

            Text(value)
                .font(.system(size: AppTheme.FontSize.callout, weight: .bold))
                .foregroundColor(color)
        }
    }

    // MARK: - Actions

    private func purchaseProduct() {
        let record = PurchaseRecord(
            productId: product.id,
            productName: product.name,
            userId: userViewModel.user.id,
            userName: userViewModel.user.profile.name,
            quantity: quantity,
            paymentMethod: .cash,
            totalPrice: totalPrice,
            status: .paid
        )

        if userViewModel.user.purchaseRecords == nil {
            userViewModel.user.purchaseRecords = []
        }

        userViewModel.user.purchaseRecords?.append(record)
        userViewModel.saveUser()

        dismiss()
    }

    private func redeemProduct() {
        guard canAffordWithMerit else { return }

        let record = PurchaseRecord(
            productId: product.id,
            productName: product.name,
            userId: userViewModel.user.id,
            userName: userViewModel.user.profile.name,
            quantity: quantity,
            paymentMethod: .meritPoints,
            totalPrice: 0,
            meritPointsUsed: totalMeritPoints,
            status: .completed
        )

        // 扣除福報值
        userViewModel.user.cloudPassport.currentMeritPoints -= totalMeritPoints

        if userViewModel.user.purchaseRecords == nil {
            userViewModel.user.purchaseRecords = []
        }

        userViewModel.user.purchaseRecords?.append(record)
        userViewModel.saveUser()

        dismiss()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ProductDetailView(product: Product.mockProducts[0])
    }
}
