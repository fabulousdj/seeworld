//
//  PlaceSearchModel.swift
//  SeeWorld
//
//  Created by fabulousdj. on 11/28/17.
//  Copyright © 2017 Raphael. All rights reserved.
//

import Foundation
import Alamofire
import GooglePlaces

class PlaceSearchClient {
    
    weak var delegate : PlaceSearchResponseHandlerDelegate?

    private let placeSearchApiEndpoint: String = "http://seeworld-api-test.mybluemix.net/seeworld/api/v1/geo-service/search"
    
    func searchPlace(_ input: String, latitude: Float, longitude: Float) {
        Alamofire.request(placeSearchApiEndpoint, method: .get, parameters: ["input": input, "lat": latitude, "lng": longitude])
            .responseJSON { response in
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling GET on /seeworld/api/v1/geo-service/search")
                    print(response.result.error!)
                    return
                }

                // make sure we got some JSON since that's what we expect
                guard let json = response.result.value as? [String: Any] else {
                    print("didn't get classify object as JSON from API")
                    print("Error: \(String(describing: response.result.error))")
                    return
                }

                // get and print the title
                guard let result = json["value"] as? [Any] else {
                    print("Could not get classified result from JSON")
                    return
                }
                // handle place info data
                self.delegate?.handlePlaceSearchResult(result: result)
            }
    }

    // Get Place Detail
    func getPlaceDetail(_ placeID : String) {
        let placesClient = GMSPlacesClient()
        
        placesClient.lookUpPlaceID(placeID, callback: { (place, error) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            
            guard let place = place else {
                print("No place details for \(placeID)")
                return
            }
            
            print("Place name \(place.name)")
            self.delegate?.handlePlaceDetailsResult(result: place)
        })
    }
    
}
