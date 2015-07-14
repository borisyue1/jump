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
    var score: Int = 0 {
        didSet {
           scoreLabel.string = "\(score)"
        }
    }
    weak var restartButton : CCButton!
    
//    func didLoadFromCCB() {
//        restartButton.cascadeOpacityEnabled = true
//        restartButton.runAction(CCActionFadeIn(duration: 0.3))
//    }

}
