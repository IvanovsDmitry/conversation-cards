import Foundation
import SwiftUI

final class DeckManager: ObservableObject {
    @Published var decks: [Deck] = []
    
    private let decksKey = "saved_decks"
    
    init() {
        loadDecks()
        if decks.isEmpty {
            initializeBuiltInDecks()
        }
    }
    
    func loadDecks() {
        guard let data = UserDefaults.standard.data(forKey: decksKey) else { return }
        if let decoded = try? JSONDecoder().decode([Deck].self, from: data) {
            decks = decoded
        }
    }
    
    func saveDecks() {
        if let encoded = try? JSONEncoder().encode(decks) {
            UserDefaults.standard.set(encoded, forKey: decksKey)
        }
    }
    
    func addDeck(_ deck: Deck) {
        decks.append(deck)
        saveDecks()
    }
    
    func updateDeck(_ deck: Deck) {
        guard let index = decks.firstIndex(where: { $0.id == deck.id }) else { return }
        decks[index] = deck
        saveDecks()
    }
    
    func deleteDeck(_ deck: Deck) {
        decks.removeAll { $0.id == deck.id }
        saveDecks()
    }
    
    func deleteCard(_ card: Card, from deck: Deck) {
        guard let deckIndex = decks.firstIndex(where: { $0.id == deck.id }) else { return }
        decks[deckIndex].cards.removeAll { $0.id == card.id }
        saveDecks()
    }
    
    func addCard(_ card: Card, to deck: Deck) {
        guard let deckIndex = decks.firstIndex(where: { $0.id == deck.id }) else { return }
        decks[deckIndex].cards.append(card)
        saveDecks()
    }
    
    func initializeBuiltInDecks() {
        decks = BuiltInDecks.allDecks
        saveDecks()
    }
}
