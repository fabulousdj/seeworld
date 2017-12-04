//
//  ConversationModel.swift
//  SeeWorld
//
//  Created by fabulousdj. on 11/28/17.
//  Copyright © 2017 Raphael. All rights reserved.
//

import Foundation
import Alamofire


enum ConversationActions : String {
    case WELCOME = "Welcome"
    case CANCEL = "Cancel"
    case CANCEL_REVIEW = "Cancel Review"
    case POST_REVIEW = "Post Review"
    case GET_WEATHER = "Weather"
    case GET_TIME = "Time"
    case EVAL_DEST = "Destination"
    case SUMMARY = "Info"
    case WALK = "Walk"
    case TRANSIT = "Transit"
    case UBER = "Uber"
    case CALL = "Call"
    case EXIT_APP = "Close App"
}

class ConversationClient {
    
    private let conversationApiEndpoint = "http://seeworld-api-test.mybluemix.net/seeworld/api/v1/conversation/send-message"
    weak var delegate : ConversationResponseHandlerDelegate?
    
    func sendMessage() {
        let context = AppContext.Instance
        let destinationName = context.destinationInfo == nil ? "" : (context.destinationInfo?.name)!
        let address = context.destinationInfo == nil ? "" : (context.destinationInfo?.name)! + " at " + (context.destinationInfo?.address)!
        let requestBody: [String: Any] = [
            "input": context.input,
            "node_name": context.nodeName,
            "prev_dest": context.hasPreviousDestination,
            "previous": context.previousDestination,
            "valid_dest": context.isValidDestination,
            "valid_review": context.isValidReview,
            "verifyAdd": context.shouldVerifyAddress,
            "callSucceeded" : context.hasPhoneNumber,
            "dest_name": destinationName,
            "address": address,
            "system": context.systemContext
        ]
        
        Alamofire.request(conversationApiEndpoint, method: .post, parameters: requestBody, encoding: JSONEncoding.default)
            .responseJSON { response in
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling GET on /seeworld/api/v1/user-reviews/post_review")
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
                guard let result = json["value"] as? [String : Any] else {
                    print("Could not get classified result from JSON")
                    return
                }
                
                if (self.delegate != nil) {
                    self.delegate?.handleConversationResult(result: result)
                }
        }
    }
    
    
}
