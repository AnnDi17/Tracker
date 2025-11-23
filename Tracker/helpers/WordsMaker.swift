//
//  words.swift
//  Tracker
//
//  Created by Анна Лапухина on 23.11.2025.
//

final class WordsMaker {
    static let standard: WordsMaker = WordsMaker()
    private init() {}
    
    func days(for count: Int) -> String {
        let n = abs(count) % 100
        let n1 = n % 10
        if n1 == 1 && n != 11 {
            return "день"
        } else if (2...4).contains(n1) && !(12...14).contains(n) {
            return "дня"
        } else {
            return "дней"
        }
    }
}
