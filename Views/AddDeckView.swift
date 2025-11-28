import SwiftUI

struct AddDeckView: View {
    @ObservedObject var deckManager: DeckManager
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var deckName: String = ""
    @State private var emoji: String = "📚"
    @State private var colorHex: String = "#007AFF"
    @State private var questionsText: String = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    private let emojiOptions = ["📚", "💬", "🎯", "❤️", "🌟", "🎨", "🎪", "🎭", "🎲", "🎁"]
    private let colorOptions = [
        "#FF6B6B", "#4ECDC4", "#95E1D3", "#F38181", "#AA96DA",
        "#FF6B9D", "#007AFF", "#34C759", "#FF9500", "#AF52DE"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Основная информация")) {
                    TextField("Название колоды", text: $deckName)
                    
                    Picker("Эмодзи", selection: $emoji) {
                        ForEach(emojiOptions, id: \.self) { symbol in
                            Text(symbol).tag(symbol)
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
                
                Section(header: Text("Вопросы"), footer: Text("Формат: основной вопрос || дополнительный вопрос. Каждая пара на новой строке.")) {
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
                    Button("Сохранить", action: saveDeck)
                        .disabled(deckName.trimmingCharacters(in: .whitespaces).isEmpty || questionsText.isEmpty)
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
        guard !cards.isEmpty else {
            errorMessage = "Не удалось распарсить вопросы. Проверьте формат."
            showingError = true
            return
        }
        let newDeck = Deck(name: deckName.trimmingCharacters(in: .whitespacesAndNewlines),
                           emoji: emoji,
                           colorHex: colorHex,
                           cards: cards,
                           isBuiltIn: false)
        deckManager.addDeck(newDeck)
        presentationMode.wrappedValue.dismiss()
    }
    
    private func parseQuestions(_ text: String) -> [Card] {
        text
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .compactMap { line -> Card? in
                let parts = line.components(separatedBy: "||")
                guard let main = parts.first?.trimmingCharacters(in: .whitespaces), !main.isEmpty else { return nil }
                let additional: String
                if parts.count > 1 {
                    additional = parts[1].trimmingCharacters(in: .whitespaces)
                } else {
                    additional = "Расскажи подробнее"
                }
                return Card(mainQuestion: main, additionalQuestion: additional)
            }
    }
}
