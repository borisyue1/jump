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
    var firstJump = false
    var firstPoint: CGPoint?
    weak var drawLine: CCPhysicsNode!
    weak var contentNode : CCNode!
    var startPoint: CGPoint?
    var endPoint: CGPoint?
    var linesList : [Line] = []
    var touchMoved : Bool = false
    weak var sky1 : CCNode!
    weak var sky2 : CCNode!
    var backgrounds = [CCNode]()
    var stuff = [CCNode]()
    var addToY : CGFloat = 0
    var canDrawNext = false
    var tooLarge = false
    var tooLargeOther = false
    var wayTooLarge = false
    var jumped = false
    var wayTooLargeOther = false
    var xVel: CGFloat = 0
    var jumps = 0
    var asteroidProb: Float = 0.2
    var birdProb: Float = 1.0
    var alienProb: Float = 0
    var ufoProb: Float = 0.0
    var randThresh = CCRANDOM_0_1() * 400 + 900

    
    func didLoadFromCCB(){
        gamePhysicsNode.collisionDelegate = self
        userInteractionEnabled = true
//        gamePhysicsNode.debugDraw = true
        backgrounds.append(sky1)
        backgrounds.append(sky2)
//        var bird = CCBReader.load("Bird") as! Bird
//        gamePhysicsNode.addChild(bird)
//        stuff.append(bird)
//        bird.position = ccp(CGFloat(0), hero.position.y + CGFloat(200))

    }

    override func update(delta: CCTime) {
        if gameOver {
            return
        }
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
            contentNode.position = ccpAdd(contentNode.position, ccp(0, -7))//6
            addToY += 7
            score += 16

        }
        if firstJump {
            if hero.position.y > CGFloat(randThresh) && jumped && hero.physicsBody.velocity.y < 0{
                spawnRandomStuff()
                jumped = false
            }

        }
        checkWallsOffScreen()

        
    }
    func spawnRandomStuff(){
        checkAliensandObstaclesOffScreen()
        var randX = CCRANDOM_0_1() * 260 + 20
        var jumpNum = CCRANDOM_0_1()
        if jumpNum < 0.7 {
            var rand = CCRANDOM_0_1()
            if rand < asteroidProb {
                var asteroid = CCBReader.load("Asteroid") as! Asteroid
                gamePhysicsNode.addChild(asteroid)
                stuff.append(asteroid)
                asteroid.position = ccp(CGFloat(randX), hero.position.y + CGFloat(650))
            }
            else if rand > asteroidProb  &&  rand < birdProb {
                var bird = CCBReader.load("Bird") as! Bird
                gamePhysicsNode.addChild(bird)
                stuff.append(bird)
                bird.position = ccp(CGFloat(randX), hero.position.y + CGFloat(312))
            }
            else if rand > birdProb  &&  rand < alienProb {
                var alien = CCBReader.load("MonsterAlien") as! MonsterAlien
                gamePhysicsNode.addChild(alien)
                stuff.append(alien)
                alien.position = ccp(CGFloat(randX), hero.position.y + CGFloat(312))
            }
            else if rand > alienProb  &&  rand < ufoProb {
                var randUfoX = CCRANDOM_0_1() * 180 + 30
                var ufo = CCBReader.load("UfoAlien") as! UfoAlien
                gamePhysicsNode.addChild(ufo)
                stuff.append(ufo)
                ufo.position = ccp(CGFloat(randUfoX), hero.position.y + CGFloat(312))
            }
            asteroidProb += 0.02
            birdProb -= 0.15
            alienProb += 0.08
            ufoProb += 0.06
            if asteroidProb > 0.3 {
                asteroidProb = 0.3
            }
            if alienProb > 0.75 {
                alienProb = 0.75
            }
            if ufoProb > 1.0 {
                ufoProb = 1.0
            }
        }
    }
    func checkAliensandObstaclesOffScreen(){
        for var s = stuff.count - 1; s>=0; s-- {
            var a = stuff[s]
            let alienWorldPosition = gamePhysicsNode.convertToWorldSpace(a.position)
            let alienScreenPosition = convertToNodeSpace(alienWorldPosition)
            if alienScreenPosition.y < 0 || alienScreenPosition.x > 350{
                stuff.removeAtIndex(s)
                gamePhysicsNode.removeChild(a)
            }
        }
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
        var heroWorldPosition = gamePhysicsNode.convertToWorldSpace(hero.position)
        var heroScreenPosition = convertToNodeSpace(heroWorldPosition)
        if heroScreenPosition.x < (-hero.boundingBox().width / 2) {
            hero.position = ccp( self.boundingBox().width + hero.boundingBox().width / 2, hero.position.y)
            hero.physicsBody.velocity.x -= 70
            hero.physicsBody.velocity.y += 70
        }
        else if heroScreenPosition.x - hero.boundingBox().width / 2 > (self.boundingBox().width ) {
            hero.position = ccp(-hero.boundingBox().width / 2, hero.position.y)
            hero.physicsBody.velocity.x += 70
            hero.physicsBody.velocity.y += 70

        }
//        while heroScreenPosition.x - hero.boundingBox().width / 2 <= 0 {
//            heroScreenPosition = ccpAdd(heroScreenPosition, ccp(5, 0))
//            println(heroScreenPosition)
//        }
        if heroScreenPosition.y < -hero.boundingBox().height / 2 {
            triggerGameOver()
        }
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, ground: CCPhysicsNode!) -> Bool {
        if gameOver {
            return false
        }
        hero.jumpUpAnimation()
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, drawline: CCNode!) -> Bool {
        if gameOver || hero.physicsBody.velocity.y > 0 {
            hero.physicsBody.velocity.y = 10
            return false
        }
        hero.jumpUpAnimation()
        hero.physicsBody.angularVelocity = 1
        var yVel = hero.physicsBody.velocity.y * 2.5
        var constantY: CGFloat = -1000
        println(xVel)
        hero.physicsBody.velocity = ccp(xVel, constantY )
        startedJumping = true
        firstJump = true
        jumped = true
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, bird: CCNode!) -> Bool {
        println("adfadf")
        triggerGameOver()
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, alien: CCNode!) -> Bool {
        hero.physicsBody.velocity = ccp(0,-300)
        triggerGameOver()
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, laser: CCNode!) -> Bool {
        triggerGameOver()
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, ufo: CCNode!) -> Bool {
        hero.physicsBody.velocity = ccp(0,-300)
        triggerGameOver()
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, lightning: CCNode!) -> Bool {
        gamePhysicsNode.removeChild(lightning)
        return true
    }
//    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, bird: CCSprite!, drawline: CCNode!) -> Bool {
//        
//        gamePhysicsNode.removeChild(bird)
//        stuff = stuff.filter() { $0 != bird }
//        return true
//    }

    func triggerGameOver() {
        gameOver = true
        var gameOverScreen = CCBReader.load("GameOver", owner: self) as! GameOver
        self.addChild(gameOverScreen)
        gameOverScreen.score = self.score
//        let defaults = NSUserDefaults.standardUserDefaults()
//        var highscore = defaults.integerForKey("highscore")
//        if self.score > highscore {
//            defaults.setInteger(self.score, forKey: "highscore")
//        }
    }
    func restart() {
        var mainScene = CCBReader.load("Gameplay") as! Gameplay
        var scene = CCScene()
        scene.addChild(mainScene)
        
        var transition = CCTransition(fadeWithDuration: 0.3)
        
        CCDirector.sharedDirector().presentScene(scene, withTransition: transition)
        gameOver = false
    }
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
//        if !firstJump {
//            if touch.locationInWorld().x < CGFloat(50) || touch.locationInWorld().x > CGFloat(280) || touch.locationInWorld().y < CGFloat(48) || touch.locationInWorld().y > CGFloat(200) {
//                return
//            }
//            
//        }
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
                println(angle)
                if endPoint!.y > startPoint!.y && endPoint!.x > startPoint!.x {
                    xVel = CGFloat(angle * 22)
                }
                else if endPoint!.y < startPoint!.y && endPoint!.x < startPoint!.x {
                    xVel = CGFloat(angle * 22)
                }
                else if endPoint!.y < startPoint!.y && endPoint!.x > startPoint!.x {
                    xVel = CGFloat(-angle * 22)

                }
                else if endPoint!.y > startPoint!.y && endPoint!.x < startPoint!.x {
                    xVel = CGFloat(-angle * 22)
                }
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
                if scaleFact > 0.9 {
                    line.scaleX = 0.9
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