/**
 * 派系（神明）選擇頁面
 * 在註冊後讓使用者選擇所信奉的神明
 */

import SwiftUI

struct DeitySelectionView: View {
    // MARK: - Properties

    @Binding var selectedDeity: Deity?
    var onComplete: () -> Void

    // MARK: - State

    @State private var deities = Deity.allDeities

    // MARK: - Body

    var body: some View {
        ZStack {
            // 背景漸層
            AppTheme.darkGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    // 標題區域
                    VStack(spacing: AppTheme.Spacing.md) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 60))
                            .foregroundStyle(AppTheme.goldGradient)
                            .shadow(
                                color: AppTheme.gold.opacity(0.5),
                                radius: 20,
                                x: 0,
                                y: 10
                            )

                        Text("選擇您的信仰")
                            .font(.system(size: AppTheme.FontSize.title1, weight: .bold))
                            .foregroundColor(AppTheme.gold)
                            .tracking(2)

                        Text("選擇您所信奉的神明，獲得專屬庇佑")
                            .font(.system(size: AppTheme.FontSize.callout))
                            .foregroundColor(AppTheme.whiteAlpha06)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 60)
                    .padding(.horizontal, AppTheme.Spacing.xxl)

                    // 神明選擇列表
                    VStack(spacing: AppTheme.Spacing.md) {
                        ForEach(deities) { deity in
                            DeitySelectionCard(
                                deity: deity,
                                isSelected: selectedDeity?.id == deity.id,
                                onTap: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedDeity = deity
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.xxl)

                    // 確認按鈕
                    Button(action: {
                        onComplete()
                    }) {
                        Text("確認選擇")
                            .font(.system(size: AppTheme.FontSize.headline, weight: .semibold))
                            .foregroundColor(AppTheme.dark)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                selectedDeity != nil ?
                                    AppTheme.goldGradient :
                                    LinearGradient(
                                        colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                            )
                            .cornerRadius(AppTheme.CornerRadius.md)
                            .shadow(
                                color: selectedDeity != nil ? AppTheme.gold.opacity(0.3) : Color.clear,
                                radius: 12,
                                x: 0,
                                y: 4
                            )
                    }
                    .disabled(selectedDeity == nil)
                    .padding(.horizontal, AppTheme.Spacing.xxl)
                    .padding(.top, AppTheme.Spacing.lg)

                    // 跳過按鈕
                    Button(action: {
                        selectedDeity = nil
                        onComplete()
                    }) {
                        Text("暫時跳過")
                            .font(.system(size: AppTheme.FontSize.callout))
                            .foregroundColor(AppTheme.whiteAlpha06)
                            .underline()
                    }
                    .padding(.bottom, AppTheme.Spacing.xxl)
                }
            }
        }
    }
}

// MARK: - Deity Selection Card Component

struct DeitySelectionCard: View {
    let deity: Deity
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppTheme.Spacing.lg) {
                // 神明圖標
                ZStack {
                    Circle()
                        .fill(Color(hex: deity.color).opacity(0.2))
                        .frame(width: 60, height: 60)

                    Image(systemName: deity.iconName)
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: deity.color))
                }

                // 神明資訊
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(deity.displayName)
                        .font(.system(size: AppTheme.FontSize.headline, weight: .semibold))
                        .foregroundColor(AppTheme.white)

                    Text(deity.description)
                        .font(.system(size: AppTheme.FontSize.caption))
                        .foregroundColor(AppTheme.whiteAlpha06)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    // 屬性標籤
                    HStack(spacing: AppTheme.Spacing.xs) {
                        ForEach(deity.attributes, id: \.self) { attribute in
                            Text(attribute)
                                .font(.system(size: AppTheme.FontSize.caption2))
                                .foregroundColor(Color(hex: deity.color))
                                .padding(.horizontal, AppTheme.Spacing.sm)
                                .padding(.vertical, AppTheme.Spacing.xs)
                                .background(
                                    Capsule()
                                        .fill(Color(hex: deity.color).opacity(0.2))
                                )
                        }
                    }
                    .padding(.top, 2)
                }

                Spacer()

                // 選中標記
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppTheme.gold)
                }
            }
            .padding(AppTheme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                    .fill(Color.white.opacity(isSelected ? 0.15 : 0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                            .stroke(
                                isSelected ? AppTheme.gold : Color.white.opacity(0.1),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .shadow(
                color: isSelected ? AppTheme.gold.opacity(0.2) : Color.clear,
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    DeitySelectionView(
        selectedDeity: .constant(nil),
        onComplete: {}
    )
}
