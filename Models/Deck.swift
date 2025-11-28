import Foundation

struct Deck: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var emoji: String
    var colorHex: String
    var cards: [Card]
    var isBuiltIn: Bool
    var ageRating: String?
    
    init(id: UUID = UUID(), name: String, emoji: String, colorHex: String, cards: [Card], isBuiltIn: Bool = false, ageRating: String? = nil) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.colorHex = colorHex
        self.cards = cards
        self.isBuiltIn = isBuiltIn
        self.ageRating = ageRating
    }
    
    var cardCount: Int {
        cards.count
    }
}
