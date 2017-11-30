//
//  ConversationResponseHandlerDelegate.swift
//  SeeWorld
//
//  Created by fabulousdj. on 11/29/17.
//  Copyright © 2017 Raphael. All rights reserved.
//

import Foundation

protocol ConversationResponseHandlerDelegate : NSObjectProtocol {
    func handleConversationResponse(result : [String : Any])
}

protocol SimpleResponseHandlerDelegate : NSObjectProtocol {
    func handleSimpleResponse(response : String, shouldAppendOriginalResponse : Bool)
}
