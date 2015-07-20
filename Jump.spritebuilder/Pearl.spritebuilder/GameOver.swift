//
//  GameOver.swift
//  Pearl
//
//  Created by Shivam Dave on 7/19/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class GameOver: CCScene {
    
    weak var scoreLabel: CCLabelTTF!
    var score = 0 {
        
        didSet{
            
            scoreLabel.string = "\(score)"
        }
    }
    
    
   
    
    func restart(){
    
    var mainScene = CCBReader.load("Gameplay") as! Gameplay
    var scene = CCScene()
    scene.addChild(mainScene)
    var transition = CCTransition(fadeWithDuration: 0.2)
    CCDirector.sharedDirector().presentScene(scene, withTransition: transition)
    
    
    
    
    
    
    
    
    }
   
}
