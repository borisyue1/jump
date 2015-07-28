//
//  Hero.swift
//  Jump
//
//  Created by Boris Yue on 7/1/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class Hero: CCSprite {
   
    func jumpUpAnimation(){
        self.animationManager.runAnimationsForSequenceNamed("jumpupanimation")
    }
//    func jumpUp(){
//        self.animationManager.runAnimationsForSequenceNamed("jumpup")
//
//    }
    func down(){
        self.animationManager.runAnimationsForSequenceNamed("down")
    }
    func jumpUpWithSound() {
        self.animationManager.runAnimationsForSequenceNamed("jumpupsound")
    }
}
