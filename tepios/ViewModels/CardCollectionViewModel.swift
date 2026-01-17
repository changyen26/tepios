/**
 * 卡牌收集管理 ViewModel
 * 管理神明卡牌的收集、抽卡、升級等功能
 */

import Foundation
import SwiftUI
import Combine

class CardCollectionViewModel: ObservableObject {
    // MARK: - Singleton

    static let shared = CardCollectionViewModel()

    // MARK: - Published Properties

    @Published var allCards: [DeityCard] = DeityCard.mockCards
    @Published var userViewModel = UserProfileViewModel.shared

    // MARK: - Computed Properties

    /// 已收集的卡牌
    var collectedCards: [CollectedCard] {
        return userViewModel.user.collectedCards
    }

    /// 收集進度百分比
    var collectionProgress: Double {
        guard !allCards.isEmpty else { return 0 }
        let uniqueCollectedCount = Set(collectedCards.map { $0.cardId }).count
        return Double(uniqueCollectedCount) / Double(allCards.count) * 100
    }

    /// 已收集的卡牌數量
    var collectedCount: Int {
        return Set(collectedCards.map { $0.cardId }).count
    }

    /// 總卡牌數量
    var totalCardCount: Int {
        return allCards.count
    }

    // MARK: - Methods

    /// 檢查是否已收集某張卡牌
    func isCardCollected(_ cardId: String) -> Bool {
        return collectedCards.contains(where: { $0.cardId == cardId })
    }

    /// 獲取已收集的卡牌
    func getCollectedCard(_ cardId: String) -> CollectedCard? {
        return collectedCards.first(where: { $0.cardId == cardId })
    }

    /// 獲取卡牌詳情
    func getCard(_ cardId: String) -> DeityCard? {
        return allCards.first(where: { $0.id == cardId })
    }

    /// 添加新卡牌到收藏
    func collectCard(_ card: DeityCard, method: ObtainMethod) {
        // 檢查是否已經收集過
        if let existingCard = collectedCards.first(where: { $0.cardId == card.id }) {
            // 已收集，升級卡牌
            upgradeCard(existingCard.id)
        } else {
            // 新卡牌，添加到收藏
            let newCollectedCard = CollectedCard(cardId: card.id, obtainMethod: method)
            userViewModel.user.collectedCards.append(newCollectedCard)
            userViewModel.saveUser()
        }
    }

    /// 升級卡牌
    func upgradeCard(_ collectedCardId: String) {
        if let index = userViewModel.user.collectedCards.firstIndex(where: { $0.id == collectedCardId }) {
            userViewModel.user.collectedCards[index].level += 1
            userViewModel.saveUser()
        }
    }

    /// 設置/取消最愛
    func toggleFavorite(_ collectedCardId: String) {
        if let index = userViewModel.user.collectedCards.firstIndex(where: { $0.id == collectedCardId }) {
            userViewModel.user.collectedCards[index].isFavorite.toggle()
            userViewModel.saveUser()
        }
    }

    /// 福報值抽卡
    func gachaCard(costPoints: Int) -> DeityCard? {
        // 檢查福報值是否足夠
        guard userViewModel.user.cloudPassport.currentMeritPoints >= costPoints else {
            return nil
        }

        // 扣除福報值
        userViewModel.user.cloudPassport.currentMeritPoints -= costPoints

        // 抽取卡牌
        let drawnCard = drawRandomCard()

        // 添加到收藏
        collectCard(drawnCard, method: .gacha)

        userViewModel.saveUser()

        return drawnCard
    }

    /// 根據稀有度機率抽取隨機卡牌
    private func drawRandomCard() -> DeityCard {
        let random = Double.random(in: 0...100)
        var cumulative = 0.0

        // 依照稀有度機率抽卡
        for rarity in [CardRarity.mythical, .legendary, .epic, .rare, .common] {
            cumulative += rarity.dropRate
            if random <= cumulative {
                let cardsOfRarity = allCards.filter { $0.rarity == rarity }
                return cardsOfRarity.randomElement() ?? allCards.randomElement()!
            }
        }

        // 保底返回普通卡
        return allCards.filter { $0.rarity == .common }.randomElement() ?? allCards[0]
    }

    /// 打卡廟宇獲得對應神明卡牌
    func checkInReward(templeId: String) -> DeityCard? {
        // 找到與該廟宇相關的卡牌
        let relatedCards = allCards.filter { $0.templeIds.contains(templeId) }

        guard !relatedCards.isEmpty else { return nil }

        // 首次打卡必定獲得，之後有 30% 機率獲得稀有版本
        let card = relatedCards.randomElement()!
        collectCard(card, method: .checkIn)

        return card
    }

    /// 根據稀有度篩選卡牌
    func cardsByRarity(_ rarity: CardRarity) -> [DeityCard] {
        return allCards.filter { $0.rarity == rarity }
    }

    /// 根據類型篩選卡牌
    func cardsByType(_ type: DeityType) -> [DeityCard] {
        return allCards.filter { $0.type == type }
    }

    /// 獲取最愛的卡牌
    var favoriteCards: [CollectedCard] {
        return collectedCards.filter { $0.isFavorite }
    }

    /// 獲取收集統計
    func getCollectionStats() -> [CardRarity: (collected: Int, total: Int)] {
        var stats: [CardRarity: (collected: Int, total: Int)] = [:]

        for rarity in CardRarity.allCases {
            let totalOfRarity = allCards.filter { $0.rarity == rarity }.count
            let collectedOfRarity = Set(collectedCards.compactMap { collectedCard -> String? in
                guard let card = getCard(collectedCard.cardId) else { return nil }
                return card.rarity == rarity ? collectedCard.cardId : nil
            }).count

            stats[rarity] = (collected: collectedOfRarity, total: totalOfRarity)
        }

        return stats
    }
}
