//
//  Prospect.swift
//  HotProspects
//
//  Created by Subhrajyoti Chakraborty on 15/09/20.
//  Copyright © 2020 Subhrajyoti Chakraborty. All rights reserved.
//

import SwiftUI

class Prospect: Identifiable, Codable {
    let id = UUID()
    var name = ""
    var emailAddress = ""
    var createdAt = 0
    fileprivate(set) var isContacted = false
}

class Prospects: ObservableObject {
    static let saveKey = "SavedData"
    @Published private(set) var people: [Prospect]
    
    init() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let fileName = paths[0].appendingPathComponent(Self.saveKey)
        do {
            let data = try Data(contentsOf: fileName)
            let peopleData = try JSONDecoder().decode([Prospect].self, from: data)
            self.people = peopleData
            return
        } catch  {
            print("Unable to load data \(error.localizedDescription)")
        }
        self.people = []
    }
    
    func getFilePath() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
        save()
    }
    
    private func save() {
        let fileName = getFilePath().appendingPathComponent(Self.saveKey)
        do {
            let data = try JSONEncoder().encode(people)
            try data.write(to: fileName, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("Unable to write the data \(error.localizedDescription)")
        }
    }
    
    func add(_ prospect: Prospect) {
        people.append(prospect)
        save()
    }
}
