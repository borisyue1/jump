import Foundation

class MainScene: CCNode {

    weak var hero: Hero!
    weak var physics: CCPhysicsNode!
    
    func didLoadFromCCB() {
        physics.collisionDelegate = self
    }
    
    func play() {
        let mode = CCBReader.load("Mode") as! Mode
        self.addChild(mode)
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, monster: CCSprite!, ground: CCPhysicsNode!) -> ObjCBool {
        hero.jumpUpAnimation()
        return true
    }
    override func update(delta: CCTime) {
        if hero.physicsBody.velocity.y < 0 {
            hero.down()
        }
    }
    
}
