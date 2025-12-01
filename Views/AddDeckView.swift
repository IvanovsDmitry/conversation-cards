import SwiftUI

struct AddDeckView: View {
    @ObservedObject var deckManager: DeckManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var deckName: String = ""
    @State private var emoji: String = "📚"
    @State private var colorHex: String = "#007AFF"
    @State private var questionsText: String = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    let emojiOptions = ["📚", "💬", "🎯", "❤️", "🌟", "🎨", "🎪", "🎭", "🎲", "🎁"]
    let colorOptions = [
        "#FF6B6B", "#4ECDC4", "#95E1D3", "#F38181", "#AA96DA",
        "#FF6B9D", "#007AFF", "#34C759", "#FF9500", "#AF52DE"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Основная информация")) {
                    TextField("Название колоды", text: $deckName)
                    
                    Picker("Эмодзи", selection: $emoji) {
                        ForEach(emojiOptions, id: \.self) { emoji in
                            Text(emoji).tag(emoji)
                        }
                    }
                    
                    Picker("Цвет", selection: $colorHex) {
                        ForEach(colorOptions, id: \.self) { color in
                            HStack {
                                Circle()
                                    .fill(Color(hex: color) ?? .blue)
                                    .frame(width: 20, height: 20)
                                Text(color)
                            }
                            .tag(color)
                        }
                    }
                }
                
                Section(header: Text("Вопросы"), footer: Text("Формат: основной вопрос || дополнительный вопрос\nКаждая пара на новой строке")) {
                    TextEditor(text: $questionsText)
                        .frame(minHeight: 200)
                }
            }
            .navigationTitle("Новая колода")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveDeck()
                    }
                    .disabled(deckName.isEmpty || questionsText.isEmpty)
                }
            }
            .alert("Ошибка", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveDeck() {
        let cards = parseQuestions(questionsText)
        
        if cards.isEmpty {
            errorMessage = "Не удалось распарсить вопросы. Проверьте формат."
            showingError = true
            return
        }
        
        let newDeck = Deck(
            name: deckName,
            emoji: emoji,
            colorHex: colorHex,
            cards: cards,
            isBuiltIn: false
        )
        
        deckManager.addDeck(newDeck)
        presentationMode.wrappedValue.dismiss()
    }
    
    private func parseQuestions(_ text: String) -> [Card] {
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        var cards: [Card] = []
        
        for line in lines {
            let parts = line.components(separatedBy: "||")
            if parts.count == 2 {
                let mainQuestion = parts[0].trimmingCharacters(in: .whitespaces)
                let additionalQuestion = parts[1].trimmingCharacters(in: .whitespaces)
                
                if !mainQuestion.isEmpty && !additionalQuestion.isEmpty {
                    cards.append(Card(
                        mainQuestion: mainQuestion,
                        additionalQuestion: additionalQuestion
                    ))
                }
            } else if parts.count == 1 && !parts[0].isEmpty {
                // Если только один вопрос, используем его как основной, а дополнительный - пустой
                cards.append(Card(
                    mainQuestion: parts[0].trimmingCharacters(in: .whitespaces),
                    additionalQuestion: "Расскажи подробнее"
                ))
            }
        }
        
        return cards
    }
}

