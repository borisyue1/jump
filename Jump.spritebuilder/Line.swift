//
//  Line.swift
//  Jump
//
//  Created by Boris Yue on 7/2/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class Line: CCNode {
   
    func draw(){
        self.animationManager.runAnimationsForSequenceNamed("scale")
    }
}
