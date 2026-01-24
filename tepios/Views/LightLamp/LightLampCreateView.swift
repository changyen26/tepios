/**
 * 新增點燈頁面
 */

import SwiftUI

struct LightLampCreateView: View {
    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    let onComplete: (LightLamp) -> Void

    // MARK: - State

    @State private var selectedLampType: LampType = .brightness
    @State private var selectedTemple: Temple = Temple.mockTemples[0]
    @State private var beneficiaryName: String = ""
    @State private var hasBirthday: Bool = false
    @State private var birthday: Date = Date()
    @State private var selectedDuration: LampDuration = .oneYear
    @State private var purpose: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var currentStep: Int = 1

    @FocusState private var focusedField: Field?

    enum Field {
        case name, purpose
    }

    // MARK: - Computed Properties

    private var totalPrice: Int {
        selectedDuration.price(for: selectedLampType)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // 背景
                AppTheme.darkGradient
                    .ignoresSafeArea()
                    .onTapGesture {
                        hideKeyboard()
                    }

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        // 步驟指示器
                        stepIndicator
                            .padding(.top, AppTheme.Spacing.lg)

                        // 內容區域
                        Group {
                            switch currentStep {
                            case 1:
                                step1_SelectLampType
                            case 2:
                                step2_SelectTemple
                            case 3:
                                step3_BeneficiaryInfo
                            case 4:
                                step4_DurationAndPurpose
                            default:
                                step1_SelectLampType
                            }
                        }
                        .padding(.horizontal, AppTheme.Spacing.xl)

                        // 底部按鈕
                        bottomButtons
                            .padding(.horizontal, AppTheme.Spacing.xl)
                            .padding(.bottom, AppTheme.Spacing.xxl)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("新增點燈")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.gold)
                }
            }
            .alert("提示", isPresented: $showAlert) {
                Button("確定", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - Components

    private var stepIndicator: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            ForEach(1...4, id: \.self) { step in
                HStack(spacing: AppTheme.Spacing.xs) {
                    Circle()
                        .fill(step <= currentStep ? AppTheme.goldGradient : LinearGradient(colors: [Color.white.opacity(0.2)], startPoint: .top, endPoint: .bottom))
                        .frame(width: step == currentStep ? 12 : 8, height: step == currentStep ? 12 : 8)

                    if step < 4 {
                        Rectangle()
                            .fill(step < currentStep ? AppTheme.gold : Color.white.opacity(0.2))
                            .frame(height: 2)
                    }
                }
            }
        }
        .padding(.horizontal, AppTheme.Spacing.xl)
    }

    // MARK: - Step 1: 選擇燈種

    private var step1_SelectLampType: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            Text("選擇燈種")
                .font(.system(size: AppTheme.FontSize.title3, weight: .bold))
                .foregroundColor(.white)

            Text("不同的燈種有不同的祈福功效")
                .font(.system(size: AppTheme.FontSize.callout))
                .foregroundColor(AppTheme.whiteAlpha06)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: AppTheme.Spacing.md),
                GridItem(.flexible(), spacing: AppTheme.Spacing.md)
            ], spacing: AppTheme.Spacing.md) {
                ForEach(LampType.allCases, id: \.self) { lampType in
                    LampTypeCard(
                        lampType: lampType,
                        isSelected: selectedLampType == lampType
                    )
                    .onTapGesture {
                        selectedLampType = lampType
                    }
                }
            }
        }
    }

    // MARK: - Step 2: 選擇廟宇

    private var step2_SelectTemple: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            Text("選擇廟宇")
                .font(.system(size: AppTheme.FontSize.title3, weight: .bold))
                .foregroundColor(.white)

            Text("選擇要點燈的廟宇")
                .font(.system(size: AppTheme.FontSize.callout))
                .foregroundColor(AppTheme.whiteAlpha06)

            ForEach(Temple.mockTemples, id: \.id) { temple in
                TempleSelectionCard(
                    temple: temple,
                    isSelected: selectedTemple.id == temple.id
                )
                .onTapGesture {
                    selectedTemple = temple
                }
            }
        }
    }

    // MARK: - Step 3: 祈福對象資訊

    private var step3_BeneficiaryInfo: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            Text("祈福對象")
                .font(.system(size: AppTheme.FontSize.title3, weight: .bold))
                .foregroundColor(.white)

            Text("填寫祈福對象的基本資料")
                .font(.system(size: AppTheme.FontSize.callout))
                .foregroundColor(AppTheme.whiteAlpha06)

            // 姓名欄位
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(AppTheme.gold)
                        .frame(width: 24)

                    Text("姓名")
                        .font(.system(size: AppTheme.FontSize.callout, weight: .medium))
                        .foregroundColor(AppTheme.whiteAlpha08)
                }

                TextField("", text: $beneficiaryName, prompt: Text("請輸入姓名").foregroundColor(.white.opacity(0.6)))
                    .font(.system(size: AppTheme.FontSize.body))
                    .foregroundColor(.white)
                    .padding(AppTheme.Spacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                            .fill(Color.white.opacity(focusedField == .name ? 0.1 : 0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                    .stroke(
                                        focusedField == .name ? AppTheme.gold : AppTheme.gold.opacity(0.3),
                                        lineWidth: focusedField == .name ? 2 : 1
                                    )
                            )
                    )
                    .focused($focusedField, equals: .name)
            }

            // 生辰選項
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                Toggle(isOn: $hasBirthday) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(AppTheme.gold)
                            .frame(width: 24)

                        Text("提供生辰（選填）")
                            .font(.system(size: AppTheme.FontSize.callout, weight: .medium))
                            .foregroundColor(AppTheme.whiteAlpha08)
                    }
                }
                .tint(AppTheme.gold)

                if hasBirthday {
                    DatePicker(
                        "",
                        selection: $birthday,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .colorScheme(.dark)
                    .environment(\.locale, Locale(identifier: "zh_TW"))
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }

    // MARK: - Step 4: 點燈期間與祈福目的

    private var step4_DurationAndPurpose: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            Text("點燈期間與目的")
                .font(.system(size: AppTheme.FontSize.title3, weight: .bold))
                .foregroundColor(.white)

            // 點燈期間選擇
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(AppTheme.gold)
                        .frame(width: 24)

                    Text("點燈期間")
                        .font(.system(size: AppTheme.FontSize.callout, weight: .medium))
                        .foregroundColor(AppTheme.whiteAlpha08)
                }

                HStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(LampDuration.allCases, id: \.self) { duration in
                        DurationButton(
                            duration: duration,
                            lampType: selectedLampType,
                            isSelected: selectedDuration == duration
                        )
                        .onTapGesture {
                            selectedDuration = duration
                        }
                    }
                }
            }

            // 祈福目的
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                HStack {
                    Image(systemName: "quote.opening")
                        .foregroundColor(AppTheme.gold)
                        .frame(width: 24)

                    Text("祈福目的（選填）")
                        .font(.system(size: AppTheme.FontSize.callout, weight: .medium))
                        .foregroundColor(AppTheme.whiteAlpha08)
                }

                ZStack(alignment: .topLeading) {
                    if purpose.isEmpty && focusedField != .purpose {
                        Text("請輸入祈福目的\n例：祈求事業順利、身體健康")
                            .font(.system(size: AppTheme.FontSize.body))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .allowsHitTesting(false)
                    }

                    TextEditor(text: $purpose)
                        .font(.system(size: AppTheme.FontSize.body))
                        .foregroundColor(.white)
                        .focused($focusedField, equals: .purpose)
                        .frame(minHeight: 100)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                        .fill(Color.white.opacity(focusedField == .purpose ? 0.1 : 0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                .stroke(
                                    focusedField == .purpose ? AppTheme.gold : AppTheme.gold.opacity(0.3),
                                    lineWidth: focusedField == .purpose ? 2 : 1
                                )
                        )
                )
            }

            // 費用預覽
            VStack(spacing: AppTheme.Spacing.sm) {
                HStack {
                    Text("費用預覽")
                        .font(.system(size: AppTheme.FontSize.callout, weight: .medium))
                        .foregroundColor(AppTheme.whiteAlpha06)

                    Spacer()
                }

                HStack {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        Text(selectedLampType.rawValue)
                            .font(.system(size: AppTheme.FontSize.body))
                            .foregroundColor(.white)
                        Text(selectedDuration.rawValue)
                            .font(.system(size: AppTheme.FontSize.caption))
                            .foregroundColor(AppTheme.whiteAlpha06)
                    }

                    Spacer()

                    Text("NT$ \(totalPrice)")
                        .font(.system(size: AppTheme.FontSize.title3, weight: .bold))
                        .foregroundColor(AppTheme.gold)
                }
                .padding(AppTheme.Spacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                        .fill(AppTheme.gold.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                .stroke(AppTheme.gold.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
    }

    // MARK: - Bottom Buttons

    private var bottomButtons: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            if currentStep > 1 {
                Button(action: previousStep) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16))
                        Text("上一步")
                            .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                            .stroke(AppTheme.gold, lineWidth: 2)
                    )
                }
            }

            Button(action: nextStep) {
                HStack {
                    Text(currentStep == 4 ? "確認點燈" : "下一步")
                        .font(.system(size: AppTheme.FontSize.callout, weight: .bold))
                    if currentStep < 4 {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16))
                    }
                }
                .foregroundColor(AppTheme.dark)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(AppTheme.goldGradient)
                .cornerRadius(AppTheme.CornerRadius.md)
            }
        }
    }

    // MARK: - Methods

    private func nextStep() {
        hideKeyboard()

        if currentStep == 3 {
            // 驗證姓名
            guard !beneficiaryName.isEmpty else {
                alertMessage = "請輸入祈福對象姓名"
                showAlert = true
                return
            }
        }

        if currentStep == 4 {
            // 確認點燈
            createLamp()
        } else {
            withAnimation {
                currentStep += 1
            }
        }
    }

    private func previousStep() {
        hideKeyboard()
        withAnimation {
            currentStep -= 1
        }
    }

    private func createLamp() {
        let newLamp = LightLamp(
            lampType: selectedLampType,
            templeName: selectedTemple.name,
            templeId: selectedTemple.id,
            beneficiaryName: beneficiaryName,
            beneficiaryBirthday: hasBirthday ? birthday : nil,
            duration: selectedDuration,
            purpose: purpose
        )

        onComplete(newLamp)
        dismiss()
    }

    private func hideKeyboard() {
        focusedField = nil
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Lamp Type Card

struct LampTypeCard: View {
    let lampType: LampType
    let isSelected: Bool

    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(Color(hex: lampType.color).opacity(0.2))
                    .frame(width: 60, height: 60)

                Image(systemName: lampType.icon)
                    .font(.system(size: 28))
                    .foregroundColor(Color(hex: lampType.color))
            }

            Text(lampType.rawValue)
                .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                .foregroundColor(.white)

            Text(lampType.description)
                .font(.system(size: AppTheme.FontSize.caption2))
                .foregroundColor(AppTheme.whiteAlpha06)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                .fill(isSelected ? Color(hex: lampType.color).opacity(0.2) : Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                        .stroke(
                            isSelected ? Color(hex: lampType.color) : AppTheme.gold.opacity(0.3),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
        )
    }
}

// MARK: - Temple Selection Card

struct TempleSelectionCard: View {
    let temple: Temple
    let isSelected: Bool

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: temple.deity.iconName)
                .font(.system(size: 24))
                .foregroundColor(AppTheme.gold)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(temple.name)
                    .font(.system(size: AppTheme.FontSize.body, weight: .semibold))
                    .foregroundColor(.white)

                Text(temple.address)
                    .font(.system(size: AppTheme.FontSize.caption))
                    .foregroundColor(AppTheme.whiteAlpha06)
                    .lineLimit(1)
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.gold)
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                .fill(isSelected ? AppTheme.gold.opacity(0.1) : Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                        .stroke(
                            isSelected ? AppTheme.gold : AppTheme.gold.opacity(0.3),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
        )
    }
}

// MARK: - Duration Button

struct DurationButton: View {
    let duration: LampDuration
    let lampType: LampType
    let isSelected: Bool

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Text(duration.rawValue)
                .font(.system(size: AppTheme.FontSize.caption, weight: .semibold))
                .foregroundColor(isSelected ? AppTheme.dark : .white)

            Text("NT$ \(duration.price(for: lampType))")
                .font(.system(size: AppTheme.FontSize.caption2))
                .foregroundColor(isSelected ? AppTheme.dark : AppTheme.whiteAlpha06)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm)
                .fill(isSelected ? AppTheme.goldGradient : LinearGradient(colors: [Color.white.opacity(0.05)], startPoint: .top, endPoint: .bottom))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm)
                        .stroke(
                            isSelected ? Color.clear : AppTheme.gold.opacity(0.3),
                            lineWidth: 1
                        )
                )
        )
    }
}

// MARK: - Preview

#Preview {
    LightLampCreateView { lamp in
        print("Created lamp: \(lamp.lampType.rawValue)")
    }
}
