//
//  Gem.swift
//  Jump
//
//  Created by Boris Yue on 7/27/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class Gem: CCNode {
   
    func didLoadFromCCB() {
        self.physicsBody.sensor = true
    }
}
