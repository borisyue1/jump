//
//  Lightning.swift
//  Jump
//
//  Created by Boris Yue on 7/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class Lightning: CCNode {
 
    func didLoadFromCCB() {
        self.physicsBody.sensor = true
    }
}
