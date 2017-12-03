//
//  ConversationResponseHandlerDelegate.swift
//  SeeWorld
//
//  Created by fabulousdj. on 11/29/17.
//  Copyright © 2017 Raphael. All rights reserved.
//

import Foundation
import MapKit
import GooglePlaces

protocol ConversationResponseHandlerDelegate : NSObjectProtocol {
    func handleConversationResult(result : [String : Any])
}

protocol TextResultHandlerDelegate : NSObjectProtocol {
    func handleTextResult(result : String, shouldAppendOriginalResponse : Bool)
}

protocol AppExitResponseHandlerDelegate : NSObjectProtocol {
    func handleAppExitResponse(response : String)
}

protocol PlaceSearchResponseHandlerDelegate : NSObjectProtocol {
    func handlePlaceSearchResult(result : [Any])
    func handlePlaceDetailsResult(result : GMSPlace)
}

protocol TravelInfoResponseHandlerDelegate : NSObjectProtocol {
    func handleTravelInfoResponse(response : MKETAResponse, transportType : MKDirectionsTransportType)
}

protocol UserReviewClientResponseHandlerDelegate : NSObjectProtocol {
    func handleUserReviewInsightsResponse(response : [String : Any])
    func handlePostUserReviewResponse()
}

protocol SubroutineFailureHandlerDelegate : NSObjectProtocol {
    func handleSubroutineFailure()
}

protocol ApplicationEnterForegroundDelegate : NSObjectProtocol {
    func prepareForApplicationEnterForeground()
}

