//
//  Enemy.swift
//  Jump
//
//  Created by Boris Yue on 7/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class Enemy: CCNode {
   
    func fireWithoutSound() {
        self.animationManager.runAnimationsForSequenceNamed("fire")
    }
}
