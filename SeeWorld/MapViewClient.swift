//
//  MapModel.swift
//  SeeWorld
//
//  Created by Raphael on 11/2/17.
//  Copyright © 2017 Raphael. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class MapViewClient {
    // Baisc Model
    let basicModel = TextSpeechConversionClient()
    let weatherModel = WeatherClient()
    
    // Your location
    var currentLongitude: Double = 0.0
    var currentLatitude: Double = 0.0
    
    // The search location
    var destLongitude: Double = 0.0
    var destLatitude: Double = 0.0
    
//    func resetMapView(mapView: MKMapView) {
//        mapView.annotations.forEach {
//            if !($0 is MKUserLocation) {
//                mapView.removeAnnotation($0)
//            }
//        }
//    }
//    
    // Search place
    func showDestinationOnMap(mapView: MKMapView, coordinate: GeoLocation, annotationTitle: String) {
        //Create the search request
        let searchRequest = MKLocalSearchRequest()
        searchRequest.region = mapView.region
        searchRequest.naturalLanguageQuery = String(coordinate.latitude) + "," + String(coordinate.longitude)
        let activeSearch = MKLocalSearch(request: searchRequest)
        
        activeSearch.start { (response, error) in
            UIApplication.shared.endIgnoringInteractionEvents()
            if response == nil {
                print("ERROR")
            } else {
                //Remove annotations
                let annotations = mapView.annotations
                mapView.removeAnnotations(annotations)
                
                //Getting data
                let latitude = response?.boundingRegion.center.latitude
                let longitude = response?.boundingRegion.center.longitude
                
                print("lat\(String(describing: latitude))")
                print("lng\(String(describing: longitude))")
                
                self.destLatitude = latitude!
                self.destLongitude = longitude!
                //Create annotation
                let annotation = MKPointAnnotation()
                annotation.title = annotationTitle
                annotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
                mapView.addAnnotation(annotation)
                mapView.showAnnotations(mapView.annotations, animated: true)
            }
        }
    }
    
    func getCurrentCoordinate() -> GeoLocation {
        return GeoLocation(latitude: Float(self.currentLatitude), longitude: Float(self.currentLongitude))
    }
}
