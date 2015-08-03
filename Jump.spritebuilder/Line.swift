//
//  Line.swift
//  Jump
//
//  Created by Boris Yue on 7/2/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class Line: CCNode {
   
    var jumped = false
    var time = 0
    var timeNoJump = 0
//    func draw(){
//        self.animationManager.runAnimationsForSequenceNamed("scale")
//    }
    func getTime() -> Int {
        return time
    }
    func increaseTime(amount: Int){
        time += amount
    }
    func didJump() -> Bool {
        return jumped
    }
    func setJump(status: Bool) {
        jumped = status
    }
    func increaseTimeNoJump(amount: Int) {
        timeNoJump+=amount
    }
    func getTimeNoJump() -> Int {
        return timeNoJump
    }
}
