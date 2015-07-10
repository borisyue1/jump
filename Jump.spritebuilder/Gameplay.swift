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
    var score : Int = 0 {
        didSet{
            scoreLabel.string = "\(score)"
        }
    }
    weak var gamePhysicsNode : CCPhysicsNode!
    weak var hero : Hero!
    var gameOver = false
    var startedJumping = false
    var firstPoint: CGPoint?
    weak var drawLine: CCPhysicsNode!
    weak var contentNode : CCNode!
    var startPoint: CGPoint?
    var endPoint: CGPoint?
    var linesList : [Line] = []
    var touchMoved : Bool = false
    weak var sky1 : CCNode!
    weak var sky2 : CCNode!
    weak var ground: CCNode!
    var backgrounds = [CCNode]()
    var addToY : CGFloat = 0
    var canDrawNext = false
    
    func didLoadFromCCB(){
        gamePhysicsNode.collisionDelegate = self
        userInteractionEnabled = true
        //gamePhysicsNode.debugDraw = true
//        drawLine.physicsBody.sensor = true
        backgrounds.append(sky1)
        backgrounds.append(sky2)
    }
    override func onEnter(){
        super.onEnter()
//        let actionFollow = CCActionFollow(target: hero, worldBoundary: boundingBox())
//        contentNode.runAction(actionFollow)
//        contentNode.position.y = -300
    }
    override func update(delta: CCTime){
        if(hero.physicsBody.velocity.y < 0){
            startedJumping = false
            hero.down()
        }
        if hero.physicsBody.velocity.y < -200 {
            canDrawNext = true
        }
        if(linesList.count > 0 ){
            checkTimeForLines()
        }
        checkOffScreen()
        if startedJumping {
            contentNode.position = ccpAdd(contentNode.position, ccp(0, -6))//6
            addToY += 6
            score += 13
//        contentNode.position = ccpAdd(contentNode.position, ccp(0, -10))

        }
        checkWallsOffScreen()
        
    }
    func checkWallsOffScreen(){
        for sky in backgrounds {
            let skyWorldPosition = gamePhysicsNode.convertToWorldSpace(sky.position)
            let skyScreenPosition = convertToNodeSpace(skyWorldPosition)
            if skyScreenPosition.y <= (-sky.boundingBox().height) {
                sky.position = ccp(sky.position.x, sky.position.y + sky.boundingBox().height * 2 )
            }
        }
    }
    func checkTimeForLines() {
        for var s = linesList.count - 1; s>=0; --s {
            linesList[s].increaseTime(1)
            if linesList[s].getTime() > 40 {
//                var transition = CCActionFadeOut(duration: CCTime(10))
//                linesList[s].runAction(transition)
                gamePhysicsNode.removeChild(linesList[s])
                linesList.removeAtIndex(s)
            }
        }
    }
    func checkOffScreen() {
        let heroWorldPosition = gamePhysicsNode.convertToWorldSpace(hero.position)
        let heroScreenPosition = convertToNodeSpace(heroWorldPosition)
        if heroScreenPosition.x <= (-hero.boundingBox().width) {
            hero.position = ccp(hero.position.x + hero.contentSize.width + 10, hero.position.y)
        }
        else if heroScreenPosition.x > (hero.contentSize.width ) {
            hero.position = ccp(-hero.boundingBox().width, hero.position.y)
        }
        if heroScreenPosition.y < -20 {
            triggerGameOver()
        }
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, ground: CCPhysicsNode!) -> Bool {
        //hero.physicsBody.velocity = ccp(0,500)
        hero.jumpUpAnimation()
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, drawline: CCNode!) -> Bool {
        hero.jumpUpAnimation()
        hero.physicsBody.angularVelocity = 1
//        hero.physicsBody.applyImpulse(ccp(0,1000))
//        if hero.physicsBody.velocity.y > 0 {
//            hero.physicsBody.velocity = ccp(0,-10)
//            return false
//        }
//        hero.physicsBody.velocity = ccp(0,1000)//585
        startedJumping = true
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, alien: CCNode!) -> Bool {
        hero.physicsBody.velocity = ccp(0,-300)
        triggerGameOver()
        return true
    }
    func triggerGameOver() {
        gameOver = true
        var gameOverScreen = CCBReader.load("GameOver", owner: self) as! GameOver
        self.addChild(gameOverScreen)
    }
    func restart() {
        var mainScene = CCBReader.load("Gameplay") as! Gameplay
        var scene = CCScene()
        scene.addChild(mainScene)
        
        var transition = CCTransition(fadeWithDuration: 0.3)
        
        CCDirector.sharedDirector().presentScene(scene, withTransition: transition)
    }
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if (gameOver == false) {
            startPoint = ccpAdd(touch.locationInWorld(), ccp(0, addToY))


        }
    }

    override func touchMoved(touch: CCTouch!, withEvent event: CCTouchEvent!) {
      touchMoved = true
    }
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if canDrawNext {
            if(touchMoved){
                endPoint = ccpAdd(touch.locationInWorld(), ccp(0, addToY))
                var distanceOne = hypotf(Float(startPoint!.x - endPoint!.x), Float(startPoint!.y - endPoint!.y))
                var distanceTwo : Float = Float(abs(startPoint!.x - endPoint!.x))
                var product  = (distanceTwo) / distanceOne
                var radian: Float = acos(product)
                var angle: Float = radian * 180 / Float(M_PI)
                if(startPoint!.y < endPoint!.y && startPoint!.x < endPoint!.y){
                    angle = 360 - radian * 180 / Float(M_PI)
                }
                if(startPoint!.y < endPoint!.y && startPoint!.x > endPoint!.x){
                    angle = 180 + radian * 180 / Float(M_PI)
                }
                if(startPoint!.y > endPoint!.y && startPoint!.x > endPoint!.x){
                    angle = 180 -  radian * 180 / Float(M_PI)
                }
                var scaleFact = distanceOne / Float(151)
                var line = CCBReader.load("Line") as! Line
                line.rotation = angle
                if scaleFact > 0.75 {
                    line.scaleX = 0.75
                } else{  line.scaleX = scaleFact }
                line.position = ccp(startPoint!.x, startPoint!.y)
                gamePhysicsNode.addChild(line)
                linesList.append(line)
                touchMoved = false
            }
            canDrawNext = false
        }
    }
    
}