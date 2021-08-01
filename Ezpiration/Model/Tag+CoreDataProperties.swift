//
//  Tag+CoreDataProperties.swift
//  Ezpiration
//
//  Created by Raka Mantika on 01/08/21.
//
//

import Foundation
import CoreData


extension Tag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }

    @NSManaged public var category: String?
    @NSManaged public var records: NSSet?

}

// MARK: Generated accessors for records
extension Tag {

    @objc(addRecordsObject:)
    @NSManaged public func addToRecords(_ value: Records)

    @objc(removeRecordsObject:)
    @NSManaged public func removeFromRecords(_ value: Records)

    @objc(addRecords:)
    @NSManaged public func addToRecords(_ values: NSSet)

    @objc(removeRecords:)
    @NSManaged public func removeFromRecords(_ values: NSSet)

}

extension Tag : Identifiable {

}
