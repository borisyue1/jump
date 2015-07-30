//
//  GameOver.swift
//  Jump
//
//  Created by Boris Yue on 7/10/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class GameOver: CCNode {
    
    weak var scoreLabel : CCLabelTTF!
    weak var highScore : CCLabelTTF!
    var score: Int = 0 {
        didSet {
           scoreLabel.string = "\(score)"
        }
    }
    weak var b: CCButton!
    
    
    func didLoadFromCCB(){
        updateHighscore()
       
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
        var scene = CCDirector.sharedDirector().runningScene
        var node: AnyObject = scene.children[0]
        var screenshot = screenShotWithStartNode(node as! CCNode)
        
        let sharedText = "This is some default text that I want to share with my users. [This is where I put a link to download my awesome game]"
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


}
