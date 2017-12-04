//
//  UserReviewModel.swift
//  SeeWorld
//
//  Created by fabulousdj. on 11/28/17.
//  Copyright © 2017 Raphael. All rights reserved.
//

import Foundation
import Alamofire

class UserReviewClient {
    
    weak var delegate : UserReviewClientResponseHandlerDelegate?
    weak var subroutineCompletionDelegate : SubroutineFailureHandlerDelegate?
    
    struct ReviewInsights : Codable {
        var count : Int
        var positiveRate : Float
        var negativeRate : Float
        var neutralRate : Float
        enum CodingKeys : String, CodingKey {
            case count
            case positiveRate = "positive"
            case negativeRate = "negative"
            case neutralRate = "neutral"
        }
    }
    
    private let postReviewApiEndpoint = "http://seeworld-api-test.mybluemix.net/seeworld/api/v1/user-reviews/post-review"
    private let getInsightsApiEndpoint = "http://seeworld-api-test.mybluemix.net/seeworld/api/v1/user-reviews/get-insights"
    
    func postReview(placeId : String, review : String) {
        
        let requestBody: [String: String] = [
            "place_id" : placeId,
            "review" : review
        ]
        
        Alamofire.request(postReviewApiEndpoint, method: .post, parameters: requestBody, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling GET on /seeworld/api/v1/user-reviews/post_review")
                    print(response.result.error!)
                    self.delegate?.handlePostUserReviewResponse(isSuccessful: false)
                    return
                }
                
                // make sure we got some JSON since that's what we expect
                guard let json = response.result.value as? [String: Any] else {
                    print("didn't get classify object as JSON from API")
                    print("Error: \(String(describing: response.result.error))")
                    self.delegate?.handlePostUserReviewResponse(isSuccessful: false)
                    return
                }
                
                // get and print the title
                guard let isSuccessful = json["successful"] else {
                    print("Could not get classified result from JSON")
                    self.delegate?.handlePostUserReviewResponse(isSuccessful: false)
                    return
                }
                
                // succeed
                if (isSuccessful as! Bool) {
                    self.delegate?.handlePostUserReviewResponse(isSuccessful: true)
                } else {
                    self.delegate?.handlePostUserReviewResponse(isSuccessful: false)
                }
        }
    }
    
    func retrieveReviewInsights(placeId : String) {
        Alamofire.request(getInsightsApiEndpoint, method: .get, parameters: ["id": placeId])
            .responseJSON { response in
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling GET on /seeworld/api/v1/user-reviews/get-insights")
                    print(response.result.error!)
                    self.subroutineCompletionDelegate?.handleSubroutineFailure()
                    return
                }
                
                // make sure we got some JSON since that's what we expect
                guard let json = response.result.value as? [String: Any] else {
                    print("didn't get classify object as JSON from API")
                    print("Error: \(String(describing: response.result.error))")
                    self.subroutineCompletionDelegate?.handleSubroutineFailure()
                    return
                }
                
                // get and print the title
                guard let result = json["value"] as? [String : Any] else {
                    print("Could not get classified result from JSON")
                    self.subroutineCompletionDelegate?.handleSubroutineFailure()
                    return
                }
                
                // handle place info data
                self.delegate?.handleUserReviewInsightsResponse(response: result)
        }
    }
}
