import Foundation

class MainScene: CCNode {
 
    func play() {
        
        //the code below loads the scene play
        let gameplay = CCBReader.loadAsScene("Gameplay")
        CCDirector.sharedDirector().presentScene(gameplay)
    }
}
