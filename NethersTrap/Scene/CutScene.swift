import SpriteKit
import GameplayKit

class CutScene: SKScene {
    
    let slideshowImages = ["Scene1", "Scene2", "Scene3", "Scene4", "Scene5"]
        var currentImageIndex = 0
        
        override func didMove(to view: SKView) {
            showNextSlide()
        }
        
    func showNextSlide() {
        guard currentImageIndex < slideshowImages.count else {
            changeToNextScene()
            return
        }
        removeAllChildren()
        let imageName = slideshowImages[currentImageIndex]
        let slide = SKSpriteNode(imageNamed: imageName)
        slide.size = CGSize(width: 314.1, height: 212.4)
        slide.alpha = 0
        slide.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(slide)
        let animation = SKAction.fadeIn(withDuration: 0.5)
        currentImageIndex += 1
        let delay = SKAction.wait(forDuration: 2.0)
        let showNextSlideAction = SKAction.run(showNextSlide)
        let sequence = SKAction.sequence([animation, delay, showNextSlideAction])
        slide.run(sequence)
    }

        
        func changeToNextScene() {
            let newScene = MenuScene(fileNamed: "MenuScene")
//                let newScene = MenuScene(size: (view?.bounds.size)!)
            newScene!.scaleMode = self.scaleMode
            let transition = SKTransition.fade(withDuration: 2)
            self.view?.presentScene(newScene!, transition: transition)
        }
}
