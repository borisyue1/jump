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
    var firstPoint: CGPoint?
    var startPoint: CGPoint?
    var endPoint: CGPoint?
    var linesList : [Line] = []
    var touchMoved : Bool = false
    var backgrounds = [CCNode]()
    var stuff = [CCNode]()
    var addToY : CGFloat = 0
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
    var purpleTouched = false
    var purpleTrack = 0
    var powerupTrack = 0
    var shield: ShieldCircle?
    var canSpawn : Float = 0.22
    var alreadySpawned = false
    var skyOff = 0
    static var boundary = false
    var crashed = false
    var pause: CCNode!
    var pausedOnce = false
    
    func didLoadFromCCB(){
        gamePhysicsNode.collisionDelegate = self
        userInteractionEnabled = true
//        gamePhysicsNode.debugDraw = true
        backgrounds.append(sky1)
        backgrounds.append(sky2)
        var timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("checkAliensandObstaclesOffScreen"), userInfo: nil, repeats: true)

    }

    override func update(delta: CCTime) {
        if gameOver {
            return
        }
        purpleTrack++
        if purpleTrack > 1050 {
            purpleTrack = 0
            purpleTouched = false
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
            if startedJumping {
                var constant: CGFloat = 0.009
                if jumpPos!.y < 150 {
                    constant = 0.005
                }
                var scrollRate = jumpPos!.y * constant + 6.5
                contentNode.position = ccpAdd(contentNode.position, ccp(0, -scrollRate))
                addToY += scrollRate
                score += 16
                if hero.positionInPoints.y > CGFloat(randThresh) && hero.physicsBody.velocity.y < 500 && hero.physicsBody.velocity.y > 480 && alreadySpawned {
                    spawnRandomStuff()
                    if hero.positionInPoints.y > CGFloat(randThresh) + 1200 {
                        spawnPowerUps()
                    }
                    alreadySpawned = false
                }

            }
        }
        else {
            powerupTrack++
            contentNode.position = ccpAdd(contentNode.position, ccp(0, -30))
            addToY += 30
            score += 20
            hero.physicsBody.velocity.y = 1830
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
            shieldPresent.position = hero.positionInPoints
        }
        checkWallsOffScreen()

        
    }

    func spawnPowerUps(){
//        if hero.position.y > CGFloat(randThresh) + 800 {
        var powerup
        var randX = CCRANDOM_0_1() * 270 + 20
        var rand = CCRANDOM_0_1()
        if rand < canSpawn {
            var prob = CCRANDOM_0_1()
            if prob < 0.35 {
                var lightning = CCBReader.load("Lightning") as! Lightning
                gamePhysicsNode.addChild(lightning)
                lightning.position = ccp(CGFloat(randX), hero.positionInPoints.y + CGFloat(450))
            }
            else if prob < 0.85 {
                var shield = CCBReader.load("Shield") as! Shield
                gamePhysicsNode.addChild(shield)
                shield.position = ccp(CGFloat(randX), hero.positionInPoints.y + CGFloat(450))
            }
            else {
                var shield = CCBReader.load("Shield") as! Shield
                gamePhysicsNode.addChild(shield)
                shield.position = ccp(CGFloat(randX), hero.positionInPoints.y + CGFloat(450))
            }
            canSpawn -= 0.08
            if canSpawn <= 0.08 {
                canSpawn = 0.08
            }
        }
        //}
    }
    func spawnRandomStuff(){
        var randX = CCRANDOM_0_1() * 260 + 20
        var jumpNum = CCRANDOM_0_1()
        if jumpNum < 0.6 {
            var rand = CCRANDOM_0_1()
            if rand < asteroidProb {
                var asteroid = CCBReader.load("Asteroid") as! Asteroid
                gamePhysicsNode.addChild(asteroid)
                stuff.append(asteroid)
                asteroid.position = ccp(CGFloat(randX), hero.positionInPoints.y + CGFloat(1000))
            }
            else if rand > asteroidProb  &&  rand < birdProb {
                var bird = CCBReader.load("Bird") as! Bird
                gamePhysicsNode.addChild(bird)
                stuff.append(bird)
                bird.position = ccp(CGFloat(randX), hero.positionInPoints.y + CGFloat(450))
                
            }
            else if rand > birdProb  &&  rand < alienProb {
                var alien = CCBReader.load("MonsterAlien") as! MonsterAlien
                gamePhysicsNode.addChild(alien)
                stuff.append(alien)
                alien.position = ccp(CGFloat(randX), hero.positionInPoints.y + CGFloat(450))
            }
            else if rand > alienProb  &&  rand < ufoProb {
                var randUfoX = CCRANDOM_0_1() * 180 + 30
                var ufo = CCBReader.load("UfoAlien") as! UfoAlien
                gamePhysicsNode.addChild(ufo)
                stuff.append(ufo)
                ufo.position = ccp(CGFloat(randUfoX), hero.positionInPoints.y + CGFloat(470))
            }
            asteroidProb += 0.04
            birdProb -= 0.1//0.1
            alienProb += 0.2//.2
            ufoProb += 0.08//.08
            if asteroidProb > 0.4 {
                asteroidProb = 0.4
            }
            if alienProb > 0.75 {
                alienProb = 0.75
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
            if skyOff != 10 {
                if skyScreenPosition.y <= (-sky.boundingBox().height) {
                    sky.position = ccp(sky.position.x, sky.position.y + sky.boundingBox().height * 2 )
                    skyOff++
                }
            }
        }
        if skyOff == 10 {
            var darker = CCBReader.load("SkyDarker") as CCNode
            contentNode.addChild(darker, z: -1)
            darker.position = ccp(0, self.contentSizeInPoints.height * 14)
            skyOff++
            backgrounds.removeAll(keepCapacity: true)
            var space = CCBReader.load("Space") as CCNode
            var space2 = CCBReader.load("Space") as CCNode
            space.position = ccp(0, darker.position.y + darker.boundingBox().height)
            space2.position = ccp(0, space.position.y + space.boundingBox().height)
            contentNode.addChild(space, z: -1)
            contentNode.addChild(space2, z: -1)
            backgrounds.append(space)
            backgrounds.append(space2)
        }
    }
    func checkTimeForLines() {
        for var s = linesList.count - 1; s>=0; --s {
            if linesList[s].didJump() {
                linesList[s].increaseTime(1)
                if linesList[s].getTime() > 15 || crashed {
                    gamePhysicsNode.removeChild(linesList[s])
                    linesList.removeAtIndex(s)
                }
            }
        }
    }
    func checkOffScreen() {
        var heroWorldPosition = gamePhysicsNode.convertToWorldSpace(hero.positionInPoints)
        var heroScreenPosition = convertToNodeSpace(heroWorldPosition)
        if !Gameplay.boundary {
            if heroScreenPosition.x < (-hero.boundingBox().width / 2) {
                hero.positionInPoints = ccp( self.boundingBox().width + hero.boundingBox().width / 2, hero.positionInPoints.y)
                hero.physicsBody.velocity.x -= 100
                hero.physicsBody.velocity.y += 100
                jump!.jumps++
                if jump!.jumps >= 2{
                    hero.physicsBody.velocity.x += 350
                    hero.physicsBody.velocity.y -= 175
                }

            }
            else if heroScreenPosition.x - hero.boundingBox().width / 2 > (self.boundingBox().width ) {
                hero.positionInPoints = ccp(-hero.boundingBox().width / 2, hero.positionInPoints.y)
                hero.physicsBody.velocity.x += 100
                hero.physicsBody.velocity.y += 100
                jump!.jumps++
                if jump!.jumps >= 2{
                    hero.physicsBody.velocity.x -= 350
                    hero.physicsBody.velocity.y -= 175
                }

            }
        }
        else {
            if heroScreenPosition.x - hero.boundingBox().width / 2 + 5 <= 0 {
                hero.physicsBody.velocity.x = 200
            }
            else if heroScreenPosition.x + hero.boundingBox().width / 2  - 5 >= self.boundingBox().width {
                hero.physicsBody.velocity.x = -200
            }
        }
        if heroScreenPosition.y < 5 {
            crashed = true
            triggerGameOver()
        }
    }
    func shake() {
        let move = CCActionEaseBounceOut(action: CCActionMoveBy(duration: 0.05, position: ccp(20, 0)))
        let moveBack = CCActionEaseBounceOut(action: move.reverse())
        let shakeSequence = CCActionSequence(array: [move, moveBack])
        runAction(shakeSequence)
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, ground: CCPhysicsNode!) -> ObjCBool {
        if gameOver {
            return false
        }
        hero.jumpUpAnimation()
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, drawline: Line!) -> ObjCBool {
        var worldPos = gamePhysicsNode.convertToWorldSpace(monster.positionInPoints)
        var screenPos = convertToNodeSpace(worldPos)
//        if hero.position.y - hero.boundingBox().width / 2 == endPoint?.y {
//            println("adfdsf")
//        }
        drawline.setJump(true)
        if hero.physicsBody.velocity.y >= 0{
            return true
        }
        jump = Jump()
//        jumpPos = hero.position
        jumpPos = screenPos
        hero.jumpUpAnimation()
        hero.physicsBody.angularVelocity = 1
        hero.physicsBody.velocity = ccp(xVel, yVel )
        startedJumping = true
        firstJump = true
        alreadySpawned = true
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, bird: CCNode!) -> ObjCBool {
        if lightningTouched {
            return false
        }
        if let shieldPresent = shield {
            shield!.removeFromParent()
            shield = nil
            return false
        }
        crashed = true
        shake()
        hero.physicsBody.velocity.y = -750
        hero.physicsBody.angularVelocity = 10
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, asteroid: CCNode!) -> ObjCBool {
        if let shieldPresent = shield {
            shield!.removeFromParent()
            shield = nil
            asteroid.physicsBody.velocity.y = 500
            asteroid.physicsBody.velocity.x = 100
            return false
        }
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, alien: CCNode!) -> ObjCBool {
        if lightningTouched {
            return false
        }
        if let shieldPresent = shield {
            shield!.removeFromParent()
            shield = nil
            return false
        }
        crashed = true
        shake()
        hero.physicsBody.velocity.y = -750
        hero.physicsBody.angularVelocity = 10
        triggerGameOver()
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, laser: CCNode!) -> ObjCBool {
        laser.removeFromParent()
        if lightningTouched {
            return false
        }
        if let shieldPresent = shield {
            shield!.removeFromParent()
            shield = nil
            return false
        }
        crashed = true
        shake()
        hero.physicsBody.velocity.y = -750
        hero.physicsBody.angularVelocity = 10
        triggerGameOver()
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, ufo: CCNode!) -> ObjCBool {
        if lightningTouched {
            return false
        }
        if let shieldPresent = shield {
            shield!.removeFromParent()
            shield = nil
            return false
        }
        crashed = true
        shake()
        hero.physicsBody.velocity.y = -750
        hero.physicsBody.angularVelocity = 10
        triggerGameOver()
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, lightning: CCNode!) -> ObjCBool {
        gamePhysicsNode.removeChild(lightning)
        lightningTouched = true
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, shield: CCNode!) -> ObjCBool {
        gamePhysicsNode.removeChild(shield)
        if let shieldPresent = self.shield {
            return false
        }
        shieldTouched = true
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, purple: CCNode!) -> ObjCBool {
        gamePhysicsNode.removeChild(purple)
        purpleTouched = true
        return true
    }
    func pausey() {
        if pausedOnce {
            return
        }
        self.paused = true
        pause = CCBReader.load("Pause", owner: self) as CCNode
        self.addChild(pause)
        pausedOnce = true
    }
    func resume(){
        self.paused = false
        self.removeChild(pause)
        pausedOnce = false
    }

    func quit(){
        let main = CCBReader.loadAsScene("MainScene")
        var transition = CCTransition(fadeWithDuration: 0.2)
        CCDirector.sharedDirector().presentScene(main, withTransition: transition)
    }
    func triggerGameOver() {
        gameOver = true
        pausedOnce = true
        var gameOverScreen = CCBReader.load("GameOver", owner: self) as! GameOver
        self.addChild(gameOverScreen)
        gameOverScreen.score = self.score
        if Gameplay.boundary {
            let defaults = NSUserDefaults.standardUserDefaults()
            var highscore = defaults.integerForKey("highscoreeasy")
            if self.score > highscore {
                defaults.setInteger(Int(self.score), forKey: "highscoreeasy")
            }
        }
        else {
            let defaults = NSUserDefaults.standardUserDefaults()
            var highscore = defaults.integerForKey("highscorehard")
            if self.score > highscore {
                defaults.setInteger(Int(self.score), forKey: "highscorehard")
            }
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
    func main (){
        var main = CCBReader.loadAsScene("MainScene")
        var transition = CCTransition(fadeWithDuration: 0.2)
        CCDirector.sharedDirector().presentScene(main, withTransition: transition)

    }
    
    func restartDuringPlay() {
        var mainScene = CCBReader.load("Gameplay") as! Gameplay
        var scene = CCScene()
        scene.addChild(mainScene)
        
        var transition = CCTransition(fadeWithDuration: 0.3)
        
        CCDirector.sharedDirector().presentScene(scene, withTransition: transition)
    }
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if crashed {
            return
        }
        if (gameOver == false) {
            startPoint = ccpAdd(touch.locationInWorld(), ccp(0, addToY))
        }
    }

    override func touchMoved(touch: CCTouch!, withEvent event: CCTouchEvent!) {
      touchMoved = true
     
        
    }
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if crashed {
            return
        }
        var constant: Float = 25
        yVel = -1000
        if(touchMoved){
            endPoint = ccpAdd(touch.locationInWorld(), ccp(0, addToY))
            var distanceOne = hypotf(Float(startPoint!.x - endPoint!.x), Float(startPoint!.y - endPoint!.y))
            var distanceTwo : Float = Float(abs(startPoint!.x - endPoint!.x))
            var product  = (distanceTwo) / distanceOne
            var radian: Float = acos(product)
            var angle: Float = radian * 180 / Float(M_PI)
//            println(angle)
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
            if(startPoint!.y < endPoint!.y && startPoint!.x < endPoint!.x){
                angle = 360 - radian * 180 / Float(M_PI)
            }
            if(startPoint!.y < endPoint!.y && startPoint!.x > endPoint!.x){
                angle = 180 + radian * 180 / Float(M_PI)
            }
            if(startPoint!.y > endPoint!.y && startPoint!.x > endPoint!.x){
                angle = 180 -  radian * 180 / Float(M_PI)
            }

            var scaleFact = distanceOne / Float(151)
            var line: Line
            if !purpleTouched {
                line = CCBReader.load("Line") as! Line
                if scaleFact > 0.9 {
                    line.scaleX = 0.9
                } else{  line.scaleX = scaleFact }
            }
            else {
                line = CCBReader.load("PurpleLine") as! Line
                if scaleFact > 1.3 {
                    line.scaleX = 1.3
                } else{  line.scaleX = scaleFact }
            }
            line.rotation = angle
            line.position = ccp(startPoint!.x, startPoint!.y)
            gamePhysicsNode.addChild(line)
            linesList.append(line)
            touchMoved = false
        }
    }
    
}