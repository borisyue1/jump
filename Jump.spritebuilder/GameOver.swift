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
    weak var restartButton : CCButton!
    
    func didLoadFromCCB(){
        //NSUserDefaults.standardUserDefaults().addObserver(self, forKeyPath: "highscore", options: .allZeros, context: nil)
        updateHighscore()
    }
    func updateHighscore() {
        var newHighscore = NSUserDefaults.standardUserDefaults().integerForKey("highscore")
        highScore.string = "\(newHighscore)"
    }
    override func update(delta: CCTime) {
        let defaults = NSUserDefaults.standardUserDefaults()
        var currentHighscore = defaults.integerForKey("highscore")
        highScore.string = "\(currentHighscore)"
    }
//    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
//        if keyPath == "highscore" {
//            updateHighscore()
//        }
//    }
//    func didLoadFromCCB() {
//        restartButton.cascadeOpacityEnabled = true
//        restartButton.runAction(CCActionFadeIn(duration: 0.3))
//    }

}
