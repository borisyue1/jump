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
    var trackerAlien: Int = 0
    var trackerAsteroid: Int = 0
    var trackerBird: Int = 0
    var trackerUfoAlien = 0
    var spawnControlTimeBird = 180
    var spawnControlTime = 400
    var tooLarge = false
    var tooLargeOther = false
    var wayTooLarge = false
    var wayTooLargeOther = false
    var xVel: CGFloat = 0

    func didLoadFromCCB(){
        gamePhysicsNode.collisionDelegate = self
        userInteractionEnabled = true
//        gamePhysicsNode.debugDraw = true
        backgrounds.append(sky1)
        backgrounds.append(sky2)
    
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
            contentNode.position = ccpAdd(contentNode.position, ccp(0, -6))//6
            addToY += 6
            score += 16

        }
        if firstJump {
            trackerAlien++
            trackerAsteroid++
            trackerBird++
            trackerUfoAlien++
        }
        checkWallsOffScreen()
        spawnBirds()
        spawnAsteroids()
        spawnAliens()
        spawnUfoAliens()
        
    }
    func spawnBirds(){
        var addToTime = CCRANDOM_0_1() * 200 - 50
        if hero.position.y < 3400 {
            if trackerBird > spawnControlTimeBird  + Int(addToTime) {
                var randY = CCRANDOM_0_1() * 200 + 300
                var bird = CCBReader.load("Bird") as! Bird
                gamePhysicsNode.addChild(bird)
                stuff.append(bird)
                bird.position = CGPoint(x: CGFloat(-50), y: hero.position.y + CGFloat(randY))
                trackerBird = 0
                spawnControlTimeBird+=250
            }
        }
       
    }
    func spawnAsteroids(){
        if trackerAsteroid > spawnControlTime {
            var randX = CCRANDOM_0_1() * 270 + 10
            var randY = CCRANDOM_0_1() * 150 + 400
            var asteroid = CCBReader.load("Asteroid") as! Asteroid
            gamePhysicsNode.addChild(asteroid)
            stuff.append(asteroid)
            asteroid.position = CGPoint(x: CGFloat(randX), y: hero.position.y + CGFloat(randY))
            //            println(asteroid.position)
            checkAliensandObstaclesOffScreen()
            spawnControlTime--
            trackerAsteroid = 0
        }
        if spawnControlTime <= 80 {
            spawnControlTime = 80
        }
    }
    func spawnAliens(){
        var addToTime = CCRANDOM_0_1() * 50 + 80
        if trackerAlien > spawnControlTime + Int(addToTime) {
            var randX = CCRANDOM_0_1() * 270 + 10
            var randY = CCRANDOM_0_1() * 150 + 700
            var alien = CCBReader.load("MonsterAlien") as! MonsterAlien
            gamePhysicsNode.addChild(alien)
            stuff.append(alien)
            alien.position = CGPoint(x: CGFloat(randX), y: hero.position.y + CGFloat(randY))
            
            trackerAlien = 0
        }
        
        
    }
    func spawnUfoAliens(){
        var addToTime = CCRANDOM_0_1() * 400 + 500
        if trackerUfoAlien > spawnControlTime + Int(addToTime) {
            var randX = CCRANDOM_0_1() * 210 + 10
            var randY = CCRANDOM_0_1() * 150 + 700
            var ufoalien = CCBReader.load("UfoAlien") as! UfoAlien
            gamePhysicsNode.addChild(ufoalien)
            stuff.append(ufoalien)
            ufoalien.position = CGPoint(x: CGFloat(randX), y: hero.position.y + CGFloat(375))
            trackerUfoAlien = 0
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
            hero.physicsBody.velocity.x -= 25
        }
        else if heroScreenPosition.x - hero.boundingBox().width / 2 > (self.boundingBox().width ) {
            hero.position = ccp(-hero.boundingBox().width / 2, hero.position.y)
            hero.physicsBody.velocity.x += 25

        }
//        while heroScreenPosition.x - hero.boundingBox().width / 2 <= 0 {
//            heroScreenPosition = ccpAdd(heroScreenPosition, ccp(5, 0))
//            println(heroScreenPosition)
//        }
        if heroScreenPosition.y < -20 {
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
//        var xVel = hero.physicsBody.velocity.x
//        println(yVel)
//        if yVel < -900 {
//            yVel = CGFloat(clampf(Float(yVel), Float(yVel  * 0.9), Float(yVel * 0.8)))
//            println(yVel)
//
//        }
//         if yVel < -1000 {
//            yVel = CGFloat(clampf(Float(yVel), Float(yVel  * 0.85), Float(yVel * 0.8)))
//            println(yVel)
//
//        }
//        else if yVel < -1300 {
//            yVel = CGFloat(clampf(Float(yVel), Float(yVel  * 0.6), Float(yVel * 0.5)))
//            println(yVel)
//            
//        }
        var constantY: CGFloat = -1000
//        if tooLarge {
//            xVel = 350
//            constantY = -950
//            tooLarge = false
//        }
//        else if tooLargeOther {
//            xVel = -350
//            constantY = -950
//            wayTooLarge = false
//        }
//        else if wayTooLarge {
//            xVel = 700
//            constantY = -775
//            tooLarge = false
//        }
//        else if wayTooLargeOther {
//            xVel = -700
//            constantY = -770
//            wayTooLarge = false
//        }
        println(xVel)
        hero.physicsBody.velocity = ccp(xVel, constantY )
        startedJumping = true
        firstJump = true
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, bird: CCNode!) -> Bool {
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
    func triggerGameOver() {
        gameOver = true
        var gameOverScreen = CCBReader.load("GameOver", owner: self) as! GameOver
        self.addChild(gameOverScreen)
        gameOverScreen.score = self.score
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
//                if angle > 25 && endPoint!.y > startPoint!.y && endPoint!.x > startPoint!.x {
//                    wayTooLarge = true
//                }
//                else if angle > 25 && endPoint!.y < startPoint!.y && endPoint!.x < startPoint!.x {
//                    wayTooLarge = true
//                }
//                else if angle > 25 && endPoint!.y < startPoint!.y && endPoint!.x > startPoint!.x {
//                    wayTooLargeOther = true
//                }
//                else if angle > 25 && endPoint!.y > startPoint!.y && endPoint!.x < startPoint!.x {
//                    wayTooLargeOther = true
//                }
//                else if angle > 10 && endPoint!.y > startPoint!.y && endPoint!.x > startPoint!.x {
//                    tooLarge = true
//                }
//                else if angle > 10 && endPoint!.y < startPoint!.y && endPoint!.x < startPoint!.x {
//                    tooLarge = true
//                }
//                else if angle > 10 && endPoint!.y < startPoint!.y && endPoint!.x > startPoint!.x {
//                    tooLargeOther = true
//                }
//                else if angle > 10 && endPoint!.y > startPoint!.y && endPoint!.x < startPoint!.x {
//                    tooLargeOther = true
//                }
                            if endPoint!.y > startPoint!.y && endPoint!.x > startPoint!.x {
                                    xVel = CGFloat(angle * 20)
                                }
                                else if endPoint!.y < startPoint!.y && endPoint!.x < startPoint!.x {
                                xVel = CGFloat(angle * 20)
                                }
                                else if endPoint!.y < startPoint!.y && endPoint!.x > startPoint!.x {
                                xVel = CGFloat(-angle * 20)

                                }
                                else if endPoint!.y > startPoint!.y && endPoint!.x < startPoint!.x {
                                xVel = CGFloat(-angle * 20)
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