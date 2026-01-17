/**
 * 活動詳情頁面
 * 顯示活動的完整資訊和報名按鈕
 */

import SwiftUI

struct EventDetailView: View {
    // MARK: - Properties

    let event: Event

    @StateObject private var userViewModel = UserProfileViewModel.shared
    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    @State private var showRegistrationConfirm = false
    @State private var showCancelConfirm = false
    @State private var registrationNotes = ""

    // MARK: - Computed Properties

    private var isRegistered: Bool {
        userViewModel.user.eventRegistrations?.contains { $0.eventId == event.id } ?? false
    }

    private var currentRegistration: EventRegistration? {
        userViewModel.user.eventRegistrations?.first { $0.eventId == event.id }
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // 背景漸層
            AppTheme.darkGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    // 活動頭部
                    eventHeader

                    // 活動詳細資訊
                    eventDetailsSection
                        .padding(.horizontal, AppTheme.Spacing.xl)

                    // 報名條件
                    if !event.requirements.isEmpty {
                        requirementsSection
                            .padding(.horizontal, AppTheme.Spacing.xl)
                    }

                    // 主辦單位資訊
                    organizerSection
                        .padding(.horizontal, AppTheme.Spacing.xl)

                    // 底部間距（預留按鈕高度 + 額外空間）
                    Color.clear
                        .frame(height: 160)
                }
            }

            // 底部報名按鈕
            VStack {
                Spacer()
                registrationButton
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
        .alert("確認報名", isPresented: $showRegistrationConfirm) {
            Button("取消", role: .cancel) {}
            Button("確認") {
                registerForEvent()
            }
        } message: {
            Text("確定要報名「\(event.title)」嗎？")
        }
        .alert("取消報名", isPresented: $showCancelConfirm) {
            Button("返回", role: .cancel) {}
            Button("確認取消", role: .destructive) {
                cancelRegistration()
            }
        } message: {
            Text("確定要取消報名嗎？此操作無法復原。")
        }
    }

    // MARK: - Components

    /// 活動頭部
    private var eventHeader: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            // 分類和狀態
            HStack {
                // 分類標籤
                HStack(spacing: 6) {
                    Image(systemName: event.category.iconName)
                        .font(.system(size: 14))
                    Text(event.category.rawValue)
                        .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(
                    Capsule()
                        .fill(Color(hex: event.category.color))
                )

                Spacer()

                // 狀態標籤
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: event.status.color))
                        .frame(width: 8, height: 8)

                    Text(event.status.rawValue)
                        .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                        .foregroundColor(Color(hex: event.status.color))
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(
                    Capsule()
                        .fill(Color(hex: event.status.color).opacity(0.2))
                )
            }
            .padding(.horizontal, AppTheme.Spacing.xl)

            // 活動標題
            Text(event.title)
                .font(.system(size: AppTheme.FontSize.title1, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, AppTheme.Spacing.xl)

            // 廟宇名稱（如果有）
            if let templeName = event.templeName {
                HStack(spacing: 6) {
                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.gold)

                    Text(templeName)
                        .font(.system(size: AppTheme.FontSize.headline, weight: .medium))
                        .foregroundColor(AppTheme.gold)
                }
                .padding(.horizontal, AppTheme.Spacing.xl)
            }
        }
        .padding(.top, AppTheme.Spacing.xl)
    }

    /// 活動詳細資訊
    private var eventDetailsSection: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // 活動描述
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                sectionTitle("活動說明")

                Text(event.description)
                    .font(.system(size: AppTheme.FontSize.callout))
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(6)
            }

            Divider()
                .background(Color.white.opacity(0.2))

            // 時間地點資訊
            VStack(spacing: AppTheme.Spacing.md) {
                infoRow(
                    icon: "calendar",
                    title: "活動日期",
                    value: event.dateRangeString
                )

                infoRow(
                    icon: "location.fill",
                    title: "活動地點",
                    value: event.location
                )

                if let maxParticipants = event.maxParticipants {
                    infoRow(
                        icon: "person.3.fill",
                        title: "活動名額",
                        value: "\(event.currentParticipants) / \(maxParticipants) 人"
                    )
                }

                infoRow(
                    icon: "dollarsign.circle.fill",
                    title: "報名費用",
                    value: event.fee > 0 ? "NT$ \(event.fee)" : "免費"
                )

                if event.meritPointsReward > 0 {
                    infoRow(
                        icon: "sparkles",
                        title: "福報值獎勵",
                        value: "+\(event.meritPointsReward) 點",
                        iconColor: AppTheme.gold
                    )
                }
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
    }

    /// 報名條件區域
    private var requirementsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            sectionTitle("報名條件")

            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                ForEach(event.requirements, id: \.self) { requirement in
                    requirementRow(requirement)
                }
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
    }

    /// 主辦單位資訊
    private var organizerSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            sectionTitle("主辦單位")

            VStack(spacing: AppTheme.Spacing.md) {
                infoRow(
                    icon: "person.fill",
                    title: "主辦方",
                    value: event.organizer
                )

                infoRow(
                    icon: "phone.fill",
                    title: "聯絡方式",
                    value: event.contactInfo
                )
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
    }

    /// 報名按鈕
    private var registrationButton: some View {
        VStack(spacing: 0) {
            // 漸層遮罩
            LinearGradient(
                colors: [Color.clear, AppTheme.dark],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 20)

            // 按鈕區域
            VStack(spacing: 0) {
                if isRegistered {
                    // 已報名狀態
                    VStack(spacing: AppTheme.Spacing.md) {
                        if let registration = currentRegistration {
                            registrationStatusInfo(registration)
                        }

                        Button(action: { showCancelConfirm = true }) {
                            Text("取消報名")
                                .font(.system(size: AppTheme.FontSize.headline, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                        .fill(Color.red.opacity(0.8))
                                )
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .padding(.vertical, AppTheme.Spacing.lg)
                } else {
                    // 未報名狀態
                    Button(action: { showRegistrationConfirm = true }) {
                        Text(registrationButtonText)
                            .font(.system(size: AppTheme.FontSize.headline, weight: .semibold))
                            .foregroundColor(event.canRegister ? AppTheme.dark : .white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                    .fill(event.canRegister ? AppTheme.goldGradient : LinearGradient(colors: [Color.gray], startPoint: .leading, endPoint: .trailing))
                                    .shadow(
                                        color: event.canRegister ? AppTheme.gold.opacity(0.3) : Color.clear,
                                        radius: 12,
                                        x: 0,
                                        y: 4
                                    )
                            )
                    }
                    .disabled(!event.canRegister)
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .padding(.vertical, AppTheme.Spacing.lg)
                }
            }
            .background(AppTheme.dark)
        }
    }

    /// 報名狀態資訊
    private func registrationStatusInfo(_ registration: EventRegistration) -> some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(.green)

            VStack(alignment: .leading, spacing: 2) {
                Text("已報名")
                    .font(.system(size: AppTheme.FontSize.callout, weight: .semibold))
                    .foregroundColor(.white)

                Text("狀態：\(registration.status.rawValue)")
                    .font(.system(size: AppTheme.FontSize.caption))
                    .foregroundColor(Color(hex: registration.status.color))
            }

            Spacer()
        }
        .padding(AppTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private var registrationButtonText: String {
        if event.isFull {
            return "名額已滿"
        } else if event.status == .ended {
            return "活動已結束"
        } else if event.status == .ongoing {
            return "活動進行中"
        } else {
            return "立即報名"
        }
    }

    // MARK: - Helper Components

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: AppTheme.FontSize.headline, weight: .bold))
            .foregroundColor(.white)
    }

    private func infoRow(
        icon: String,
        title: String,
        value: String,
        iconColor: Color = .white
    ) -> some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(iconColor.opacity(0.8))
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: AppTheme.FontSize.caption))
                    .foregroundColor(.white.opacity(0.6))

                Text(value)
                    .font(.system(size: AppTheme.FontSize.callout, weight: .medium))
                    .foregroundColor(.white)
            }

            Spacer()
        }
    }

    private func requirementRow(_ requirement: String) -> some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.md) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18))
                .foregroundColor(AppTheme.gold.opacity(0.8))
                .frame(width: 24)

            Text(requirement)
                .font(.system(size: AppTheme.FontSize.callout))
                .foregroundColor(.white.opacity(0.8))

            Spacer()
        }
    }

    // MARK: - Actions

    private func registerForEvent() {
        let registration = EventRegistration(
            eventId: event.id,
            eventTitle: event.title,
            userId: userViewModel.user.id,
            userName: userViewModel.user.profile.name,
            status: .confirmed,
            notes: registrationNotes.isEmpty ? nil : registrationNotes
        )

        if userViewModel.user.eventRegistrations == nil {
            userViewModel.user.eventRegistrations = []
        }

        userViewModel.user.eventRegistrations?.append(registration)
        userViewModel.saveUser()
    }

    private func cancelRegistration() {
        userViewModel.user.eventRegistrations?.removeAll { $0.eventId == event.id }
        userViewModel.saveUser()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        EventDetailView(event: Event.mockEvents[0])
    }
}
