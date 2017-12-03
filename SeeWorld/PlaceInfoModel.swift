//
//  PlaceInfoModel.swift
//  SeeWorld
//
//  Created by fabulousdj. on 11/28/17.
//  Copyright © 2017 Raphael. All rights reserved.
//

import Foundation

struct PlaceInfo : Codable {
    var name : String
    var address : String
    var placeId : String
    var geoLocation : GeoLocation
    enum CodingKeys : String, CodingKey {
        case name
        case address
        case placeId = "place_id"
        case geoLocation = "geo_location"
    }
}

struct GeoLocation : Codable {
    var latitude : Float
    var longitude : Float
    enum CodingKeys : String, CodingKey {
        case latitude = "lat"
        case longitude = "lng"
    }
}
