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
import UIKit

class MapModel {

    // Baisc Model
    let basicModel = BaiscFuncModel()
    let weatherModel = WeatherModel()
    let callFuncModel = CallFuncModel()
    let addressModel = AddressModel()
    
    // Your location
    var _lon: Double = 0.0
    var _lat: Double = 0.0
    
    // The search location
    var _lonEnd: Double = 0.0
    var _latEnd: Double = 0.0
    

    // Convert Function
    func convertTime (time: Double) -> String {
        var result:String
        let seconds = Int(time.truncatingRemainder(dividingBy: 60))
        let minutes = Int((time / 60).truncatingRemainder(dividingBy: 60))
        let hours = Int(time / 3600)
        
        if (hours != 0) {
            result = "\(hours) hours, \(minutes) minutes and \(seconds) seconds."
        }
        else {
            result = "\(minutes) minutes and \(seconds) seconds."
        }
        
        return result
    }
    
    // Search place
    func searchPlace(_ textView: UITextView, _ mapView: MKMapView, fullAddr: String) {
        
        //Create the search request
        let searchRequest = MKLocalSearchRequest()
        searchRequest.region = mapView.region
        searchRequest.naturalLanguageQuery = fullAddr
        let activeSearch = MKLocalSearch(request: searchRequest)
        
        activeSearch.start { (response, error) in
            UIApplication.shared.endIgnoringInteractionEvents()
            if response == nil
            {
                print("ERROR")
            }
            else
            {
                //Remove annotations
                let annotations = mapView.annotations
                mapView.removeAnnotations(annotations)
                
                //Getting data
                let latitude = response?.boundingRegion.center.latitude
                let longitude = response?.boundingRegion.center.longitude
                
                self._latEnd = latitude!
                self._lonEnd = longitude!
                //Create annotation
                let annotation = MKPointAnnotation()
                annotation.title = textView.text
                annotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
                mapView.addAnnotation(annotation)
                
                //Zooming in on annotation
                let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude!, longitude!)
                let span = MKCoordinateSpanMake(0.1, 0.1)
                let region = MKCoordinateRegionMake(coordinate, span)
                mapView.setRegion(region, animated: true)
                
                // Get ETA func
                self.getETA(textView)
            }
        }
    }
    
    // ETA func
    func getETA(_ textView: UITextView) {
        let locManager = CLLocationManager()
        var currentLocation: CLLocation!
        currentLocation = locManager.location
    
        _lat = currentLocation.coordinate.latitude
        _lon = currentLocation.coordinate.longitude

        var byUber: String = ""
        var byPublic: String = ""
        var byWalk: String = ""
        
        // Uber
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: _lat, longitude: _lon), addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: _latEnd, longitude: _lonEnd), addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .automobile

        var directions = MKDirections(request: request)
        directions.calculateETA { (response, error) in
            if error == nil {
                if let r = response {
                    byUber = self.convertTime(time: r.expectedTravelTime)

                    textView.text =  " If you would like to take Uber, it might take " + byUber
                    self.basicModel.testToSpeech(" If you would like to take Uber, it might take " + byUber)
                }
            }
        }

        // Public transit
        let request2 = MKDirectionsRequest()
        request2.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: _lat, longitude: _lon), addressDictionary: nil))
        request2.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: _latEnd, longitude: _lonEnd), addressDictionary: nil))
        request2.requestsAlternateRoutes = true
        request2.transportType = .transit
        directions = MKDirections(request: request2)
        directions.calculateETA { (response, error) in
            if error == nil {
                if let r = response {
                    byPublic = self.convertTime(time: r.expectedTravelTime)
                    textView.text.append(" If you prefer to by public transit, it will take " + byPublic)
                    self.basicModel.testToSpeech(" If you prefer to by public transit, it will take " + byPublic)
                }
            }
        }

        // Walk
        let request3 = MKDirectionsRequest()
        request3.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: _lat, longitude: _lon), addressDictionary: nil))
        request3.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: _latEnd, longitude: _lonEnd), addressDictionary: nil))
        request3.requestsAlternateRoutes = true
        request3.transportType = .walking
        directions = MKDirections(request: request3)
        directions.calculateETA { (response, error) in
            if error == nil {
                if let r = response {
                    byWalk = self.convertTime(time: r.expectedTravelTime)
                    textView.text.append( " If you choose walking to the destination, it will take " + byWalk)
                    self.basicModel.testToSpeech(" If you choose walking to the destination, it will take " + byWalk)
                }
            }
        }
    }
    
    // Open Apple Map
    func openInMapsTransit(coord:CLLocationCoordinate2D) {
        let placemark = MKPlacemark(coordinate:coord, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Your Destination"
        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeTransit]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
    
    // Weather of current location
    func currentWeather(_ textView: UITextView){
        let currentLat = String(self._lat)
        let currentLon = String(self._lon)
        weatherModel.getWeather(textView, currentLat, currentLon)
    }
    
    // Call for the search location
    func makeCall(_ textView: UITextView){
        let searchLat = self.addressModel.getCoreData(name: "lat")
        let searchLon = self.addressModel.getCoreData(name: "lon")
        //        let searchLat = String("40.0023")
        //        let searchLon = String("-83.0159")
        callFuncModel.getPlaceID(textView, searchLat, searchLon)
    }

}
