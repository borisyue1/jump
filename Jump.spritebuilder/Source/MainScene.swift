import Foundation

class MainScene: CCNode {

    weak var hero: Hero!
    weak var physics: CCPhysicsNode!
    var touchMoved : Bool = false
    var startPoint: CGPoint?
    var linesList = [Line]()
    var xVel: CGFloat = 0
    var tracker = 0
    var pressed = false

    func didLoadFromCCB() {
        physics.collisionDelegate = self
        userInteractionEnabled = true
    }
    override func update(delta: CCTime) {
        tracker++
        if linesList.count > 0 {
            checkTimeForLines()
        }
        if hero.physicsBody.velocity.y < 0 {
            hero.down()
        }
        if tracker > 30 {
            checkOffScreen()
        }
    }
    func checkOffScreen() {
        if hero.positionInPoints.x - hero.boundingBox().width / 2 + 5 <= 0 {
            hero.physicsBody.velocity.x = 200
        }
        else if hero.positionInPoints.x + hero.boundingBox().width / 2  - 5 >= self.contentSizeInPoints.width {
            hero.physicsBody.velocity.x = -200
        }
        else if hero.positionInPoints.y + hero.boundingBox().width / 2 >= self.contentSizeInPoints.height {
            hero.physicsBody.velocity.y = -200

        }
    }
    func play() {
        if !pressed {
            let mode = CCBReader.load("Mode") as! Mode
            self.addChild(mode)
        }
        pressed = true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, ground: CCPhysicsNode!) -> ObjCBool {
        hero.jumpUpAnimation()
        return true
    }
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
  
        startPoint = touch.locationInWorld()
    }
    override func touchMoved(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        touchMoved = true
        
        
    }
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        var constant: Float = 25
        if(touchMoved){
            var endPoint = touch.locationInWorld()
            var distanceOne = hypotf(Float(startPoint!.x - endPoint.x), Float(startPoint!.y - endPoint.y))
            var distanceTwo : Float = Float(abs(startPoint!.x - endPoint.x))
            var product  = (distanceTwo) / distanceOne
            var radian: Float = acos(product)
            var angle: Float = radian * 180 / Float(M_PI)
            if endPoint.y > startPoint!.y && endPoint.x > startPoint!.x {
                xVel = CGFloat(angle * constant)
            }
            else if endPoint.y < startPoint!.y && endPoint.x < startPoint!.x {
                xVel = CGFloat(angle * constant)
            }
            else if endPoint.y < startPoint!.y && endPoint.x > startPoint!.x {
                xVel = CGFloat(-angle * constant)
                
            }
            else if endPoint.y > startPoint!.y && endPoint.x < startPoint!.x {
                xVel = CGFloat(-angle * constant)
            }
            if(startPoint!.y < endPoint.y && startPoint!.x < endPoint.x){
                angle = 360 - radian * 180 / Float(M_PI)
            }
            else if(startPoint!.y < endPoint.y && startPoint!.x > endPoint.x){
                angle = 180 + radian * 180 / Float(M_PI)
            }
            else if(startPoint!.y > endPoint.y && startPoint!.x > endPoint.x){
                angle = 180 -  radian * 180 / Float(M_PI)
            }
            
            var scaleFact = distanceOne / Float(151)
            var line = CCBReader.load("Line") as! Line
            if scaleFact > 0.9 {
                line.scaleX = 0.9
            } else{  line.scaleX = scaleFact }
            line.rotation = angle
            line.position = ccp(startPoint!.x, startPoint!.y)
            physics.addChild(line)
            linesList.append(line)
            touchMoved = false
        }
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, drawline: Line!) -> ObjCBool {
        drawline.setJump(true)
        if hero.physicsBody.velocity.y >= 0{
            return true
        }
        hero.jumpUpAnimation()
        hero.physicsBody.angularVelocity = 1
        hero.physicsBody.velocity = ccp(xVel, -1000 )
        return true
    }
    func checkTimeForLines() {
        for var s = linesList.count - 1; s>=0; --s {
            linesList[s].increaseTime(1)
            if linesList[s].getTime() > 40 {
                physics.removeChild(linesList[s])
                linesList.removeAtIndex(s)
            }
        }
    }
}
