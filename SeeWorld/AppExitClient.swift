//
//  AppExitClient.swift
//  SeeWorld
//
//  Created by fabulousdj. on 11/30/17.
//  Copyright © 2017 Raphael. All rights reserved.
//

import Foundation

class AppExitClient {
    
    weak var delegate : AppExitResponseHandlerDelegate?
    
    func exitApp(response : String) {
        self.delegate?.handleAppExitResponse(response: response)
    }
}
