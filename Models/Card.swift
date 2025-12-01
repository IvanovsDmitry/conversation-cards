import Foundation

struct Card: Identifiable, Codable, Equatable {
    let id: UUID
    var mainQuestion: String
    var additionalQuestion: String
    
    init(id: UUID = UUID(), mainQuestion: String, additionalQuestion: String) {
        self.id = id
        self.mainQuestion = mainQuestion
        self.additionalQuestion = additionalQuestion
    }
}

