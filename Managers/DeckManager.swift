import Foundation
import SwiftUI

class DeckManager: ObservableObject {
    @Published var decks: [Deck] = []
    
    private let decksKey = "saved_decks"
    private let builtInDecksVersionKey = "built_in_decks_version"
    private let currentBuiltInDecksVersion = 3 // Увеличиваем при обновлении встроенных колод (версия 3 = 100 карт в каждой колоде)
    
    init() {
        loadDecks()
        if decks.isEmpty {
            initializeBuiltInDecks()
        } else {
            updateBuiltInDecksIfNeeded()
        }
    }
    
    func loadDecks() {
        if let data = UserDefaults.standard.data(forKey: decksKey),
           let decoded = try? JSONDecoder().decode([Deck].self, from: data) {
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
        if let index = decks.firstIndex(where: { $0.id == deck.id }) {
            decks[index] = deck
            saveDecks()
        }
    }
    
    func deleteDeck(_ deck: Deck) {
        decks.removeAll { $0.id == deck.id }
        saveDecks()
    }
    
    func deleteCard(_ card: Card, from deck: Deck) {
        if let deckIndex = decks.firstIndex(where: { $0.id == deck.id }) {
            decks[deckIndex].cards.removeAll { $0.id == card.id }
            saveDecks()
        }
    }
    
    func addCard(_ card: Card, to deck: Deck) {
        if let deckIndex = decks.firstIndex(where: { $0.id == deck.id }) {
            decks[deckIndex].cards.append(card)
            saveDecks()
        }
    }
    
    func initializeBuiltInDecks() {
        decks = BuiltInDecks.allDecks
        saveDecks()
        UserDefaults.standard.set(currentBuiltInDecksVersion, forKey: builtInDecksVersionKey)
    }
    
    func updateBuiltInDecksIfNeeded() {
        let savedVersion = UserDefaults.standard.integer(forKey: builtInDecksVersionKey)
        
        // Если версия не совпадает или это первая загрузка, обновляем встроенные колоды
        if savedVersion < currentBuiltInDecksVersion {
            let builtInDecks = BuiltInDecks.allDecks
            let userDecks = decks.filter { !$0.isBuiltIn }
            
            // Заменяем все встроенные колоды новыми версиями (по имени, так как ID могут отличаться)
            var updatedDecks: [Deck] = []
            let existingBuiltInNames = Set(decks.filter { $0.isBuiltIn }.map { $0.name })
            
            for builtInDeck in builtInDecks {
                // Всегда добавляем новую версию встроенной колоды
                updatedDecks.append(builtInDeck)
            }
            
            // Добавляем пользовательские колоды
            updatedDecks.append(contentsOf: userDecks)
            
            decks = updatedDecks
            saveDecks()
            UserDefaults.standard.set(currentBuiltInDecksVersion, forKey: builtInDecksVersionKey)
        } else {
            // Проверяем, все ли встроенные колоды на месте
            let builtInDecks = BuiltInDecks.allDecks
            let existingBuiltInNames = Set(decks.filter { $0.isBuiltIn }.map { $0.name })
            let requiredBuiltInNames = Set(builtInDecks.map { $0.name })
            
            // Находим недостающие колоды
            let missingNames = requiredBuiltInNames.subtracting(existingBuiltInNames)
            let missingDecks = builtInDecks.filter { missingNames.contains($0.name) }
            
            if !missingDecks.isEmpty {
                // Добавляем недостающие встроенные колоды
                decks.append(contentsOf: missingDecks)
                saveDecks()
            }
        }
    }
    
    // Метод для принудительного обновления всех встроенных колод
    func forceUpdateBuiltInDecks() {
        let builtInDecks = BuiltInDecks.allDecks
        let userDecks = decks.filter { !$0.isBuiltIn }
        
        // Заменяем все встроенные колоды новыми версиями
        decks = builtInDecks + userDecks
        saveDecks()
        UserDefaults.standard.set(currentBuiltInDecksVersion, forKey: builtInDecksVersionKey)
    }
}

