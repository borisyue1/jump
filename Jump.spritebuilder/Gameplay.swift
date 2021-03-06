//
//  Gameplay.swift
//  Jump
//
//  Created by Boris Yue on 7/2/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//
//Thisisacomment
//another comment

import UIKit
import GameKit
import Mixpanel

class Gameplay: CCNode {
    
    weak var scoreLabel : CCLabelTTF!
    var score : Int = 0 {
        didSet{
            scoreLabel.string = "\(score)"
        }
    }
    weak var gemNum: CCLabelTTF!
    var gemTrack: Int = NSUserDefaults.standardUserDefaults().integerForKey("gems") ?? 0 {
        didSet {
            NSUserDefaults.standardUserDefaults().setInteger(gemTrack, forKey:"gems")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    weak var newLabel: CCLabelTTF!
    weak var gamePhysicsNode : CCPhysicsNode!
    weak var hero : Hero!
    weak var drawLine: CCPhysicsNode!
    weak var contentNode : CCNode!
    weak var sky1 : CCNode!
    weak var sky2 : CCNode!
    weak var tutorial: CCNode!
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
    var spawnProb: Float = 0.6
    var randThresh = CCRANDOM_0_1() * 300 + 1200
    var jumpPos : CGPoint?
    let constant = 0.006
    var jump: Jump?
    var lightningTouched = false
    var shieldTouched = false
    var purpleTouched = false
    var purpleTrack = 0
    var powerupTrack = 0
    var shield: CCNode?
    var alreadySpawned = false
    var skyOff = 0
    var crashed = false
    var pause: CCNode!
    var pausedOnce = false
    static var boundary = false
    static var lineScale: Float = NSUserDefaults.standardUserDefaults().floatForKey("scale") ?? 0.9 {
        didSet{
            NSUserDefaults.standardUserDefaults().setFloat(lineScale, forKey:"scale")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    static var lightningSpeed: Int =  NSUserDefaults.standardUserDefaults().integerForKey("lightningspeed") ?? 175 {
        didSet{
            NSUserDefaults.standardUserDefaults().setInteger(lightningSpeed, forKey:"lightningspeed")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    static var purpleTime: Int = NSUserDefaults.standardUserDefaults().integerForKey("purpletime") ?? 1100 {
        didSet{
            NSUserDefaults.standardUserDefaults().setInteger(purpleTime, forKey:"purpletime")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    static var shieldHit: Int = NSUserDefaults.standardUserDefaults().integerForKey("shieldhit") ?? 1 {
        didSet{
            NSUserDefaults.standardUserDefaults().setInteger(shieldHit, forKey:"shieldhit")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    var hits = 0
    static var canSpawn: Float = 0.22
    static var startSpawn: Float = NSUserDefaults.standardUserDefaults().floatForKey("star") ?? 0.22 {
        didSet{
            NSUserDefaults.standardUserDefaults().setFloat(startSpawn, forKey:"star")
            NSUserDefaults.standardUserDefaults().synchronize()
            Gameplay.canSpawn = Gameplay.startSpawn
        }
    }
    static var spawnPower: Float = NSUserDefaults.standardUserDefaults().floatForKey("spawnpower") ?? 0.05 {
        didSet{
            NSUserDefaults.standardUserDefaults().setFloat(spawnPower, forKey:"spawnpower")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    var timer: NSTimer!
  
    
    func didLoadFromCCB(){
//        gemTrack+=500
        gamePhysicsNode.collisionDelegate = self
        userInteractionEnabled = true
        backgrounds.append(sky1)
        backgrounds.append(sky2)
        gemNum.string = "\(gemTrack)"
        if MKStoreKit.sharedKit().isProductPurchased("com.yueboris.bounceyblob.longerlines") {
            Gameplay.lineScale = 1.1//0.9, 1.1
        }
        if MKStoreKit.sharedKit().isProductPurchased("com.yueboris.bounceyblob.longerlightningpowerup") {
            Gameplay.lightningSpeed = 245//175,245
        }
        if MKStoreKit.sharedKit().isProductPurchased("com.yueboris.bounceyblob.longerpotionpowerup") {
            Gameplay.purpleTime = 1050//700, 1050
        }
        if MKStoreKit.sharedKit().isProductPurchased("com.yueboris.bounceyblob.longershieldpowerup") {
            Gameplay.shieldHit = 2//1,2
        }
        if MKStoreKit.sharedKit().isProductPurchased("com.yueboris.bounceyblob.morepowerups") {
            Gameplay.startSpawn = 0.32//0.22,0.32
        }
        if MKStoreKit.sharedKit().isProductPurchased("com.yueboris.bounceyblob.moregems") {
            Gameplay.spawnPower = 0.1//0.05,0.1
        }
        if Gameplay.lineScale == 0 {
            Gameplay.lineScale = 0.9
        }
        if Gameplay.lightningSpeed == 0 {
            Gameplay.lightningSpeed = 175
        }
        if Gameplay.purpleTime == 0 {
            Gameplay.purpleTime = 700
        }
        if Gameplay.shieldHit == 0 {
            Gameplay.shieldHit = 1
        }
        if Gameplay.startSpawn == 0 {
            Gameplay.canSpawn = 0.22
        }
        if Gameplay.startSpawn == 0.32 {
            Gameplay.canSpawn = 0.32
        }
        if Gameplay.spawnPower == 0.0 {
            Gameplay.spawnPower = 0.05
        }
//        println(Gameplay.lineScale)
//        println(Gameplay.lightningSpeed)
//        println(Gameplay.purpleTime)
//        println(Gameplay.shieldHit)
//        println(Gameplay.canSpawn)
//        println(Gameplay.startSpawn)
//        println(Gameplay.spawnPower)
//        NSUserDefaults.standardUserDefaults().setObject(64048, forKey: "highscoreeasy")
//        NSUserDefaults.standardUserDefaults().setObject(79888, forKey: "highscorehard")
        timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "spawnGems", userInfo: nil, repeats: true)
    }
    func spawnGems() {
        if hero.positionInPoints.y > CGFloat(randThresh) + 800 {
            var rand = CCRANDOM_0_1()
            if rand < Gameplay.spawnPower {
                var randX = CCRANDOM_0_1() * Float(self.boundingBox().width - 20) + 10
                var powerup = CCBReader.load("Gem") as! Powerup
                gamePhysicsNode.addChild(powerup)
                stuff.append(powerup)
                powerup.position = ccp(CGFloat(randX), hero.positionInPoints.y + CGFloat(500))
            }
        }
    }
    func getGems() -> Int {
        return gemTrack
    }
    func subGems(s: Int) {
        gemTrack-=s
        
    }
    override func update(delta: CCTime) {
        if gameOver {
            return
        }
        gemNum.string = "\(gemTrack)"
        if purpleTouched{
            purpleTrack++
            if purpleTrack > Gameplay.purpleTime {
                purpleTrack = 0
                purpleTouched = false
            }
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
                var heroWorldPosition = gamePhysicsNode.convertToWorldSpace(hero.positionInPoints)
                var heroScreenPosition = convertToNodeSpace(heroWorldPosition)
                var constant: CGFloat = 0.006
                if jumpPos!.y < 160 {
                    constant = 0.003
                }
                if jumpPos!.y > 215 {
                    constant = 0.011
                }
//               println(jumpPos!.y)
                if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                    constant = 0.006
                    if jumpPos!.y < 160 {
                        constant = 0.004
                    }
                    if jumpPos!.y > 230 {
                        constant = 0.01
                    }
                }
                var scrollRate = heroScreenPosition.y * constant + 6.5
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
            particles()
            powerupTrack++
            contentNode.position = ccpAdd(contentNode.position, ccp(0, -30))
            addToY += 30
            score += 16
            hero.physicsBody.velocity.y = 1820//20
            hero.physicsBody.velocity.x = 0
            if powerupTrack > Gameplay.lightningSpeed {
                lightningTouched = false
                powerupTrack = 0
                hero.physicsBody.velocity.y = 100
            }
        }
        if shieldTouched {
            shield = CCBReader.load("ShieldCircle") as CCNode
            contentNode.addChild(shield)
            shieldTouched = false
        }
        if let shieldPresent = shield {
            shieldPresent.position = hero.positionInPoints
        }
        if hero.positionInPoints.y > 9500 {
            birdProb = 0
        
        }
        checkWallsOffScreen()
        checkAliensandObstaclesOffScreen()
        
    }
    func particles() {
        let boost = CCBReader.load("Boost") as! CCParticleSystem
        boost.autoRemoveOnFinish = true;
        boost.position = ccp(hero.positionInPoints.x, CGFloat(hero.positionInPoints.y - hero.boundingBox().height / 2 - 20));
        contentNode.addChild(boost)
    }
    func spawnPowerUps(){
        var powerup: Powerup
        var randX = CCRANDOM_0_1() * Float(self.boundingBox().width - 50) + 20
        var rand = CCRANDOM_0_1()
        if rand < Gameplay.canSpawn {
            var prob = CCRANDOM_0_1()
            if prob < 0.30 {//.32
                powerup = CCBReader.load("Lightning") as! Powerup
            }
            else if prob < 0.8  {//.75
                powerup = CCBReader.load("Shield") as! Powerup
            }
            else {//.9,spawnpower
                powerup = CCBReader.load("Purple") as! Powerup
            }
            gamePhysicsNode.addChild(powerup)
            stuff.append(powerup)
            powerup.position = ccp(CGFloat(randX), hero.positionInPoints.y + CGFloat(450))
            Gameplay.canSpawn -= 0.02
            if Gameplay.canSpawn <= Gameplay.startSpawn - 0.14 {
                Gameplay.canSpawn = Gameplay.startSpawn - 0.14
            }
        }

    }
    func spawnRandomStuff(){
        var enemy: Enemy
        var randX = CCRANDOM_0_1() * Float(self.boundingBox().width - 60) + 20
        var jumpNum = CCRANDOM_0_1()
        if jumpNum < spawnProb {
            var rand = CCRANDOM_0_1()
            if rand < asteroidProb {
                enemy = CCBReader.load("Asteroid") as! Enemy
                enemy.position = ccp(CGFloat(randX), hero.positionInPoints.y + CGFloat(800))
                gamePhysicsNode.addChild(enemy)
                stuff.append(enemy)
            }
            else if rand > asteroidProb  &&  rand < birdProb {
                enemy = CCBReader.load("Bird") as! Enemy
                enemy.position = ccp(CGFloat(randX), hero.positionInPoints.y + 450)
                gamePhysicsNode.addChild(enemy)
                stuff.append(enemy)
                
            }
            else if rand > birdProb  &&  rand < alienProb {
                enemy = CCBReader.load("MonsterAlien") as! Enemy
                enemy.position = ccp(CGFloat(randX), hero.positionInPoints.y + 450)
                gamePhysicsNode.addChild(enemy)
                stuff.append(enemy)
            }
            else if rand > alienProb && rand < ufoProb {
                var randUfoX = CCRANDOM_0_1() * Float(self.boundingBox().width - 140) + 30
                enemy = CCBReader.load("UfoAlien") as! Enemy
                if Settings.pressed {
                    enemy.fireWithoutSound()
                }
                enemy.position = ccp(CGFloat(randUfoX), hero.positionInPoints.y + CGFloat(470))
                gamePhysicsNode.addChild(enemy)
                stuff.append(enemy)
            }
            asteroidProb += 0.04
            birdProb -= 0.1//0.1
            alienProb += 0.15//.2
            ufoProb += 0.075//.08
            spawnProb += 0.01
            if spawnProb > 0.8 {
                spawnProb = 0.8
            }
            if asteroidProb > 0.32 {
                asteroidProb = 0.35
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
            if alienScreenPosition.y < -10 {
                stuff.removeAtIndex(s)
                a.removeFromParent()
            }
        }
    }

    func checkWallsOffScreen(){
        for var s = backgrounds.count - 1; s>=0; --s {
            var sky = backgrounds[s]
            let skyWorldPosition = gamePhysicsNode.convertToWorldSpace(sky.position)
            let skyScreenPosition = convertToNodeSpace(skyWorldPosition)
            if skyOff != 10 {
                if skyScreenPosition.y <= (-sky.boundingBox().height / 2) {
                    sky.position = ccp(sky.position.x, sky.position.y + sky.boundingBox().height * 2 )
                    skyOff++
                }
            }
        }
        if skyOff == 10 {
            Mixpanel.sharedInstance().track("Gameplay", properties: ["How high" : "Sky Darker Spawned"]);
            var darker = CCBReader.load("SkyDarker") as CCNode
            contentNode.addChild(darker, z: -1)
            darker.position = ccp(0, backgrounds.last!.position.y + backgrounds.last!.boundingBox().height / 2)
            skyOff++
            backgrounds.removeAll(keepCapacity: true)
            var space = CCBReader.load("Space") as CCNode
            var space2 = CCBReader.load("Space") as CCNode
            space.position = ccp(self.boundingBox().width / 2, darker.position.y + darker.boundingBox().height + space.boundingBox().height / 2)
            space2.position = ccp(self.boundingBox().width / 2, space.position.y + space.boundingBox().height)
            contentNode.addChild(space, z: -1)
            contentNode.addChild(space2, z: -1)
            backgrounds.append(space)
            backgrounds.append(space2)
        }
    }
    func checkTimeForLines() {
        for var s = linesList.count - 1; s>=0; --s {
            linesList[s].increaseTimeNoJump(1)
            if linesList[s].didJump() {
                linesList[s].increaseTime(1)
                if linesList[s].getTime() > 15 || crashed {
                    gamePhysicsNode.removeChild(linesList[s])
                    linesList.removeAtIndex(s)
                }
            }
            else if linesList[s].getTimeNoJump() > 100 || crashed {
                gamePhysicsNode.removeChild(linesList[s])
                linesList.removeAtIndex(s)
            }
        }
    }
    func checkOffScreen() {
        var heroWorldPosition = gamePhysicsNode.convertToWorldSpace(hero.positionInPoints)
        var heroScreenPosition = convertToNodeSpace(heroWorldPosition)
        if !Gameplay.boundary {
//            if heroScreenPosition.x < (-hero.boundingBox().width / 2) {
            if heroScreenPosition.x < -7 {
//                hero.positionInPoints = ccp( self.boundingBox().width + hero.boundingBox().width / 2, hero.positionInPoints.y)
                hero.positionInPoints = ccp( self.boundingBox().width + 7, hero.positionInPoints.y)
                if firstJump {
                    hero.physicsBody.velocity.x -= 100
                    hero.physicsBody.velocity.y += 100
                    jump!.jumps++
                    if jump!.jumps >= 2{
                        hero.physicsBody.velocity.x += 325
                        hero.physicsBody.velocity.y -= 175
                    }
                }

            }
//            else if heroScreenPosition.x - hero.boundingBox().width / 2 > (self.boundingBox().width ) {
            else if heroScreenPosition.x > self.boundingBox().width + 7 {
//                hero.positionInPoints = ccp(-hero.boundingBox().width / 2, hero.positionInPoints.y)
                hero.positionInPoints = ccp(-7, hero.positionInPoints.y)
                if firstJump {
                    hero.physicsBody.velocity.x += 100
                    hero.physicsBody.velocity.y += 100
                    jump!.jumps++
                    if jump!.jumps >= 2{
                        hero.physicsBody.velocity.x -= 325
                        hero.physicsBody.velocity.y -= 175
                    }
                }

            }
        }
        else {
            if heroScreenPosition.x - hero.boundingBox().width / 2 + 5 <= 0 {
                hero.physicsBody.velocity.x = 150
            }
            else if heroScreenPosition.x + hero.boundingBox().width / 2  - 5 >= self.boundingBox().width {
                hero.physicsBody.velocity.x = -150
            }
        }
        if heroScreenPosition.y < 0 {
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
        if !Settings.pressed {
            hero.jumpUpWithSound()
        } else { hero.jumpUpAnimation() }
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, drawline: Line!) -> ObjCBool {
        var worldPos = gamePhysicsNode.convertToWorldSpace(monster.positionInPoints)
        var screenPos = convertToNodeSpace(worldPos)
        drawline.setJump(true)
        if gameOver {
            return false
        }
        if hero.physicsBody.velocity.y > 0 {
            hero.physicsBody.velocity = ccp(xVel, -700 )
            return true
        }
        jump = Jump()
        jumpPos = screenPos
        if !Settings.pressed {
            hero.jumpUpWithSound()
        } else { hero.jumpUpAnimation() }
        hero.physicsBody.angularVelocity = 1
        hero.physicsBody.velocity = ccp(xVel, yVel )
//        println(hero.physicsBody.velocity)
        startedJumping = true
        firstJump = true
        alreadySpawned = true
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, bird: CCNode!) -> ObjCBool {
        if lightningTouched || gameOver {
            return false
        }
        if let shieldPresent = shield {
            hits++
            if hits >= Gameplay.shieldHit {
                shield!.removeFromParent()
                shield = nil
                hits = 0
            }
            return false
        }
        Mixpanel.sharedInstance().track("Collision", properties: ["Collision type": "Bird"])
        if !Settings.pressed {
            OALSimpleAudio.sharedInstance().playEffect("sounds/crash.wav")
        }
        crashed = true
        shake()
        hero.physicsBody.velocity.y = -750
        hero.physicsBody.angularVelocity = 10
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, asteroid: CCNode!) -> ObjCBool {
        if let shieldPresent = shield {
            hits++
            asteroid.physicsBody.velocity.y = 500
            asteroid.physicsBody.velocity.x = 100
            if hits >= Gameplay.shieldHit {
                shield!.removeFromParent()
                shield = nil
                hits = 0
            }
            return false
        }
        Mixpanel.sharedInstance().track("Collision", properties: ["Collision type": "Asteroid"])
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, alien: CCNode!) -> ObjCBool {
        if lightningTouched || gameOver {
            return false
        }
        if let shieldPresent = shield {
            hits++
            if hits >= Gameplay.shieldHit {
                shield!.removeFromParent()
                shield = nil
                hits = 0
            }
            return false
        }
        if !Settings.pressed {
            OALSimpleAudio.sharedInstance().playEffect("sounds/crash.wav")
        }
        Mixpanel.sharedInstance().track("Collision", properties: ["Collision type": "Alien"])
        crashed = true
        shake()
        hero.physicsBody.velocity.y = -750
        hero.physicsBody.angularVelocity = 10
        triggerGameOver()
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, laser: CCNode!) -> ObjCBool {
        laser.removeFromParent()
        if lightningTouched || gameOver {
            return false
        }
        if let shieldPresent = shield {
            hits++
            if hits >= Gameplay.shieldHit {
                shield!.removeFromParent()
                shield = nil
                hits = 0
            }
            return false
        }
        Mixpanel.sharedInstance().track("Collision", properties: ["Collision type": "Laser"])
        crashed = true
        shake()
        hero.physicsBody.velocity.y = -750
        hero.physicsBody.angularVelocity = 10
        triggerGameOver()
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, ufo: CCNode!) -> ObjCBool {
        if lightningTouched || gameOver {
            return false
        }
        if let shieldPresent = shield {
            hits++
            if hits >= Gameplay.shieldHit {
                shield!.removeFromParent()
                shield = nil
                hits = 0
            }
            return false
        }
        Mixpanel.sharedInstance().track("Collision", properties: ["Collision type": "UFO"])
        if !Settings.pressed {
            OALSimpleAudio.sharedInstance().playEffect("sounds/crash.wav")
        }
        crashed = true
        shake()
        hero.physicsBody.velocity.y = -750
        hero.physicsBody.angularVelocity = 10
        triggerGameOver()
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, lightning: CCNode!) -> ObjCBool {
        stuff.filter({$0 != lightning})
        gamePhysicsNode.removeChild(lightning)
        if !Settings.pressed {
            OALSimpleAudio.sharedInstance().playEffect("sounds/launch.wav")
        }
        lightningTouched = true
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, shield: CCNode!) -> ObjCBool {
        stuff.filter({$0 != shield})
        gamePhysicsNode.removeChild(shield)
        if let shieldPresent = self.shield {
            return false
        }
        shieldTouched = true
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, purple: CCNode!) -> ObjCBool {
        stuff.filter({$0 != purple})
        gamePhysicsNode.removeChild(purple)
        purpleTouched = true
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, gem: CCNode!) -> ObjCBool {
        stuff.filter({$0 != gem})
        gem.removeFromParent()
        gemTrack++
        return true
    }
    func pausey() {
        if pausedOnce {
            return
        }
        self.paused = true
        timer.invalidate()
        pause = CCBReader.load("Pause", owner: self) as CCNode
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            pause.contentSize = CGSize(width: 384, height: 512)
        }
        self.addChild(pause)
        pausedOnce = true
    }
    func resume(){
        self.paused = false
        self.removeChild(pause)
        pausedOnce = false
        timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "spawnGems", userInfo: nil, repeats: true)
    }

    func quit(){
        let main = CCBReader.loadAsScene("MainScene")
        var transition = CCTransition(fadeWithDuration: 0.2)
        CCDirector.sharedDirector().presentScene(main, withTransition: transition)
    }
    func triggerGameOver() {
        Mixpanel.sharedInstance().track("Game Over", properties: ["Score": self.score])
        gameOver = true
        pausedOnce = true
        if !Settings.pressed {
            OALSimpleAudio.sharedInstance().playEffect("sounds/falling.wav")
        }
        var gameOverScreen = CCBReader.load("GameOver", owner: self) as! GameOver
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            gameOverScreen.contentSize = CGSize(width: 384, height: 512)
        }
        self.addChild(gameOverScreen)
        gameOverScreen.displayTip()
        gameOverScreen.score = self.score
        if Gameplay.boundary {
            let defaults = NSUserDefaults.standardUserDefaults()
            var highscore = defaults.integerForKey("highscoreeasy")
            if self.score > highscore {
                defaults.setInteger(Int(self.score), forKey: "highscoreeasy")
                GameCenterInteractor.sharedInstance.reportHighScoreToGameCenterEasy(self.score)
                newLabel.visible = true
            }
        }
        else {
            let defaults = NSUserDefaults.standardUserDefaults()
            var highscore = defaults.integerForKey("highscorehard")
            if self.score > highscore {
                defaults.setInteger(Int(self.score), forKey: "highscorehard")
                GameCenterInteractor.sharedInstance.reportHighScoreToGameCenterHard(self.score)
                newLabel.visible = true
            }
        }
    }

    func restart() {
        OALSimpleAudio.sharedInstance().stopAllEffects()
        var mainScene = CCBReader.loadAsScene("Gameplay")
        var transition = CCTransition(fadeWithDuration: 0.2)
        
        CCDirector.sharedDirector().presentScene(mainScene, withTransition: transition)
        gameOver = false
        newLabel.visible = false
    }
    func main (){
        var main = CCBReader.loadAsScene("MainScene")
        var transition = CCTransition(fadeWithDuration: 0.2)
        CCDirector.sharedDirector().presentScene(main, withTransition: transition)
        newLabel.visible = false
    }
    func leader() {
        showLeaderboard()
    }
    
    func restartDuringPlay() {
        Mixpanel.sharedInstance().track("Pause screen", properties: ["Restart clicked": "Restart"])
        self.removeFromParent()
        var mainScene = CCBReader.load("Gameplay") as! Gameplay
        var scene = CCScene()
        scene.addChild(mainScene)
        var transition = CCTransition(fadeWithDuration: 0.2)
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
            if let t = tutorial {
                tutorial.removeFromParent()
            }
            endPoint = ccpAdd(touch.locationInWorld(), ccp(0, addToY))
            var distanceOne = hypotf(Float(startPoint!.x - endPoint!.x), Float(startPoint!.y - endPoint!.y))
            var distanceTwo : Float = Float(abs(startPoint!.x - endPoint!.x))
            var product  = (distanceTwo) / distanceOne
            var radian: Float = acos(product)
            var angle: Float = radian * 180 / Float(M_PI)
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
            if xVel > 1000 {
                xVel = 1000
            }
            if xVel < -1000 {
                xVel = -1000
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
                if scaleFact > Gameplay.lineScale {
                    line.scaleX = Gameplay.lineScale
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
extension Gameplay: GKGameCenterControllerDelegate {
    func showLeaderboard() {
        var viewController = CCDirector.sharedDirector().parentViewController!
        var gameCenterViewController = GKGameCenterViewController()
        gameCenterViewController.gameCenterDelegate = self
        viewController.presentViewController(gameCenterViewController, animated: true, completion: nil)
    }
    
    // Delegate methods
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}


