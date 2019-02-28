//
//  Constants.swift
//  Project 33
//
//  Created by Paul on 27.02.2019.
//  Copyright © 2019 Paul. All rights reserved.
//

// Describes Suggestion record type (smth. like table)
struct Suggestions {
    struct Record {
        static let type = "Suggestions"
    }
    static let text = "text"
    static let owningWhistle = "owningWhistle"
    // common "fields"
    static let creationDate = "creationDate"
}

struct Whistles {
    struct Record {
        static let type = "Whistles"
    }
    static let genre = "genre"

    // common "fields"
    static let creationDate = "creationDate"
}
let myGenresSettingKey = "myGenres"
