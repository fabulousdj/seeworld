//
//  ConversationContextModel.swift
//  SeeWorld
//
//  Created by fabulousdj. on 11/28/17.
//  Copyright © 2017 Raphael. All rights reserved.
//

import Foundation

class ConversationContext {
    
    var input : String
    var nodeName : String
    var hasPreviousDestination : Bool
    var previousDestination : String
    var isValidDestination : Bool
    var isValidReview : Bool
    var shouldVerifyAddress : Bool
    var completeAddress : String
    var systemContext : [String : Any]
    
    static let Instance = ConversationContext()
    
    private init() {
        self.input = ""
        self.nodeName = ""
        self.hasPreviousDestination = false
        self.previousDestination = ""
        self.isValidDestination = false
        self.isValidReview = false
        self.shouldVerifyAddress = true
        self.completeAddress = ""
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
        self.completeAddress = ""
        self.systemContext = [:]
    }
}
