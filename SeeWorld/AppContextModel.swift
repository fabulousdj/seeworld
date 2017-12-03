//
//  ConversationContextModel.swift
//  SeeWorld
//
//  Created by fabulousdj. on 11/28/17.
//  Copyright © 2017 Raphael. All rights reserved.
//

import Foundation

class AppContext {
    
    var input : String
    var nodeName : String
    var hasPreviousDestination : Bool
    var previousDestination : String
    var isValidDestination : Bool
    var isValidReview : Bool
    var shouldVerifyAddress : Bool
    var destinationInfo : PlaceInfo?
    var reviewInsights : String
    var walkInfo : String
    var transitInfo : String
    var driveInfo : String
    var responseText : String
    var finishedSubroutine : Int
    var canStartNewConversation : Bool
    var hasPhoneNumber : Bool
    var isCalling : Bool
    var systemContext : [String : Any]
    
    static let Instance = AppContext()
    
    private init() {
        self.input = ""
        self.nodeName = ""
        self.hasPreviousDestination = false
        self.previousDestination = ""
        self.isValidDestination = false
        self.isValidReview = false
        self.shouldVerifyAddress = true
        self.destinationInfo = nil
        self.reviewInsights = ""
        self.walkInfo = ""
        self.transitInfo = ""
        self.driveInfo = ""
        self.responseText = ""
        self.finishedSubroutine = 0
        self.canStartNewConversation = true
        self.hasPhoneNumber = false
        self.isCalling = false
        self.systemContext = [:]
    }
    
    public func reset() {
        self.input = ""
        self.nodeName = ""
        self.hasPreviousDestination = false
        self.previousDestination = ""
        self.isValidDestination = false
        self.isValidReview = false
        self.shouldVerifyAddress = true
        self.destinationInfo = nil
        self.reviewInsights = ""
        self.walkInfo = ""
        self.transitInfo = ""
        self.driveInfo = ""
        self.responseText = ""
        self.finishedSubroutine = 0
        self.hasPhoneNumber = false
        self.isCalling = false
        self.systemContext = [:]
    }
}
