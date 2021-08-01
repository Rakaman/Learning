//
//  Records+CoreDataProperties.swift
//  Ezpiration
//
//  Created by Raka Mantika on 01/08/21.
//
//

import Foundation
import CoreData


extension Records {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Records> {
        return NSFetchRequest<Records>(entityName: "Records")
    }

    @NSManaged public var date: Date?
    @NSManaged public var file_name: String?
    @NSManaged public var stt_result: String?
    @NSManaged public var tags: NSSet?

}

// MARK: Generated accessors for tags
extension Records {

    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)

}

extension Records : Identifiable {

}
