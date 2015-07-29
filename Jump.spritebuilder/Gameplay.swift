//
//  Gameplay.swift
//  Jump
//
//  Created by Boris Yue on 7/2/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//
//Thisisacomment

import UIKit
import GameKit

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
//        gamePhysicsNode.debugDraw = true
        backgrounds.append(sky1)
        backgrounds.append(sky2)
        gemNum.string = "\(gemTrack)"
        if Gameplay.lineScale == 0 {
            Gameplay.lineScale = 0.9
        }
        if Gameplay.lightningSpeed == 0 {
            Gameplay.lightningSpeed = 175
        }
        if Gameplay.purpleTime == 0 {
            Gameplay.purpleTime = 1100
        }
        if Gameplay.shieldHit == 0 {
            Gameplay.shieldHit = 1
        }
        if Gameplay.startSpawn == 0.34 {
            Gameplay.canSpawn = 0.34
        }
        if Gameplay.spawnPower == 0.0 {
            Gameplay.spawnPower = 0.05
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "spawnGems", userInfo: nil, repeats: true)
    }
    func spawnGems() {
        if hero.positionInPoints.y > CGFloat(randThresh) + 800 {
            var rand = CCRANDOM_0_1()
            if rand < Gameplay.spawnPower {
                var powerup = CCBReader.load("Gem") as! Powerup
                gamePhysicsNode.addChild(powerup)
                stuff.append(powerup)
                powerup.position = ccp(CGFloat(200), hero.positionInPoints.y + CGFloat(500))
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
        purpleTrack++
        if purpleTrack > Gameplay.purpleTime {
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
            particles()
            powerupTrack++
            contentNode.position = ccpAdd(contentNode.position, ccp(0, -30))
            addToY += 30
            score += 16
            hero.physicsBody.velocity.y = 1820
            hero.physicsBody.velocity.x = 0
            if powerupTrack > Gameplay.lightningSpeed {
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
        if hero.positionInPoints.y > 9000 {
            birdProb = 0
            alienProb += 0.4
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
//        if hero.position.y > CGFloat(randThresh) + 800 {
        var powerup: Powerup
        var randX = CCRANDOM_0_1() * 270 + 20
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
//            else {
//                powerup = CCBReader.load("Gem") as! Powerup
//            }
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
        var randX = CCRANDOM_0_1() * 260 + 20
        var jumpNum = CCRANDOM_0_1()
        if jumpNum < spawnProb {
            var rand = CCRANDOM_0_1()
            if rand < asteroidProb {
                enemy = CCBReader.load("Asteroid") as! Enemy
                enemy.position = ccp(CGFloat(randX), hero.positionInPoints.y + CGFloat(1000))
                gamePhysicsNode.addChild(enemy)
                stuff.append(enemy)
            }
            else if rand > asteroidProb  &&  rand < birdProb {
                enemy = CCBReader.load("Bird") as! Enemy
                enemy.position = ccp(CGFloat(randX), hero.positionInPoints.y + CGFloat(450))
                gamePhysicsNode.addChild(enemy)
                stuff.append(enemy)
                
            }
            else if rand > birdProb  &&  rand < alienProb {
                enemy = CCBReader.load("MonsterAlien") as! Enemy
                enemy.position = ccp(CGFloat(randX), hero.positionInPoints.y + CGFloat(450))
                gamePhysicsNode.addChild(enemy)
                stuff.append(enemy)
            }
            else if rand > alienProb && rand < ufoProb {
                var randUfoX = CCRANDOM_0_1() * 180 + 30
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
            ufoProb += 0.07//.07
            spawnProb += 0.01
            if spawnProb > 0.8 {
                spawnProb = 0.8
            }
            if asteroidProb > 0.35 {
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
                if skyScreenPosition.y <= (-sky.boundingBox().height) {
                    sky.position = ccp(sky.position.x, sky.position.y + sky.boundingBox().height * 2 )
                    skyOff++
                }
            }
//            if skyOff == 11 {
//                println(-sky.boundingBox().height)
//                if skyScreenPosition.y <= (-sky.boundingBox().height / 2) {
//                    var space = CCBReader.load("Space") as CCNode
//                    var space2 = CCBReader.load("Space") as CCNode
//                    space.position = ccp(0, sky.position.y + sky.boundingBox().height)
//                    space2.position = ccp(0, space.position.y + space.boundingBox().height)
//                    contentNode.addChild(space, z: -1)
//                    contentNode.addChild(space2, z: -1)
//                    backgrounds.append(space)
//                    backgrounds.append(space2)
//                    backgrounds.removeAtIndex(s)
//                    skyOff++
//
//                }
//            }
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
                hero.physicsBody.velocity.x = 200
            }
            else if heroScreenPosition.x + hero.boundingBox().width / 2  - 5 >= self.boundingBox().width {
                hero.physicsBody.velocity.x = -200
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
//        if hero.position.y - hero.boundingBox().width / 2 == endPoint?.y {
//            println("adfdsf")
//        }
        drawline.setJump(true)
        if gameOver {
            return false
        }
        if hero.physicsBody.velocity.y > 0 {
            return true
        }
        jump = Jump()
        jumpPos = screenPos
        if !Settings.pressed {
            hero.jumpUpWithSound()
        } else { hero.jumpUpAnimation() }
        hero.physicsBody.angularVelocity = 1
        hero.physicsBody.velocity = ccp(xVel, yVel )
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
            shield!.removeFromParent()
            shield = nil
            asteroid.physicsBody.velocity.y = 500
            asteroid.physicsBody.velocity.x = 100
            return false
        }
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, alien: CCNode!) -> ObjCBool {
        if lightningTouched || gameOver {
            return false
        }
        if let shieldPresent = shield {
            shield!.removeFromParent()
            shield = nil
            return false
        }
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
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, laser: CCNode!) -> ObjCBool {
        laser.removeFromParent()
        if lightningTouched || gameOver {
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
        if lightningTouched || gameOver {
            return false
        }
        if let shieldPresent = shield {
            shield!.removeFromParent()
            shield = nil
            return false
        }
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
        gameOver = true
        pausedOnce = true
        if !Settings.pressed {
            OALSimpleAudio.sharedInstance().playEffect("sounds/falling.wav")
        }
        var gameOverScreen = CCBReader.load("GameOver", owner: self) as! GameOver
        self.addChild(gameOverScreen)
        gameOverScreen.score = self.score
        if Gameplay.boundary {
            let defaults = NSUserDefaults.standardUserDefaults()
            var highscore = defaults.integerForKey("highscoreeasy")
            if self.score > highscore {
                defaults.setInteger(Int(self.score), forKey: "highscoreeasy")
                GameCenterInteractor.sharedInstance.reportHighScoreToGameCenterEasy(self.score)
            }
        }
        else {
            let defaults = NSUserDefaults.standardUserDefaults()
            var highscore = defaults.integerForKey("highscorehard")
            if self.score > highscore {
                defaults.setInteger(Int(self.score), forKey: "highscorehard")
                GameCenterInteractor.sharedInstance.reportHighScoreToGameCenterHard(self.score)
            }
        }
    }
    func restart() {
        OALSimpleAudio.sharedInstance().stopAllEffects()
        var mainScene = CCBReader.load("Gameplay") as! Gameplay
        var scene = CCScene()
        scene.addChild(mainScene)
        
        var transition = CCTransition(fadeWithDuration: 0.2)
        
        CCDirector.sharedDirector().presentScene(scene, withTransition: transition)
        gameOver = false
        Space.canSpawn = 0
    }
    func main (){
        var main = CCBReader.loadAsScene("MainScene")
        var transition = CCTransition(fadeWithDuration: 0.2)
        CCDirector.sharedDirector().presentScene(main, withTransition: transition)
        Space.canSpawn = 0
    }
    func leader() {
        showLeaderboard()
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


