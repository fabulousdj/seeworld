//
//  CallUberModel.swift
//  SeeWorld
//
//  Created by Raphael on 11/28/17.
//  Copyright © 2017 Raphael. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class UberClient: NSObject {

    private let cliendId = "p2X4pyS11QDf7iQMSPOwvQr58Agxecv_"
    private let uberAppStoreUrl = "itms-apps://itunes.apple.com/app/id368677368"
    
    // Check whether there is Uber app
    func checkIfUberInstalled() -> Bool{
        if UIApplication.shared.canOpenURL(URL(string: "uber://")!){
            return true
        }
        return false
    }
    
    func openInAppStore() {
        let url = URL(string: "itms-apps://itunes.apple.com/app/id1024941703")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    // open the Uber App if there is Uber App
    func openUber(_ uberLink: String){
        let url = NSURL(string: uberLink)!
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
    }
    
    func callUber (_ lat: Float, _ lon: Float) {
        var uberURL: String = "uber://"
        uberURL += "?client_id=" + cliendId
        uberURL += "&action=setPickup"
        uberURL += "&pickup=my_location"
        uberURL += "&dropoff[latitude]=\(String(lat))"
        uberURL += "&dropoff[longitude]=\(String(lon))"
        
        if (checkIfUberInstalled()) {
            openUber(uberURL)
        } else {
            openInAppStore()
        }
    }
    
}




