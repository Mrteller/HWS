//
//  Whistle.swift
//  Project 33
//
//  Created by Paul on 25.02.2019.
//  Copyright © 2019 Paul. All rights reserved.
//

import CloudKit
import UIKit

class Whistle: NSObject {
    var recordID: CKRecord.ID!
    var genre: String!
    var comments: String!
    var audio: URL!
}
