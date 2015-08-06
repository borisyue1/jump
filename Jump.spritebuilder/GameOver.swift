//
//  GameOver.swift
//  Jump
//
//  Created by Boris Yue on 7/10/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit
import Mixpanel

class GameOver: CCNode {
    
    weak var scoreLabel : CCLabelTTF!
    weak var highScore : CCLabelTTF!
    var score: Int = 0 {
        didSet {
           scoreLabel.string = "\(score)"
        }
    }
    weak var rush: CCLabelTTF!
    weak var multipleLines: CCLabelTTF!
    weak var asteroids: CCLabelTTF!
    weak var getHigh: CCLabelTTF!
    weak var potion: CCLabelTTF!
    weak var shield: CCLabelTTF!
    weak var useGems: CCLabelTTF!
    
    func didLoadFromCCB(){
        updateHighscore()
        rush.visible = false
        multipleLines.visible = false
        asteroids.visible = false
        getHigh.visible = false
        potion.visible = false
        shield.visible = false
        useGems.visible = false
    }
    func updateHighscore() {
        if Gameplay.boundary {
            var newHighscore = NSUserDefaults.standardUserDefaults().integerForKey("highscoreeasy")
            highScore.string = "\(newHighscore)"
        }
        else {
            var newHighscore = NSUserDefaults.standardUserDefaults().integerForKey("highscorehard")
            highScore.string = "\(newHighscore)"
        
        }
    }
    override func update(delta: CCTime) {
        if Gameplay.boundary {
            let defaults = NSUserDefaults.standardUserDefaults()
            var currentHighscore = defaults.integerForKey("highscoreeasy")
            highScore.string = "\(currentHighscore)"
        }
        else {
            let defaults = NSUserDefaults.standardUserDefaults()
            var currentHighscore = defaults.integerForKey("highscorehard")
            highScore.string = "\(currentHighscore)"
        }
    }
    func share() {
        Mixpanel.sharedInstance().track("Game Over", properties: ["Share": "Share clicked"])
        var scene = CCDirector.sharedDirector().runningScene
        var node: AnyObject = scene.children[0]
        var screenshot = screenShotWithStartNode(node as! CCNode)
        
        let sharedText = "Check out this awesome game!!"
        let itemsToShare = [screenshot, sharedText]
        
        var excludedActivities = [ UIActivityTypeAssignToContact,
            UIActivityTypeAddToReadingList, UIActivityTypePostToTencentWeibo]
        
        var controller = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        controller.excludedActivityTypes = excludedActivities
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(controller, animated: true, completion: nil)
        
    }
    
    func screenShotWithStartNode(node: CCNode) -> UIImage {
        CCDirector.sharedDirector().nextDeltaTimeZero = true
        var viewSize = CCDirector.sharedDirector().viewSize()
        var rtx = CCRenderTexture(width: Int32(viewSize.width), height: Int32(viewSize.height))
        rtx.begin()
        node.visit()
        rtx.end()
        return rtx.getUIImage()
    }
    func displayTip() {
        var rand = CCRANDOM_0_1()
        if rand < 0.143 {
            rush.visible = true
        }
        else if rand < 0.286 {
            multipleLines.visible = true
        }
        else if rand < 0.429 {
            asteroids.visible = true
        }
        else if rand < 0.571{
            getHigh.visible = true
        }
        else if rand < 0.714 {
            potion.visible = true
        }
        else if rand < 0.857 {
            shield.visible = true
        }
        else {
            useGems.visible = true
        }
    }

}
