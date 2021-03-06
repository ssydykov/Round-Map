//
//  GameScene.swift
//  Math Tetris
//
//  Created by Saken Sydykov on 30.06.17.
//  Copyright © 2017 Strixit. All rights reserved.
//

import SpriteKit
import GameplayKit
import Google

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Nodes
    var leftButton: SKSpriteNode!
    var rightButton: SKSpriteNode!
    var map: SKSpriteNode!
    var endDialog: SKSpriteNode!
    var pauseDialog: SKSpriteNode!
    var circle: SKSpriteNode!
    var key: SKSpriteNode?
    var keySprite: SKSpriteNode?
    var teleport1: SKSpriteNode?
    var teleport2: SKSpriteNode?
    var obstacle: SKSpriteNode?
    var shieldLine: SKSpriteNode?
    var shieldTimeline: SKSpriteNode?
    var needles: SKSpriteNode?
    var exit: SKSpriteNode!
    var tutorialDialog: SKSpriteNode?
    
    // Buttons
    var nextLevelButton: MSButtonNode!
    var menuButton: MSButtonNode!
    var restartButton: MSButtonNode!
    var exitButton: MSButtonNode!
    var restartButtonPause: MSButtonNode!
    var exitButtonPause: MSButtonNode!
    var pauseButton: MSButtonNode!
    var resumeButton: MSButtonNode!
    
    // UI Labels
    var scoreLabel: SKLabelNode!
    var liveNumberLabel: SKLabelNode!
    var liveStatusLabel: SKLabelNode!
    
    // Emitter
    let emitter = SKEmitterNode(fileNamed: "PlayerTrail.sks")!
    
    // Booleans
    var onTouch: Bool = false
    var onTeleport: Bool = true
    var isInTimer: Bool = false
    var isShield: Bool = false
    var isObstacleCollideEnd = true
    
    // Variables
    var score: Int = 0
    var timer = Timer()
    var shieldTimer = Timer()
    
    
    override func didMove(to view: SKView) {
        
        // Analytics
        trackScreenView()
        
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self
        
        // Game is on
        isGameOver = false
        
        // Initiate variables
        
        circle = childNode(withName: "//circle") as! SKSpriteNode
        leftButton = childNode(withName: "leftButton") as! SKSpriteNode
        rightButton = childNode(withName: "rightButton") as! SKSpriteNode
        map = childNode(withName: "map") as! SKSpriteNode
        endDialog = childNode(withName: "//endDialog") as! SKSpriteNode
        endDialog.zPosition = -5
        pauseDialog = childNode(withName: "//pauseDialog") as! SKSpriteNode
        pauseDialog.zPosition = -5
        nextLevelButton = childNode(withName: "//nextLevelButton") as! MSButtonNode
        restartButton = childNode(withName: "//restartButton") as! MSButtonNode
        exitButton = childNode(withName: "//exitButton") as! MSButtonNode
        restartButtonPause = childNode(withName: "//restartButtonPause") as! MSButtonNode
        exitButtonPause = childNode(withName: "//exitButtonPause") as! MSButtonNode
        pauseButton = childNode(withName: "//pauseButton") as! MSButtonNode
        scoreLabel = childNode(withName: "//score") as! SKLabelNode
        key = childNode(withName: "//key") as? SKSpriteNode
        keySprite = childNode(withName: "//keySprite") as? SKSpriteNode
        exit = childNode(withName: "//exit") as! SKSpriteNode
        teleport1 = childNode(withName: "//teleport1") as? SKSpriteNode
        teleport2 = childNode(withName: "//teleport2") as? SKSpriteNode
        obstacle = childNode(withName: "//obstacle") as? SKSpriteNode
        liveNumberLabel = childNode(withName: "//liveNumber") as! SKLabelNode
        resumeButton = childNode(withName: "//resumeButton") as! MSButtonNode
        shieldLine = childNode(withName: "//shieldLine") as? SKSpriteNode
        shieldTimeline = childNode(withName: "//shieldTimeline") as? SKSpriteNode
        needles = childNode(withName: "//needlesBody") as? SKSpriteNode
        emitter.targetNode = scene
        tutorialDialog = childNode(withName: "//tutorialDialog") as? SKSpriteNode
        
        // Is first time
        // Get stored levels
        if let data = UserDefaults.standard.object(forKey: "levels") as? Data {
            if let storedData = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Level] {
                
                if !storedData[1].status {
                    
                    tutorialDialog!.isHidden = false
                } 
            }
        }
        
        // Set lives number label
        if superUser {
            
            liveNumberLabel.text = "∞"
            
        } else {
            
            print("Live number is \(lives)")
            liveNumberLabel.text = String(lives)
        }
        
        // Call timer for flashing obstacle if it is in the scene
        if obstacle != nil {
            
            scheduledTimerWithTimeInterval()
        }
        
        // Check is it key in the scene
        if (key == nil){
            
            print("key node is not in the scene")
            
        } else {
            
            print("key node is in the scene")
            
            // Set exit label to closed
            exit.isHidden = true
        }
        
        // Next level button clicked
        nextLevelButton.selectedHandler = {
            
            print("Start next level")
        
            currentLevel += 1
            if currentLevel > numberOfLevels {
                
                self.loadScene("Levels")
                
            } else {
                
                guard let scene = GameScene.loadLevel(currentLevel) else {
                    
                    print ("Level is missing?")
                    return
                }
                view.presentScene(scene)
            }
        }
        
        // Restart button clicked
        restartButton.selectedHandler = {
            
            print ("Restart button clicked")
            
            guard let scene = GameScene.loadLevel(currentLevel) else {
                
                print ("Level is missing?")
                return
            }
            
            view.presentScene(scene)
        }
        restartButtonPause.selectedHandler = {
            
            print ("Restart button clicked")
            
            guard let scene = GameScene.loadLevel(currentLevel) else {
                
                print ("Level is missing?")
                return
            }
            
            view.presentScene(scene)
        }
        
        // Exit button clicked
        exitButton.selectedHandler = {
            
            print ("Exit button clicked")
            
            self.loadScene("Levels")
        }
        exitButtonPause.selectedHandler = {
            
            print ("Exit button clicked")
            print ("Lives = \(lives)")
            
            self.loadScene("Levels")
        }
        
        // Pause button clicked
        pauseButton.selectedHandler = {
            
            // Show pause menu
            self.pauseDialog.zPosition = 5
            
            // Hide pause button
            self.pauseButton.isHidden = true
            
            // Pause game
            self.isPaused = true
        }
        
        // Resume button clicked
        resumeButton.selectedHandler = {
            
            // Hide pause menu
            self.pauseDialog.zPosition = -5
            
            // Show pause button
            self.pauseButton.isHidden = false
            
            // Unpause game
            self.isPaused = false
        }
    }
    
    // Calls when touch begins
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        // Close tutorial
        if tutorialDialog != nil {
            
            tutorialDialog!.isHidden = true
        }
        
        let touch = touches.first!
        let location = touch.location(in: self)
        let nodeAtPoint = atPoint(location)
        
        onTouch = true

        // Touch control logic
        
        if nodeAtPoint.name == "leftButton" {
            
            map.removeAllActions()
            let action = SKAction.rotate(byAngle: CGFloat(Double.pi * 30), duration: 60.0)
            map.run(action)
            
        } else if nodeAtPoint.name == "rightButton" {
            
            map.removeAllActions()
            let action = SKAction.rotate(byAngle: CGFloat(-Double.pi * 30), duration: 60.0)
            map.run(action)
        }
    }
    
    // Calls when touch ends
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        map.removeAllActions()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    
        if (obstacle != nil && !obstacle!.isHidden && !isObstacleCollideEnd) {
            
            killPlayer()
        }
    }
    
    // Recursive function for hideUnhide method
    func scheduledTimerWithTimeInterval(){
    
        timer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(self.hideUnhideNode), userInfo: nil, repeats: true)
    }
    
    // Hide or unhide node
    func hideUnhideNode() {
        
        if obstacle!.isHidden {
            
            obstacle!.isHidden = false
        }
        else {
            
            obstacle!.isHidden = true
        }
    }
    
    // Some two objects colliding
    func didBegin(_ contact: SKPhysicsContact) {
        
        print("Something is colliding")
        
        /* Get references to bodies involved in collision */
        let contactA = contact.bodyA
        let contactB = contact.bodyB
        
        /* Get references to the physics body parent nodes */
        let nodeA = contactA.node!
        let nodeB = contactB.node!
        
        // If circle collides with hidden obstacle
        if nodeA.name == "obstacle" || nodeB.name == "obstacle" {
            
            isObstacleCollideEnd = false
        }
        
        // If circle collides with exit
        if ((nodeA.name == "exit" || nodeB.name == "exit") &&
            !exit.isHidden){
            
            print("Exit is collide")
            
            // Unlock next level and save current level result in data
            let passLevel = Level(currentLevel, "Level \(currentLevel + 1)", true, score, "1.00")
            let nextLevel = Level(currentLevel + 1, "Level \(currentLevel + 2)", true, 0, "")
            var levels: Array<Level> = []
            
            // Get stored levels
            if let data = UserDefaults.standard.object(forKey: "levels") as? Data {
                if let storedData = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Level] {
                    
                    print("Pass level = \(storedData[currentLevel])")
                    
                    levels = storedData
                }
            }
            
            if levels[currentLevel].stars <= score {
                
                levels[currentLevel] = passLevel
            }
            if currentLevel == 11 {
                
                gameCompleted = true
            }
            else if !levels[currentLevel + 1].status {
                
                levels[currentLevel + 1] = nextLevel
            }
            
            // Update level
            let levelsData = NSKeyedArchiver.archivedData(withRootObject: levels)
            UserDefaults.standard.set(levelsData, forKey: "levels")
            UserDefaults.standard.synchronize()
            
            print("Levels are updated")
            
            // Show dialog
            endDialog.zPosition = 5
            
            // Hide pause button
            pauseButton.isHidden = true
            
            let star0 = endDialog.childNode(withName: "star0") as! SKSpriteNode
            let star1 = endDialog.childNode(withName: "star1") as! SKSpriteNode
            let star2 = endDialog.childNode(withName: "star2") as! SKSpriteNode
            let star3 = endDialog.childNode(withName: "star3") as! SKSpriteNode
            
            switch score {
                
                case 0:
                    star0.isHidden = false
                case 1:
                    star1.isHidden = false
                case 2:
                    star2.isHidden = false
                case 3:
                    star3.isHidden = false
                default:
                    star0.isHidden = false
            }
            
            // Remove all actions
            map.removeAllActions()

            // Remove circle
            circle.removeFromParent()
            
            return
        }

        // If circle collides with obstale

        else if (((nodeA.name == "obstacle" || nodeB.name == "obstacle") && !obstacle!.isHidden) ||
                (nodeA.name == "staticObstacle" || nodeB.name == "staticObstacle") && !isShield) ||
            (nodeA.name == "end" || nodeB.name == "end") || (nodeA.name == "needles" || nodeB.name == "needles"){
            
            print("Hits obstacle")
            
            killPlayer()
        }
        
        // If circle collides with star
        
        else if nodeA.name == "star" || nodeB.name == "star" {
            
            score += 1
            scoreLabel.text = ": \(score)"
            
            if nodeA.name == "star" {
                nodeA.removeFromParent()
            } else {
                nodeB.removeFromParent()
            }
        }
            
        // If circle collides with key
            
        else if nodeA.name == "key" || nodeB.name == "key" {
            
            keySprite?.isHidden = false
            
            exit.alpha = 0.0
            exit.isHidden = false
            let fadeInAction = SKAction.fadeIn(withDuration: 2.0)
            exit.run(fadeInAction)
            
            if nodeA.name == "key" {
                nodeA.removeFromParent()
            } else {
                nodeB.removeFromParent()
            }
        }
            
        // If circle collides with key
            
        else if nodeA.name == "needlesButton" || nodeB.name == "needlesButton" {
            
            print("Needles button press")
            
            
            var needlesButtonBody: SKSpriteNode!
            if nodeA.name == "needlesButton" {
                
                needlesButtonBody = nodeA.parent as! SKSpriteNode
                
            } else {
                
                needlesButtonBody = nodeB.parent as! SKSpriteNode
            }
            
            let moveButton = SKAction.scaleX(to: 0.3, y: needlesButtonBody.yScale, duration: 0.5)
            needlesButtonBody.run(moveButton)
            
            let moveNeedles = SKAction.scaleY(to: 0.3, duration: 0.5)
            needles?.run(moveNeedles)
        }
            
        // If circle collides with shield
            
        else if nodeA.name == "shield" || nodeB.name == "shield" {
            
            // If is shield dont hit obstacles
            isShield = true
            
            // Add emitter (trail) to player
            circle.addChild(emitter)
            
            // Remove shield from the scene
            if nodeA.name == "shield" {
                nodeA.removeFromParent()
            } else {
                nodeB.removeFromParent()
            }
            
            // Add shield line
            shieldLine?.isHidden = false
            
            // Start shield timer
            shieldTimerInterval()
            
        }
        
        // If circle collides with teleports
        
        else if nodeA.name == "teleport1" || nodeB.name == "teleport1" {
            
            if (teleport2 != nil && onTeleport) {
                
                onTeleport = false
                
                print("circle position = \(circle.position), teleport1 position = \(teleport1!.position), teleport2 position = \(teleport2!.position)")
                
                let moveCircle = SKAction.move(to: teleport2!.position, duration: 0)
                circle.run(moveCircle)
            
            } else {
                
                print("Teleport is nil")
            
            }
        }
        
        else if nodeA.name == "teleport2" || nodeB.name == "teleport2" {
            
            if (teleport1 != nil && onTeleport) {
                
                onTeleport = false
                
                print("circle position = \(circle.position), teleport1 position = \(teleport1!.position), teleport2 position = \(teleport2!.position)")
                
                let moveCircle = SKAction.move(to: teleport1!.position, duration: 0)
                circle.run(moveCircle)
            
            } else {
                
                print("Teleport is nil")
            
            }
        }
    }
    
    // ShieldTimerCounter
    var shieldTimerCounter = 1
    var shieldLineSizeCounter: CGFloat = 0
    
    // Set interval function to shield timer
    func shieldTimerInterval(){
        
        shieldLineSizeCounter = (self.shieldTimeline?.size.width)! / 15
        
        shieldTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.shieldTimerTimelineFunction), userInfo: nil, repeats: true)
    }
    
    // Shield timer line function
    func shieldTimerTimelineFunction(){

        print("Shield timer: \(shieldTimerCounter)")
        


        self.shieldTimeline?.size.width -= shieldLineSizeCounter
        
        if shieldTimerCounter == 16 {
            
            print("Fire")
            
            self.shieldLine?.isHidden = true
            self.isShield = false
            
            // remove trail
            emitter.removeFromParent()
            
            shieldTimer.invalidate()
        }
        
        shieldTimerCounter += 1
    }
    
    // Some two objects stop colliding
    func didEnd(_ contact: SKPhysicsContact) {
        
        print("Something stop colliding")
        
        /* Get references to bodies involved in collision */
        let contactA = contact.bodyA
        let contactB = contact.bodyB
        
        /* Get references to the physics body parent nodes */
        let nodeA = contactA.node
        let nodeB = contactB.node
        
        // If circle stop colliding with teleports
        
        if nodeA?.name == "teleport1" || nodeB?.name == "teleport1" ||
            nodeA?.name == "teleport2" || nodeB?.name == "teleport2" {
            
            onTeleport = true
        }
        
        else if nodeA?.name == "obstacle" || nodeB?.name == "obstacle" {
            
            isObstacleCollideEnd = true
        }
    }
    
    // Kill player
    func killPlayer(){
    
        // Pause game
//        let pauseAction = SKAction.sequence([SKAction.wait(forDuration: 1.0), SKAction.pause()])
//        self.run(pauseAction)
//        sleep(1)

        // Live --
        lives -= 1
        
        // Set lives number
        UserDefaults.standard.set(lives, forKey: "lives")
        
        if (lives > 0 || superUser) {
            
            print("Start level \(currentLevel + 1) again")
            
            // Start level again
            guard let scene = GameScene.loadLevel(currentLevel) else {
                
                print ("Level is missing?")
                return
            }
            self.view?.presentScene(scene)
            
        } else {
            
            print("Start levels scene")
            
            isGameOver = true
            
            // Show levels scene
            self.loadScene("Levels")
        }
    }
    
    // Load level
    class func loadLevel(_ levelNumber: Int) -> GameScene? {
        
        guard let scene = GameScene(fileNamed: "Level_\(levelNumber)") else {
            
            return nil
        }
        
        scene.scaleMode = .aspectFill
        return scene
    }
    
    // Load any scene
    func loadScene(_ sceneName: String){
        
        print("Load scene")
        
        // Grab reference to out Sprite Kit view
        guard let skView = self.view as SKView! else {
            
            print ("Couldn't get SKVeiw")
            return
        }
        
        // Load game scene
        guard let scene = GameScene(fileNamed: sceneName) else {
            
            print("Could not make GameScene, check the name is spelled correctly")
            return
        }
        
        // Start game scene
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
        
    }
    
    // Round map
    func roundMap(){
        
        while onTouch {
            
            map.zRotation =  CGFloat(4.0)
        }
    }
    
    // Create circle
    func createCircle(_ x: CGFloat, _ y: CGFloat){
        
        // Create circle, radius, color and position
        
        let radius: CGFloat = 10
        let circle = SKShapeNode(circleOfRadius: radius)
        circle.position = CGPoint(x: x, y: y)
        circle.fillColor = SKColor.orange
        circle.strokeColor = SKColor.orange
        
        // Circle physics
        
        circle.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        circle.physicsBody?.categoryBitMask = 1
        circle.physicsBody?.friction = 0.1
        circle.physicsBody?.mass = 0.5
        
        self.addChild(circle)
    }
    
    func trackScreenView() {
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Level \(currentLevel)")
        tracker?.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject]?)
    }
}
