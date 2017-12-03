//
//  TransitInfoClient.swift
//  SeeWorld
//
//  Created by fabulousdj. on 12/1/17.
//  Copyright © 2017 Raphael. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class TransportInfoClient {
    
    weak var delegate : TravelInfoResponseHandlerDelegate?
    weak var subroutineCompletionDelegate : SubroutineFailureHandlerDelegate?
    
    func getTransportInfo(from current: GeoLocation, to destination: GeoLocation, by transportType: MKDirectionsTransportType) {
        
        let currentLatitude = current.latitude
        let currentLongitude = current.longitude
        let destLatitude = destination.latitude
        let destLongitude = destination.longitude
        
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(currentLatitude), longitude: CLLocationDegrees(currentLongitude)), addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(destLatitude), longitude: CLLocationDegrees(destLongitude)), addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = transportType
        let directions = MKDirections(request: request)
        
        directions.calculateETA(
            completionHandler: { (response, error) in
                
                if error != nil {
                    self.subroutineCompletionDelegate?.handleSubroutineFailure()
                    return
                }

                if let r = response {
                    self.delegate?.handleTravelInfoResponse(response: r, transportType: transportType)
                } else {
                    self.subroutineCompletionDelegate?.handleSubroutineFailure()
                }

            }
        )
    }
    
    // Convert Function
    func getFormattedTime(time: Double) -> String {
        var result:String
        let minutes = Int((time / 60).truncatingRemainder(dividingBy: 60))
        let hours = Int(time / 3600)
        
        if (hours != 0) {
            result = "\(hours) hours and \(minutes) minutes"
        }
        else {
            result = "\(minutes) minutes"
        }
        return result
    }
}
