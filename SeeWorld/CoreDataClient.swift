//
//  CoreDataModel.swift
//  SeeWorld
//
//  Created by fabulousdj. on 11/28/17.
//  Copyright © 2017 Raphael. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataClient {
    
    let entityName : String = "PlaceInfoStorage"
    
    lazy var appDelegate = UIApplication.shared.delegate as! AppDelegate
    lazy var context = appDelegate.persistentContainer.viewContext
    
    // Save Core Data
    func savePlaceRecord(placeInfo : PlaceInfo) {
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
        let placeRecord = NSManagedObject(entity: entity!, insertInto: context)
        placeRecord.setValue(placeInfo.name, forKey: "name")
        placeRecord.setValue(placeInfo.address, forKey: "address")
        placeRecord.setValue(placeInfo.placeId, forKey: "placeId")
        let geoInfo = placeInfo.geoLocation
        placeRecord.setValue(geoInfo.latitude, forKey: "lat")
        placeRecord.setValue(geoInfo.longitude, forKey: "lng")
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
    }
    
    // Get value from CoreData
    func getPlaceRecord() -> PlaceInfo {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.returnsObjectsAsFaults = false
        var placeInfo : PlaceInfo? = nil
        do {
            let result = try context.fetch(request)
            let data = result[0] as! NSManagedObject
            let lat = data.value(forKey: "lat") as! Float
            let lng = data.value(forKey: "lng") as! Float
            let geoLocation = GeoLocation(latitude: lat, longitude: lng)
            let name = data.value(forKey: "name") as! String
            let address = data.value(forKey: "address") as! String
            let placeId = data.value(forKey: "placeId") as! String
            placeInfo = PlaceInfo(name: name, address: address, placeId: placeId, geoLocation: geoLocation)
        } catch {
            print("Failed")
        }
        return placeInfo!
    }
    
    // Delete value from CoreData
    func clearRecords() -> Void {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let result = try? self.context.fetch(request)
        for object in result! {
            self.context.delete(object as! NSManagedObject)
        }
        do {
            try context.save()
            print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
        }
    }
    
    func containsRecords() -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let result = try? self.context.fetch(request)
        return result!.count > 0
    }
}
