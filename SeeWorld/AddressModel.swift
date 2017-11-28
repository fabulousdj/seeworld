//
//  AddressModel.swift
//  Save Address to the core data
//  SeeWorld
//
//  Created by Raphael on 11/14/17.
//  Copyright © 2017 Raphael. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import CoreData

class AddressModel {
    // Get the Full Address
    var name = ""
    var address = ""
    var city = ""
    var state = ""
    var country = ""
    var zipCode = ""
    
    // Save Core Data
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    lazy var context = appDelegate.persistentContainer.viewContext
    lazy var entity = NSEntityDescription.entity(forEntityName: "PlaceInformation", in: context)
    lazy var newPlace = NSManagedObject(entity: entity!, insertInto: context)
    
    
    func getAddressFromLatLon(lat: Double, lon: Double) {
        self.deleteRecords()
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        
        self.newPlace.setValue(String(lat), forKey: "lat")
        self.newPlace.setValue(String(lon), forKey: "lon")
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                    
                    if pm.subLocality != nil {
                        self.name = pm.name!
                        self.newPlace.setValue(self.name, forKey: "name")
                    }
                    if pm.thoroughfare != nil {
                        self.address = pm.thoroughfare!
                        self.newPlace.setValue(self.address, forKey: "address")
                    }
                    if pm.locality != nil {
                        self.city = pm.locality!
                        self.newPlace.setValue(self.city, forKey: "city")
                    }
                    if pm.administrativeArea != nil {
                        self.state = pm.administrativeArea!
                        self.newPlace.setValue(self.state, forKey: "state")
                    }
                    //                    if pm.country != nil {
                    //                        self.country = pm.country!
                    //                    }
                    //                    if pm.postalCode != nil {
                    //                        self.zipCode = pm.postalCode!
                    //                    }
                }
                
                // Save the value
                do {
                    try self.context.save()
                } catch {
                    print("Failed saving")
                }
                
        })
    }
    
    // Get value from CoreData
    func getCoreData(name: String) -> String {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PlaceInformation")
        request.returnsObjectsAsFaults = false
        var returnValue = ""
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                print(data.value(forKey: name) as! String)
                returnValue = data.value(forKey: name) as! String
            }
        } catch {
            print("Failed")
        }
        return returnValue
    }
    
    // Delete value from CoreData
    func deleteRecords() -> Void {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PlaceInformation")
        let result = try? self.context.fetch(request)
        let resultData = result as! [PlaceInformation]
        for object in resultData {
            self.context.delete(object)
        }
        
        do {
            try context.save()
            print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
        }
    }
    
    func someDataExists() -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PlaceInformation")
        let result = try? self.context.fetch(request)
        let resultData = result as! [PlaceInformation]
        var entitiesCount = 0
        
        entitiesCount = resultData.count
        
        return entitiesCount > 0
    }
    
}

