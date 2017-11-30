//
//  ConversationModel.swift
//  SeeWorld
//
//  Created by fabulousdj. on 11/28/17.
//  Copyright © 2017 Raphael. All rights reserved.
//

import Foundation
import Alamofire

class ConversationClient {
    
    private let conversationApiEndpoint = "http://seeworld-api-test.mybluemix.net/seeworld/api/v1/conversation/send-message"
    weak var delegate : ConversationResponseHandlerDelegate?
    
    func sendMessage() {
        let context = ConversationContext.Instance
        
        let requestBody: [String: Any] = [
            "input": context.input,
            "node_name": context.nodeName,
            "prev_dest": context.hasPreviousDestination,
            "previous": context.previousDestination,
            "valid_dest": context.isValidDestination,
            "valid_review": context.isValidReview,
            "verifyAdd": context.shouldVerifyAddress,
            "address": context.completeAddress,
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
                    self.delegate?.handleConversationResponse(result: result)
                }
        }
    }
    
    
}
