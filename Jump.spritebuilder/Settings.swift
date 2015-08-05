//
//  Settings.swift
//  Jump
//
//  Created by Boris Yue on 7/24/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class Settings: CCScene {
   
    weak var sound: CCButton!
    static var pressed = false
    var creditPressed = false
    var credit: CCNode!
    var creditText: CCLabelTTF!
    
    func didLoadFromCCB() {
        if !Settings.pressed {
            sound.setBackgroundSpriteFrame(CCSpriteFrame(imageNamed: "sounds/Sound_On.png"), forState: CCControlState.Normal)
            sound.setBackgroundSpriteFrame(CCSpriteFrame(imageNamed: "sounds/Sound_Off.png"), forState: CCControlState.Selected)
        }
        else {
            sound.setBackgroundSpriteFrame(CCSpriteFrame(imageNamed: "sounds/Sound_Off.png"), forState: CCControlState.Normal)
            sound.setBackgroundSpriteFrame(CCSpriteFrame(imageNamed: "sounds/Sound_On.png"), forState: CCControlState.Selected)
        }
        sound.togglesSelectedState = true

    }
    func back() {
        CCDirector.sharedDirector().popScene()
    }
    func soundPressed() {
        Settings.pressed = !Settings.pressed
       
    }
    func credits() {
        if !creditPressed {
            credit = CCBReader.load("Credits", owner: self) as CCNode
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                credit.contentSize = CGSize(width: 384, height: 512)
                creditText.fontSize = 8
            }
            self.addChild(credit)
        }
        creditPressed = true
    }
    func backy() {
        self.removeChild(credit)
        creditPressed = false
    }
}
