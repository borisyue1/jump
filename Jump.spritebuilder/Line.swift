//
//  Line.swift
//  Jump
//
//  Created by Boris Yue on 7/2/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class Line: CCNode {
   
    var time = 0
    
    func draw(){
        self.animationManager.runAnimationsForSequenceNamed("scale")
    }
    func getTime() -> Int {
        return time
    }
    func increaseTime(amount: Int){
        time += amount
    }
}
