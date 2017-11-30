//
//  AppRedirectModel.swift
//  SeeWorld
//
//  Created by fabulousdj. on 11/28/17.
//  Copyright © 2017 Raphael. All rights reserved.
//

import Foundation
import MapKit

class AppRedirectClient {
    // Redirect to Apple Map
    func openInMapsTransit(coord:CLLocationCoordinate2D) {
        let placemark = MKPlacemark(coordinate:coord, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Your Destination"
        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeTransit]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
    
    // Redirect to Uber
    func openInUberApp() {
        
    }
}
