import Foundation
import SwiftUI

class DeckManager: ObservableObject {
    @Published var decks: [Deck] = []
    
    private let decksKey = "saved_decks"
    private let builtInDecksVersionKey = "built_in_decks_version"
    private let currentBuiltInDecksVersion = 2 // Увеличиваем при обновлении встроенных колод
    
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
            var updatedDecks: [Deck] = []
            
            // Обновляем встроенные колоды
            for builtInDeck in builtInDecks {
                if let existingIndex = decks.firstIndex(where: { $0.id == builtInDeck.id && $0.isBuiltIn }) {
                    // Обновляем существующую встроенную колоду
                    updatedDecks.append(builtInDeck)
                } else if decks.firstIndex(where: { $0.name == builtInDeck.name && $0.isBuiltIn }) != nil {
                    // Если колода с таким именем существует, заменяем её
                    updatedDecks.append(builtInDeck)
                } else {
                    // Добавляем новую встроенную колоду
                    updatedDecks.append(builtInDeck)
                }
            }
            
            // Сохраняем пользовательские колоды
            let userDecks = decks.filter { !$0.isBuiltIn }
            updatedDecks.append(contentsOf: userDecks)
            
            decks = updatedDecks
            saveDecks()
            UserDefaults.standard.set(currentBuiltInDecksVersion, forKey: builtInDecksVersionKey)
        } else {
            // Проверяем, все ли встроенные колоды на месте
            let builtInDecks = BuiltInDecks.allDecks
            var missingDecks: [Deck] = []
            
            for builtInDeck in builtInDecks {
                if !decks.contains(where: { $0.id == builtInDeck.id && $0.isBuiltIn }) &&
                   !decks.contains(where: { $0.name == builtInDeck.name && $0.isBuiltIn }) {
                    missingDecks.append(builtInDeck)
                }
            }
            
            if !missingDecks.isEmpty {
                // Добавляем недостающие встроенные колоды
                decks.append(contentsOf: missingDecks)
                saveDecks()
            }
        }
    }
}

