//
//  Commit+CoreDataClass.swift
//  Project 38
//
//  Created by Paul on 26.01.2019.
//  Copyright © 2019 Paul. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Commit)
public class Commit: NSManagedObject {
    override public init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        print("Init called!")
    }
}
