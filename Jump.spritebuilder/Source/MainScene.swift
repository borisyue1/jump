import Foundation
import SpriteKit

class MainScene: CCNode {

    weak var scoreLabel : CCLabelTTF!
    weak var gamePhysicsNode : CCPhysicsNode!
    weak var hero : Hero!
    var gameOver = false
    var startedJumping = false
    var firstPoint: CGPoint?
//    var lineNode = SKShapeNode()
    var scaleFact : Double = 0
    var line : Line?
    
    func didLoadFromCCB(){
        gamePhysicsNode.collisionDelegate = self
        userInteractionEnabled = true
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
//        hero.physicsBody.velocity = ccp(0,500)
//        var scaleUp = CCActionScaleTo(duration: 0.5, scale: 0.25)
//        hero.runAction(scaleUp)
        hero.physicsBody.applyImpulse(ccp(0,300))
        hero.jumpUpAnimation()
        return true
    }
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if (gameOver == false) {
            line = CCBReader.load("Line") as? Line
            var worldPoint : CGPoint = touch.locationInWorld()
            line!.position = worldPoint
            gamePhysicsNode.addChild(line)
//            line.draw()
//            line!.scaleX = Float(scaleFact)
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
        var newPos : CGPoint = touch.locationInWorld()
        scaleFact += 0.1
        line!.scaleX = Float(scaleFact)
    }
    
}
