import Foundation

class MainScene: CCNode {

    func play() {
        let mode = CCBReader.load("Mode") as! Mode
        self.addChild(mode)
    }

    
}
