//
//  Store.swift
//  Jump
//
//  Created by Boris Yue on 7/27/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit
import StoreKit

class Store: CCNode {
    weak var gems: CCLabelTTF!
    weak var longLineBoughtColor: CCNodeColor!
    var gemTrack = 0 {
        didSet {
            gems.string = "\(gemTrack)"
        }
    }
    weak var gemLongLineButton: CCButton!
    weak var moneyLongLineButton: CCButton!
    var g = Gameplay()
    static var longLineBought = false {
        didSet{
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "longlinebought")

        }
    }
    weak var gemLightningButton: CCButton!
    weak var moneyLightningButton: CCButton!
    weak var lightningBoughtColor: CCNodeColor!
    static var lightningBought = false {
        didSet{
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "lightningbought")
        }
    }
    weak var gemPurpleButton: CCButton!
    weak var moneyPurpleButton: CCButton!
    weak var purpleBoughtColor: CCNodeColor!
    static var purpleBought = false {
        didSet{
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "purplebought")
        }
    }
    weak var gemShieldButton: CCButton!
    weak var moneyShieldButton: CCButton!
    weak var shieldBoughtColor: CCNodeColor!
    static var shieldBought = false {
        didSet{
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "shieldbought")
        }
    }
    weak var gemStarButton: CCButton!
    weak var moneyStarButton: CCButton!
    weak var starBoughtColor: CCNodeColor!
    static var starBought = false {
        didSet{
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "starbought")
        }
    }
    weak var gemGemButton: CCButton!
    weak var moneyGemButton: CCButton!
    weak var gemBoughtColor: CCNodeColor!
    static var gemBought = false {
        didSet{
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "gembought")
        }
    }
    
    func didLoadFromCCB(){
        gemTrack = g.getGems()
//        NSUserDefaults.standardUserDefaults().setObject(false, forKey: "gembought")
        if NSUserDefaults.standardUserDefaults().boolForKey("longlinebought") {
            longLineBoughtColor.visible = true
            gemLongLineButton.enabled = false
            moneyLongLineButton.enabled = false
        }
        if NSUserDefaults.standardUserDefaults().boolForKey("lightningbought") {
            lightningBoughtColor.visible = true
            gemLightningButton.enabled = false
            moneyLightningButton.enabled = false
        }
        if NSUserDefaults.standardUserDefaults().boolForKey("purplebought") {
            purpleBoughtColor.visible = true
            gemPurpleButton.enabled = false
            moneyPurpleButton.enabled = false
        }
        if NSUserDefaults.standardUserDefaults().boolForKey("shieldbought") {
            shieldBoughtColor.visible = true
            gemShieldButton.enabled = false
            moneyShieldButton.enabled = false
        }
        if NSUserDefaults.standardUserDefaults().boolForKey("starbought") {
            starBoughtColor.visible = true
            gemStarButton.enabled = false
            moneyStarButton.enabled = false
        }
        if NSUserDefaults.standardUserDefaults().boolForKey("gembought") {
            gemBoughtColor.visible = true
            gemGemButton.enabled = false
            moneyGemButton.enabled = false
        }
    }

    func back() {
        self.parent.paused = false
        self.removeFromParent()
//        MainScene.storePressed = false
    }
    func gemsLongLine() {
        if g.getGems() >= 5 {
            OALSimpleAudio.sharedInstance().playEffect("sounds/moneysound.wav")
            g.subGems(5)
            gemTrack = g.getGems()
            Gameplay.lineScale = 1.1
            longLineBoughtColor.visible = true
            gemLongLineButton.enabled = false
            moneyLongLineButton.enabled = false
            Store.longLineBought = true
        }
    }
    func moneyLongLine() {
        
    }
    func gemsLightning() {
        if g.getGems() >= 10 {
            OALSimpleAudio.sharedInstance().playEffect("sounds/moneysound.wav")
            g.subGems(10)
            gemTrack = g.getGems()
            Gameplay.lightningSpeed = 245
            lightningBoughtColor.visible = true
            gemLightningButton.enabled = false
            moneyLongLineButton.enabled = false
            Store.lightningBought = true

        }
    }
    func gemsPurple() {
        if g.getGems() >= 10 {
            OALSimpleAudio.sharedInstance().playEffect("sounds/moneysound.wav")
            g.subGems(10)
            gemTrack = g.getGems()
            Gameplay.purpleTime = 1650
            purpleBoughtColor.visible = true
            gemPurpleButton.enabled = false
            moneyPurpleButton.enabled = false
            Store.purpleBought = true
        }
    }
    func gemsShield() {
        if g.getGems() >= 10 {
            OALSimpleAudio.sharedInstance().playEffect("sounds/moneysound.wav")
            g.subGems(10)
            gemTrack = g.getGems()
            Gameplay.shieldHit = 2
            shieldBoughtColor.visible = true
            gemShieldButton.enabled = false
            moneyShieldButton.enabled = false
            Store.shieldBought = true
        }
    }
    func gemsStar() {
        if g.getGems() >= 15 {
            OALSimpleAudio.sharedInstance().playEffect("sounds/moneysound.wav")
            g.subGems(15)
            gemTrack = g.getGems()
            Gameplay.startSpawn = 0.34
            starBoughtColor.visible = true
            gemStarButton.enabled = false
            moneyStarButton.enabled = false
            Store.starBought = true
        }
    }
    func gemsGem() {
//        OALSimpleAudio.sharedInstance().playEffect("sounds/moneysound.wav")
        if g.getGems() >= 15 {
            OALSimpleAudio.sharedInstance().playEffect("sounds/moneysound.wav")
            g.subGems(15)
            gemTrack = g.getGems()
            Gameplay.spawnPower = 0.12//.07
            gemBoughtColor.visible = true
            gemGemButton.enabled = false
            moneyGemButton.enabled = false
            Store.gemBought = true
        }
    }
}
