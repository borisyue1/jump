//
//  Ice.swift
//  Jump
//
//  Created by Boris Yue on 7/21/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class Ice: CCNode {
   
    func didLoadFromCCB() {
        self.physicsBody.sensor = true
        
    }
}
