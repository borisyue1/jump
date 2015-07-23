//
//  Mode.swift
//  Jump
//
//  Created by Boris Yue on 7/19/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class Mode: CCNode {
   
    func boundary() {
        Gameplay.boundary = true
        let gameplayScene = CCBReader.loadAsScene("Gameplay")
        var transition = CCTransition(fadeWithDuration: 0.3)
        CCDirector.sharedDirector().presentScene(gameplayScene, withTransition: transition)
    }
    func noboundary() {
        Gameplay.boundary = false
        let gameplayScene = CCBReader.loadAsScene("Gameplay")
        var transition = CCTransition(fadeWithDuration: 0.3)
        CCDirector.sharedDirector().presentScene(gameplayScene, withTransition: transition)
    }
    func back() {
        let gameplayScene = CCBReader.loadAsScene("MainScene")
        CCDirector.sharedDirector().presentScene(gameplayScene)
    }
}
