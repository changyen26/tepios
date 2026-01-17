/**
 * 產品展示頁面（帶 iPhone 框架）
 * 用於官網錄製和展示
 */

import SwiftUI

struct ProductShowcaseView: View {
    var body: some View {
        ZStack {
            // 精美背景
            LinearGradient(
                colors: [
                    Color(hex: "#1a1a2e"),
                    Color(hex: "#16213e"),
                    Color(hex: "#0f3460")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // iPhone 框架
            iPhoneFrame {
                // 內容：產品介紹頁面
                ProductIntroView()
            }
        }
    }

    // MARK: - iPhone Frame

    @ViewBuilder
    func iPhoneFrame<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ZStack {
            // iPhone 外框
            RoundedRectangle(cornerRadius: 55)
                .fill(Color.black)
                .frame(width: 400, height: 820)
                .shadow(color: .black.opacity(0.5), radius: 40, x: 0, y: 20)

            // 螢幕區域
            RoundedRectangle(cornerRadius: 47)
                .fill(Color.black)
                .frame(width: 380, height: 800)
                .overlay(
                    RoundedRectangle(cornerRadius: 47)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                )

            // 實際內容
            content()
                .frame(width: 380, height: 800)
                .clipShape(RoundedRectangle(cornerRadius: 47))

            // Dynamic Island
            VStack {
                Capsule()
                    .fill(Color.black)
                    .frame(width: 120, height: 35)
                    .padding(.top, 15)

                Spacer()
            }
            .frame(width: 380, height: 800)
        }
        .scaleEffect(0.8) // 縮小以適應畫面
    }
}

// MARK: - Preview

#Preview {
    ProductShowcaseView()
}
