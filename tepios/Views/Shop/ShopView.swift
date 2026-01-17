/**
 * 商城列表頁面
 * 顯示所有可購買的商品，支援分類篩選和購買/兌換功能
 */

import SwiftUI

struct ShopView: View {
    // MARK: - State

    @Environment(\.dismiss) private var dismiss
    @StateObject private var userViewModel = UserProfileViewModel.shared
    @State private var selectedCategory: ProductCategory? = nil
    @State private var selectedProduct: Product? = nil
    @State private var showProductDetail = false

    // MARK: - Computed Properties

    private var filteredProducts: [Product] {
        let products = Product.mockProducts

        if let category = selectedCategory {
            return products.filter { $0.category == category }
        }

        return products
    }

    private var availableMeritPoints: Int {
        return userViewModel.user.cloudPassport.currentMeritPoints
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // 背景漸層
                AppTheme.darkGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        // 福報值顯示
                        meritPointsHeader
                            .padding(.horizontal, AppTheme.Spacing.xl)
                            .padding(.top, AppTheme.Spacing.md)

                        // 分類篩選
                        categoryFilterSection
                            .padding(.top, AppTheme.Spacing.sm)

                        // 商品網格
                        if filteredProducts.isEmpty {
                            emptyState
                        } else {
                            productsGrid
                                .padding(.horizontal, AppTheme.Spacing.xl)
                        }

                        // 底部間距
                        Color.clear
                            .frame(height: AppTheme.Spacing.xxxl)
                    }
                }
            }
            .navigationTitle("福報商城")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("返回")
                                .font(.system(size: AppTheme.FontSize.body))
                        }
                        .foregroundColor(AppTheme.gold)
                    }
                }
            }
            .sheet(isPresented: $showProductDetail) {
                if let product = selectedProduct {
                    ProductDetailView(product: product)
                }
            }
        }
    }

    // MARK: - Components

    /// 福報值顯示頭部
    private var meritPointsHeader: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "sparkles")
                .font(.system(size: 24))
                .foregroundColor(AppTheme.gold)

            VStack(alignment: .leading, spacing: 4) {
                Text("可用福報值")
                    .font(.system(size: AppTheme.FontSize.caption))
                    .foregroundColor(.white.opacity(0.6))

                Text("\(availableMeritPoints)")
                    .font(.system(size: AppTheme.FontSize.title2, weight: .bold))
                    .foregroundColor(AppTheme.gold)
            }

            Spacer()

            NavigationLink(destination: EmptyView()) {
                HStack(spacing: 4) {
                    Text("兌換紀錄")
                        .font(.system(size: AppTheme.FontSize.callout, weight: .medium))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                }
                .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(AppTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                        .stroke(AppTheme.gold.opacity(0.3), lineWidth: 1)
                )
        )
    }

    /// 分類篩選區域
    private var categoryFilterSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("商品分類")
                .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, AppTheme.Spacing.xl)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    // 全部按鈕
                    categoryChip(
                        title: "全部",
                        isSelected: selectedCategory == nil
                    ) {
                        selectedCategory = nil
                    }

                    // 各分類按鈕
                    ForEach(ProductCategory.allCases, id: \.self) { category in
                        categoryChip(
                            title: category.rawValue,
                            iconName: category.iconName,
                            color: Color(hex: category.color),
                            isSelected: selectedCategory == category
                        ) {
                            if selectedCategory == category {
                                selectedCategory = nil
                            } else {
                                selectedCategory = category
                            }
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.xl)
            }
        }
    }

    /// 分類按鈕
    private func categoryChip(
        title: String,
        iconName: String? = nil,
        color: Color = AppTheme.gold,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.xs) {
                if let icon = iconName {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                }

                Text(title)
                    .font(.system(size: AppTheme.FontSize.callout, weight: .medium))
            }
            .foregroundColor(isSelected ? AppTheme.dark : .white)
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(
                Capsule()
                    .fill(isSelected ? color : Color.white.opacity(0.1))
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : color.opacity(0.3), lineWidth: 1)
            )
        }
    }

    /// 商品網格
    private var productsGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: AppTheme.Spacing.md),
                GridItem(.flexible(), spacing: AppTheme.Spacing.md)
            ],
            spacing: AppTheme.Spacing.md
        ) {
            ForEach(filteredProducts) { product in
                productCard(product)
                    .onTapGesture {
                        selectedProduct = product
                        showProductDetail = true
                    }
            }
        }
    }

    /// 商品卡片
    private func productCard(_ product: Product) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            // 商品圖片區域
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                    .fill(Color.white.opacity(0.1))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        Image(systemName: product.category.iconName)
                            .font(.system(size: 40))
                            .foregroundColor(Color(hex: product.category.color).opacity(0.5))
                    )

                // 標籤
                if !product.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(product.tags.prefix(1), id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: AppTheme.FontSize.caption, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(AppTheme.gold)
                                )
                        }
                    }
                    .padding(AppTheme.Spacing.sm)
                }
            }

            // 商品資訊
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .frame(height: 36)

                // 價格資訊
                if product.canPurchase && product.canRedeem {
                    // 可購買也可兌換
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.green)
                            Text("NT$ \(product.price)")
                                .font(.system(size: AppTheme.FontSize.caption, weight: .semibold))
                                .foregroundColor(.white)
                        }

                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.gold)
                            Text("\(product.meritPointsPrice ?? 0) 福報值")
                                .font(.system(size: AppTheme.FontSize.caption, weight: .semibold))
                                .foregroundColor(AppTheme.gold)
                        }
                    }
                } else if product.canPurchase {
                    // 僅可購買
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                        Text("NT$ \(product.price)")
                            .font(.system(size: AppTheme.FontSize.callout, weight: .bold))
                            .foregroundColor(.white)
                    }
                } else if product.canRedeem {
                    // 僅可兌換
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.gold)
                        Text("\(product.meritPointsPrice ?? 0) 福報值")
                            .font(.system(size: AppTheme.FontSize.callout, weight: .bold))
                            .foregroundColor(AppTheme.gold)
                    }
                } else {
                    Text("暫不可購買")
                        .font(.system(size: AppTheme.FontSize.caption))
                        .foregroundColor(.white.opacity(0.5))
                }

                // 庫存狀態
                if !product.inStock {
                    Text("已售完")
                        .font(.system(size: AppTheme.FontSize.caption, weight: .medium))
                        .foregroundColor(.red)
                } else if product.stock < 10 {
                    Text("僅剩 \(product.stock) 件")
                        .font(.system(size: AppTheme.FontSize.caption))
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(AppTheme.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }

    /// 空狀態
    private var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "bag.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.gold.opacity(0.5))

            Text("目前沒有相關商品")
                .font(.system(size: AppTheme.FontSize.headline, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.top, AppTheme.Spacing.xxxl)
    }
}

// MARK: - Preview

#Preview {
    ShopView()
}
