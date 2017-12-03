//
//  TimeModel.swift
//  SeeWorld
//
//  Created by fabulousdj. on 11/28/17.
//  Copyright © 2017 Raphael. All rights reserved.
//

import Foundation

class TimeClient {
    
    weak var delegate : TextResultHandlerDelegate?
    
    func retrieveCurrentTime() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let dateInFormat = dateFormatter.string(from: Date())
        let response = "The time is " + dateInFormat + "."
        self.delegateResponseHandling(response: response)
    }
    
    private func delegateResponseHandling(response : String) {
        if (self.delegate != nil) {
            self.delegate?.handleTextResult(result: response, shouldAppendOriginalResponse: false)
        }
    }
}
