//
//  Gameplay.swift
//  Jump
//
//  Created by Boris Yue on 7/2/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit
import SpriteKit

class Gameplay: CCNode {
    
    weak var scoreLabel : CCLabelTTF!
    weak var gamePhysicsNode : CCPhysicsNode!
    weak var hero : Hero!
    var gameOver = false
    var startedJumping = false
    var firstPoint: CGPoint?
    var lineNode = SKShapeNode()
    var scaleFact : Double = 0
    weak var drawLine: CCPhysicsNode!
    
    func didLoadFromCCB(){
        gamePhysicsNode.collisionDelegate = self
        userInteractionEnabled = true
        //gamePhysicsNode.debugDraw = true
//        drawLine.physicsBody.sensor = true
    }
    override func update(delta: CCTime){
        if(hero.physicsBody.velocity.y < 0){
//            var scaleDown = CCActionScaleTo(duration: 0.2, scale: 0.2)
//            hero.runAction(scaleDown)
            hero.down()
        }
        
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, ground: CCPhysicsNode!) -> Bool {
        hero.physicsBody.velocity = ccp(0,500)
        //        var scaleUp = CCActionScaleTo(duration: 0.5, scale: 0.25)
        //        hero.runAction(scaleUp)
        hero.jumpUpAnimation()
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, drawline: CCNode!) -> Bool {
        //hero.physicsBody.velocity = ccp(0,800)
        //var scaleUp = CCActionScaleTo(duration: 0.5, scale: 0.25)
        //hero.runAction(scaleUp)
        hero.jumpUpAnimation()
        if hero.physicsBody.velocity.y > 0 {
            hero.physicsBody.velocity = ccp(0,-50)
            return false
        }
        hero.physicsBody.velocity = ccp(0,500)
        return true
    }
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if (gameOver == false) {
            let line = CCBReader.load("Line") as! Line
            var worldPoint : CGPoint = touch.locationInWorld()
            line.position = worldPoint
            gamePhysicsNode.addChild(line)

        }
    }
    override func touchMoved(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        //        let path = CGPathCreateMutable()
        //        var newPos = touch.locationInNode(self)
        //        CGPathMoveToPoint(path, nil, firstPoint!.x , firstPoint!.y)
        //        CGPathAddLineToPoint(path, nil, newPos.x, newPos.y)
        //        lineNode.path = path
        //        self.addChild(lineNode) //new class?
        //        lineNode.lineWidth = 20
        //        lineNode.strokeColor = UIColor.blackColor()
        //        firstPoint = newPos
        var line = CCBReader.load("Line") as! Line
        var newPos : CGPoint = touch.locationInWorld()
        line.position = newPos
        gamePhysicsNode.addChild(line)
        
    }
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        
    }
    
}