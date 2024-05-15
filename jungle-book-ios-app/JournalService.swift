//
//  JournalService.swift
//  jungle-book-ios-app
//
//  Created by Schablinger Mathias on 13.03.24.
//

import Foundation
//fileprivate let journalUrlString = "http://jungle-book.ddns.net:8000/api/journal/list"
fileprivate let journalUrlString = "http://localhost:8000/api/journal/list"
func loadAllJournals() async -> [Journal] {
    var journals: [Journal] = [Journal]()
    let url: URL = URL(string: journalUrlString)!
    if let (data, _) = try? await URLSession.shared.data(from: url) {
        if let loadedJournals = try? JSONDecoder().decode([Journal].self, from: data) {
            journals = loadedJournals
        } else {
            print("failed to decode")
        }
    } else {
        print("failed to load url")
    }
    
    return journals
}
