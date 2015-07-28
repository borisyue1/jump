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

//    func didLoadFromCCB() {
//        restartButton.cascadeOpacityEnabled = true
//        restartButton.runAction(CCActionFadeIn(duration: 0.3))
//    }

}
