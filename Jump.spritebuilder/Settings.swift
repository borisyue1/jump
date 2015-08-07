//
//  Settings.swift
//  Jump
//
//  Created by Boris Yue on 7/24/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit
import Mixpanel


class Settings: CCScene {
   
    weak var sound: CCButton!
    var creditPressed = false
    var credit: CCNode!
    var creditText: CCLabelTTF!
    static var pressed = NSUserDefaults.standardUserDefaults().boolForKey("soundpressed") ?? false {
        didSet {
            NSUserDefaults.standardUserDefaults().setBool(pressed, forKey: "soundpressed")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
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
        Mixpanel.sharedInstance().track("Sound pressed")

    }
    func credits() {
        if !creditPressed {
            Mixpanel.sharedInstance().track("Credits clicked")
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
