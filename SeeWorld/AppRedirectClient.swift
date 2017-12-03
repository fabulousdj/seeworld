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

    let uberClient = UberClient()
    
    func redirectToAppleMap(latitude : Float, longitude : Float, directionMode : String) {
        let coord = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        let placemark = MKPlacemark(coordinate:coord, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Your Destination"
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: directionMode]
        AppContext.Instance.canStartNewConversation = true
        mapItem.openInMaps(launchOptions: launchOptions)
    }
    
    func redirectToUber(latitude : Float, longitude : Float) {
        AppContext.Instance.canStartNewConversation = true
        self.uberClient.callUber(latitude, longitude)
    }
    
    func makePhoneCall(number: String)  {
        var callableNumber : String = ""
        for i in 0...number.count - 1 {
            let index = number.index (number.startIndex, offsetBy: i)
            switch number[index] {
                case "0","1","2","3","4","5","6","7","8","9" :
                    callableNumber += String(number[index])
                break
            default:
                break
            }
        }
        let url: NSURL = URL(string: "tel://\(callableNumber)")! as NSURL
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
    }
}
