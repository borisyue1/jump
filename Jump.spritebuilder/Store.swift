//
//  Store.swift
//  Jump
//
//  Created by Boris Yue on 7/27/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit
import StoreKit
import Mixpanel

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
    var restorePop: CCNode!
    
    func didLoadFromCCB(){
        gemTrack = g.getGems()
        if MKStoreKit.sharedKit().isProductPurchased("com.yueboris.bounceyblob.longerlines") {
            Store.longLineBought = true
        }
        if MKStoreKit.sharedKit().isProductPurchased("com.yueboris.bounceyblob.longerlightningpowerup") {
            Store.lightningBought = true
        }
        if MKStoreKit.sharedKit().isProductPurchased("com.yueboris.bounceyblob.longerpotionpowerup") {
            Store.purpleBought = true
        }
        if MKStoreKit.sharedKit().isProductPurchased("com.yueboris.bounceyblob.longershieldpowerup") {
            Store.shieldBought = true
        }
        if MKStoreKit.sharedKit().isProductPurchased("com.yueboris.bounceyblob.morepowerups") {
            Store.starBought = true
        }
        if MKStoreKit.sharedKit().isProductPurchased("com.yueboris.bounceyblob.moregems") {
            Store.gemBought = true
        }
//        NSUserDefaults.standardUserDefaults().setObject(false, forKey: "longlinebought")
//        NSUserDefaults.standardUserDefaults().setObject(false, forKey: "lightningbought")
//        NSUserDefaults.standardUserDefaults().setObject(false, forKey: "purplebought")
//        NSUserDefaults.standardUserDefaults().setObject(false, forKey: "shieldbought")
//        NSUserDefaults.standardUserDefaults().setObject(false, forKey: "starbought")
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
//        var timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("longLine"), userInfo: nil, repeats: true)
      
    }
    func longLine() {
        NSNotificationCenter.defaultCenter().addObserverForName(kMKStoreKitProductPurchasedNotification, object: nil, queue: NSOperationQueue(), usingBlock: {
                (note: NSNotification!) in
                println("purchased!!!")
        })
    }
    
    func back() {
        self.parent.paused = false
        self.removeFromParent()
//        MainScene.storePressed = false
    }
    func gemsLongLine() {
        if g.getGems() >= 5 {
//            OALSimpleAudio.sharedInstance().playEffect("sounds/moneysound.wav")
            Mixpanel.sharedInstance().track("Upgrade bought", properties: ["Gem": "Longer lines"])
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
        MKStoreKit.sharedKit().initiatePaymentRequestForProductWithIdentifier("com.yueboris.bounceyblob.longerlines")
//        NSNotificationCenter.defaultCenter().addObserverForName(kMKStoreKitProductPurchasedNotification, object: nil, queue: NSOperationQueue(), usingBlock: {
//            (note: NSNotification!) in
//            println("purchased!!!")
//            println(MKStoreKit.sharedKit().valueForKey( "purchaseRecord"))
//        })
    }
    func gemsLightning() {
        if g.getGems() >= 10 {
            Mixpanel.sharedInstance().track("Upgrade bought", properties: ["Gem": "Longer lightning"])
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
    func moneyLightning() {
        MKStoreKit.sharedKit().initiatePaymentRequestForProductWithIdentifier("com.yueboris.bounceyblob.longerlightningpowerup")
    }
    func gemsPurple() {
        if g.getGems() >= 10 {
            Mixpanel.sharedInstance().track("Upgrade bought", properties: ["Gem": "Longer potion"])
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
    func moneyPurple() {
        MKStoreKit.sharedKit().initiatePaymentRequestForProductWithIdentifier("com.yueboris.bounceyblob.longerpotionpowerup")
    }
    func gemsShield() {
        if g.getGems() >= 10 {
            Mixpanel.sharedInstance().track("Upgrade bought", properties: ["Gem": "Longer shield"])
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
    func moneyShield() {
        MKStoreKit.sharedKit().initiatePaymentRequestForProductWithIdentifier("com.yueboris.bounceyblob.longershieldpowerup")

    }
    func gemsStar() {
        if g.getGems() >= 15 {
            Mixpanel.sharedInstance().track("Upgrade bought", properties: ["Gem": "More powerups"])
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
    func moneyStar() {
        MKStoreKit.sharedKit().initiatePaymentRequestForProductWithIdentifier("com.yueboris.bounceyblob.morepowerups")
    }
    func gemsGem() {
        if g.getGems() >= 15 {
            Mixpanel.sharedInstance().track("Upgrade bought", properties: ["Gem": "More gems"])
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
    func moneyGem() {
        MKStoreKit.sharedKit().initiatePaymentRequestForProductWithIdentifier("com.yueboris.bounceyblob.moregems")

    }
    func restore() {
        MKStoreKit.sharedKit().restorePurchases()
        Mixpanel.sharedInstance().track("Upgrade bought", properties: ["Restore": "Restore clicked"])
    }
    func question() {
        Mixpanel.sharedInstance().track("Upgrade bought", properties: ["Restore": "Question clicked"])
        restorePop = CCBReader.load("Restore", owner: self) as CCNode
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            restorePop.contentSize = CGSize(width: 384, height: 512)
        }
        self.addChild(restorePop)
    }
    func backRestore() {
        self.removeChild(restorePop)
    }
}

