//
//  ImageMetaData+CoreDataProperties.swift
//  FIT3178-Week09-Lab
//
//  Created by Joshua Olsen on 17/5/20.
//  Copyright © 2020 Monash University. All rights reserved.
//
//

import Foundation
import CoreData


extension ImageMetaData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageMetaData> {
        return NSFetchRequest<ImageMetaData>(entityName: "ImageMetaData")
    }

    @NSManaged public var filename: String?

}
