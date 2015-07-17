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
    weak var drawLine: CCPhysicsNode!
    weak var contentNode : CCNode!
    weak var sky1 : CCNode!
    weak var sky2 : CCNode!
    var gameOver = false
    var startedJumping = false
    var firstJump = false
    var cantDraw = false
    var firstPoint: CGPoint?
    var startPoint: CGPoint?
    var endPoint: CGPoint?
    var linesList : [Line] = []
    var touchMoved : Bool = false
    var backgrounds = [CCNode]()
    var stuff = [CCNode]()
    var addToY : CGFloat = 0
    var jumped = false
    var xVel: CGFloat = 0
    var yVel: CGFloat = -1000
    var asteroidProb: Float = 0.2
    var birdProb: Float = 1.0
    var alienProb: Float = 0
    var ufoProb: Float = 0.0
    var randThresh = CCRANDOM_0_1() * 300 + 900
    var jumpPos : CGPoint?
    let constant = 0.006
    var jump: Jump?
    var lightningTouched = false
    var shieldTouched = false
    var powerupTrack = 0
    var shield: ShieldCircle?
    var canSpawn : Float = 0.22
    

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
        if !lightningTouched {
            if hero.physicsBody.velocity.y < 0 {
                startedJumping = false
                hero.down()
            }
            if(linesList.count > 0 ){
                checkTimeForLines()
            }
            checkOffScreen()
//            println(hero.physicsBody.velocity.y)
            if startedJumping {
                var scrollRate = jumpPos!.y * 0.0063 + 6.5
                contentNode.position = ccpAdd(contentNode.position, ccp(0, -scrollRate))
                addToY += scrollRate
                score += 16
                if hero.position.y > CGFloat(randThresh) && hero.physicsBody.velocity.y < 120 && hero.physicsBody.velocity.y > 110 {
                    spawnRandomStuff()
                    if hero.position.y > CGFloat(randThresh) + 800 {
                        spawnPowerUps()
                    }
                    jumped = false
                }

            }
        }
        else {
            powerupTrack++
            contentNode.position = ccpAdd(contentNode.position, ccp(0, -30))
            addToY += 30
            score += 20
            hero.physicsBody.velocity.y = 1825
            hero.physicsBody.velocity.x = 0
            if powerupTrack > 175 {
                lightningTouched = false
                powerupTrack = 0
                hero.physicsBody.velocity.y = 0
            }
        }
        if shieldTouched {
            shield = CCBReader.load("ShieldCircle") as? ShieldCircle
            contentNode.addChild(shield)
            shieldTouched = false
        }
        if let shieldPresent = shield {
            shieldPresent.position = hero.position
        }
        checkWallsOffScreen()

        
    }

    func spawnPowerUps(){
        var randX = CCRANDOM_0_1() * 270 + 20
        var rand = CCRANDOM_0_1()
        if rand < canSpawn {
            var prob = CCRANDOM_0_1()
            if prob < 0.35 {
                var lightning = CCBReader.load("Lightning") as! Lightning
                gamePhysicsNode.addChild(lightning)
                lightning.position = ccp(CGFloat(randX), hero.position.y + CGFloat(320))
            }
            else {
                var shield = CCBReader.load("Shield") as! Shield
                gamePhysicsNode.addChild(shield)
                shield.position = ccp(CGFloat(randX), hero.position.y + CGFloat(320))
            }
            canSpawn -= 0.08
            if canSpawn <= 0.08 {
                canSpawn = 0.08
            }
        }
    }
    func spawnRandomStuff(){
        checkAliensandObstaclesOffScreen()
        var randX = CCRANDOM_0_1() * 260 + 20
        var jumpNum = CCRANDOM_0_1()
        if jumpNum < 0.6 {
            var rand = CCRANDOM_0_1()
            if rand < asteroidProb {
                var asteroid = CCBReader.load("Asteroid") as! Asteroid
                gamePhysicsNode.addChild(asteroid)
                stuff.append(asteroid)
                asteroid.position = ccp(CGFloat(randX), hero.position.y + CGFloat(1000))
            }
            else if rand > asteroidProb  &&  rand < birdProb {
                var bird = CCBReader.load("Bird") as! Bird
                gamePhysicsNode.addChild(bird)
                stuff.append(bird)
                bird.position = ccp(CGFloat(randX), hero.position.y + CGFloat(320))
                
            }
            else if rand > birdProb  &&  rand < alienProb {
                var alien = CCBReader.load("MonsterAlien") as! MonsterAlien
                gamePhysicsNode.addChild(alien)
                stuff.append(alien)
                alien.position = ccp(CGFloat(randX), hero.position.y + CGFloat(320))
            }
            else if rand > alienProb  &&  rand < ufoProb {
                println("ufo spawned")
                var randUfoX = CCRANDOM_0_1() * 180 + 30
                var ufo = CCBReader.load("UfoAlien") as! UfoAlien
                gamePhysicsNode.addChild(ufo)
                stuff.append(ufo)
                ufo.position = ccp(CGFloat(randUfoX), hero.position.y + CGFloat(320))
            }
            asteroidProb += 0.04
            birdProb -= 0.1
            alienProb += 0.18
            ufoProb += 0.08
            if asteroidProb > 0.4 {
                asteroidProb = 0.4
            }
            if alienProb > 0.8 {
                alienProb = 0.8
            }

        }
    }
    func checkAliensandObstaclesOffScreen(){
        for var s = stuff.count - 1; s>=0; s-- {
            var a = stuff[s]
            let alienWorldPosition = gamePhysicsNode.convertToWorldSpace(a.position)
            let alienScreenPosition = convertToNodeSpace(alienWorldPosition)
            if alienScreenPosition.y < 0 {
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
//        if heroScreenPosition.x < (-hero.boundingBox().width / 2) {
//            hero.position = ccp( self.boundingBox().width + hero.boundingBox().width / 2, hero.position.y)
//            hero.physicsBody.velocity.x -= 100
//            hero.physicsBody.velocity.y += 100
//            jump!.jumps++
//            if jump!.jumps >= 2{
//                hero.physicsBody.velocity.x += 350
//                hero.physicsBody.velocity.y -= 175
//            }
//
//        }
//        else if heroScreenPosition.x - hero.boundingBox().width / 2 > (self.boundingBox().width ) {
//            hero.position = ccp(-hero.boundingBox().width / 2, hero.position.y)
//            hero.physicsBody.velocity.x += 100
//            hero.physicsBody.velocity.y += 100
//            jump!.jumps++
//            if jump!.jumps >= 2{
//                hero.physicsBody.velocity.x -= 350
//                hero.physicsBody.velocity.y -= 175
//            }
//
//        }
        if heroScreenPosition.x - hero.boundingBox().width / 2 + 5 <= 0 {
            hero.physicsBody.velocity.x = 200
//            hero.physicsBody.velocity.y = 50
        }
        else if heroScreenPosition.x + hero.boundingBox().width / 2  - 5 >= self.boundingBox().width {
            hero.physicsBody.velocity.x = -200
//            hero.physicsBody.velocity.y = 50
        }
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
        var worldPos = gamePhysicsNode.convertToWorldSpace(monster.position)
        var screenPos = convertToNodeSpace(worldPos)
        if hero.position.y - hero.boundingBox().width / 2 == endPoint?.y {
            println("adfdsf")
        }
        if gameOver || hero.physicsBody.velocity.y > 0 {
            hero.physicsBody.velocity.y = 10
            return false
        }
        jump = Jump()
        jumpPos = screenPos
        hero.jumpUpAnimation()
        hero.physicsBody.angularVelocity = 1
        hero.physicsBody.velocity = ccp(xVel, yVel )
        startedJumping = true
        firstJump = true
        jumped = true
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, bird: CCNode!) -> Bool {
        if lightningTouched {
            return false
        }
        if let shieldPresent = shield {
            shield!.removeFromParent()
            shield = nil
            return false
        }
        triggerGameOver()
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, asteroid: CCNode!) -> Bool {
        if let shieldPresent = shield {
            shield!.removeFromParent()
            shield = nil
            asteroid.physicsBody.velocity.y = 500
            asteroid.physicsBody.velocity.x = 100
            return false
        }
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, alien: CCNode!) -> Bool {
        if lightningTouched {
            return false
        }
        if let shieldPresent = shield {
            shield!.removeFromParent()
            shield = nil
            return false
        }
        hero.physicsBody.velocity = ccp(0,-300)
        triggerGameOver()
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, laser: CCNode!) -> Bool {
        laser.removeFromParent()
        if lightningTouched {
            return false
        }
        if let shieldPresent = shield {
            shield!.removeFromParent()
            shield = nil
            return false
        }
        triggerGameOver()
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, ufo: CCNode!) -> Bool {
        if lightningTouched {
            return false
        }
        if let shieldPresent = shield {
            shield!.removeFromParent()
            shield = nil
            return false
        }
        hero.physicsBody.velocity = ccp(0,-300)
        triggerGameOver()
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, lightning: CCNode!) -> Bool {
        gamePhysicsNode.removeChild(lightning)
        lightningTouched = true
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, shield: CCNode!) -> Bool {
        gamePhysicsNode.removeChild(shield)
        if let shieldPresent = self.shield {
            return false
        }
        shieldTouched = true
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
        let defaults = NSUserDefaults.standardUserDefaults()
        var highscore = defaults.integerForKey("highscore")
        if self.score > highscore {
            defaults.setInteger(Int(self.score), forKey: "highscore")
        }
    }
    func restart() {
        var mainScene = CCBReader.load("Gameplay") as! Gameplay
        var scene = CCScene()
        scene.addChild(mainScene)
        
        var transition = CCTransition(fadeWithDuration: 0.2)
        
        CCDirector.sharedDirector().presentScene(scene, withTransition: transition)
        gameOver = false
    }
    func restartDuringPlay() {
        var mainScene = CCBReader.load("Gameplay") as! Gameplay
        var scene = CCScene()
        scene.addChild(mainScene)
        
        var transition = CCTransition(fadeWithDuration: 0.3)
        
        CCDirector.sharedDirector().presentScene(scene, withTransition: transition)
    }
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if !firstJump {
//            if touch.locationInWorld().x < CGFloat(50) || touch.locationInWorld().x > CGFloat(250) || touch.locationInWorld().y < CGFloat(60) || touch.locationInWorld().y > CGFloat(200) || touch.locationInWorld().y > hero.position.y {
            if touch.locationInWorld().y < 50 {
                cantDraw = true
                return
            }
            
        }
        if (gameOver == false) {
            startPoint = ccpAdd(touch.locationInWorld(), ccp(0, addToY))
        }
    }

    override func touchMoved(touch: CCTouch!, withEvent event: CCTouchEvent!) {
      touchMoved = true
    }
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if cantDraw {
            cantDraw = false
            return
        }
        var constant: Float = 25
        yVel = -1000
        if(touchMoved){
            endPoint = ccpAdd(touch.locationInWorld(), ccp(0, addToY))
//            if !firstJump && (endPoint!.x > 300 || endPoint!.x < 20 || endPoint!.y > hero.position.y)  {
//                return
//            }
            var distanceOne = hypotf(Float(startPoint!.x - endPoint!.x), Float(startPoint!.y - endPoint!.y))
            var distanceTwo : Float = Float(abs(startPoint!.x - endPoint!.x))
            var product  = (distanceTwo) / distanceOne
            var radian: Float = acos(product)
            var angle: Float = radian * 180 / Float(M_PI)
            println(angle)
//            constant += angle * 0.25
//            if constant > 30 {
//                yVel = yVel + CGFloat(pow((constant - 25), 2.9))
//            }
            yVel = yVel + CGFloat(angle * 2.5)
            if endPoint!.y > startPoint!.y && endPoint!.x > startPoint!.x {
                xVel = CGFloat(angle * constant)
            }
            else if endPoint!.y < startPoint!.y && endPoint!.x < startPoint!.x {
                xVel = CGFloat(angle * constant)
            }
            else if endPoint!.y < startPoint!.y && endPoint!.x > startPoint!.x {
                xVel = CGFloat(-angle * constant)

            }
            else if endPoint!.y > startPoint!.y && endPoint!.x < startPoint!.x {
                xVel = CGFloat(-angle * constant)
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
    }
    
}