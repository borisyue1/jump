import Foundation
import SpriteKit

class MainScene: CCNode {

    weak var scoreLabel : CCLabelTTF!
    weak var gamePhysicsNode : CCPhysicsNode!
    weak var hero : Hero!
    var gameOver = false
    var startedJumping = false
    var firstPoint: CGPoint?
    var lineNode = SKShapeNode()
    
    func didLoadFromCCB(){
        gamePhysicsNode.collisionDelegate = self
        userInteractionEnabled = true
    }
    override func update(delta: CCTime){
        if(hero.physicsBody.velocity.y < 0){
            hero.down()
        }
      
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, ground: CCPhysicsNode!) -> Bool {

        hero.physicsBody.velocity = ccp(0,500)
        hero.jumpUpAnimation()
        return true
    }
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if (gameOver == false) {
            var worldPoint : CGPoint = touch.locationInWorld()
            firstPoint = touch.locationInNode(self)
        }
    }
    override func touchMoved(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        let path = CGPathCreateMutable()
        var newPos = touch.locationInNode(self)
        CGPathMoveToPoint(path, nil, firstPoint!.x , firstPoint!.y)
        CGPathAddLineToPoint(path, nil, newPos.x, newPos.y)
        lineNode.path = path
        lineNode.lineWidth = 20
        lineNode.strokeColor = UIColor.blackColor()
        firstPoint = newPos
    }
    
}
