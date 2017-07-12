//
//  GameScene.swift
//  Math Tetris
//
//  Created by Saken Sydykov on 30.06.17.
//  Copyright © 2017 Strixit. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Nodes
    var leftButton: SKSpriteNode!
    var rightButton: SKSpriteNode!
    var map: SKSpriteNode!
    var endDialog: SKSpriteNode!
    var circle: SKSpriteNode!
    var key: SKSpriteNode?
    var keySprite: SKSpriteNode!
    var teleport1: SKSpriteNode?
    var teleport2: SKSpriteNode?
    var obstacle: SKSpriteNode?
    
    // Buttons
    var nextLevelButton: MSButtonNode!
    var menuButton: MSButtonNode!
    var restartButton: MSButtonNode!
    
    // UI Labels
    var scoreLabel: SKLabelNode!
    var exitLabel: SKLabelNode!
    var liveNumberLabel: SKLabelNode!
    var liveStatusLabel: SKLabelNode!
    
    // Booleans
    var onTouch: Bool = false
    var onTeleport: Bool = true
    var isInTimer: Bool = false
    
    // Variables
    var score: Int = 0
    var timer = Timer()
    
    override func didMove(to view: SKView) {
        
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self
        
        
        // Initiate variables
        
        circle = childNode(withName: "//circle") as! SKSpriteNode
        leftButton = childNode(withName: "leftButton") as! SKSpriteNode
        rightButton = childNode(withName: "rightButton") as! SKSpriteNode
        map = childNode(withName: "map") as! SKSpriteNode
        endDialog = childNode(withName: "//endDialog") as! SKSpriteNode
        endDialog.zPosition = -5
        nextLevelButton = childNode(withName: "//nextLevelButton") as! MSButtonNode
        menuButton = childNode(withName: "//menuButton") as! MSButtonNode
        scoreLabel = childNode(withName: "//score") as! SKLabelNode
        key = childNode(withName: "//key") as? SKSpriteNode
        keySprite = childNode(withName: "//keySprite") as! SKSpriteNode
        exitLabel = childNode(withName: "//exitLabel") as! SKLabelNode
        restartButton = childNode(withName: "//restartButton") as! MSButtonNode
        teleport1 = childNode(withName: "//teleport1") as? SKSpriteNode
        teleport2 = childNode(withName: "//teleport2") as? SKSpriteNode
        obstacle = childNode(withName: "//obstacle") as? SKSpriteNode
        liveNumberLabel = childNode(withName: "//liveNumber") as! SKLabelNode
        liveStatusLabel = childNode(withName: "//liveStatus") as! SKLabelNode
        
        // Get current lives
//        liveNumber = UserDefaults.standard.integer(forKey: "lives")
        
        // Set lives number label
        print("Live number is \(lives)")
        liveNumberLabel.text = String(lives)
        
        if (lives < 5){
            
            print("Live number is less 5")
            
        } else {
            
            // Set lives
            liveStatusLabel.text = "FULL"
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
            exitLabel.text = "Closed"
            exitLabel.fontSize = 13
        }
        
        // Next level button clicked
        nextLevelButton.selectedHandler = {
            
            print("Start next level")
        
            currentLevel += 1
            guard let scene = GameScene.loadLevel(currentLevel) else {

                print ("Level is missing?")
                return
            }
            
            view.presentScene(scene)
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
        
        // Menu button clicked
        menuButton.selectedHandler = {
            
            print("Menu button clicked")
            
            guard let scene = GameScene(fileNamed: "Menu") else {
                
                print("Level is missing?")
                return
            }
            
            scene.scaleMode = .aspectFill
            view.presentScene(scene)
        }
    }
    
    // Calls when touch begins
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        let touch = touches.first!
        let location = touch.location(in: self)
        let nodeAtPoint = atPoint(location)
        
        onTouch = true

        // Touch control logic
        
        if nodeAtPoint.name == "leftButton" {
            
            map.removeAllActions()
            let action = SKAction.rotate(byAngle: CGFloat(Double.pi * 20), duration: 60.0)
            map.run(action)
            
        } else if nodeAtPoint.name == "rightButton" {
            
            map.removeAllActions()
            let action = SKAction.rotate(byAngle: CGFloat(-Double.pi * 20), duration: 60.0)
            map.run(action)
        }
        
    }
    
    // Calls when touch ends
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        map.removeAllActions()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    
        
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
        
        // If circle collides with exit
        if ((nodeA.name == "exit" || nodeB.name == "exit") &&
            exitLabel.text != "Closed"){
            
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
            
            levels[currentLevel] = passLevel
            levels[currentLevel + 1] = nextLevel
            
            // Update level
            let levelsData = NSKeyedArchiver.archivedData(withRootObject: levels)
            UserDefaults.standard.set(levelsData, forKey: "levels")
            UserDefaults.standard.synchronize()
            
            print("Levels are updated")
            
            // Show dialog
            endDialog.zPosition = 5
            
            // Remove all actions
            map.removeAllActions()

            // Remove circle
            circle.removeFromParent()
            
            return
        }

        // If circle collides with obstale

        else if ((nodeA.name == "obstacle" || nodeB.name == "obstacle") && !obstacle!.isHidden) ||
            (nodeA.name == "end" || nodeB.name == "end"){
            
            print("Hits obstacle")
            
            // Live --
            lives -= 1
            
            // Set lives number
            UserDefaults.standard.set(lives, forKey: "lives")
            
            if lives > 0 {
                
                print("Start level \(currentLevel + 1) again")
                
                // Start level again
                guard let scene = GameScene.loadLevel(currentLevel) else {
                    
                    print ("Level is missing?")
                    return
                }
                self.view?.presentScene(scene)
                
            } else {
                
                print("Start levels scene")
                
                // Show levels scene
                self.loadScene("Levels")
            }
            
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
            
            keySprite.isHidden = false
            exitLabel.text = "Open"
            exitLabel.fontSize = 16
            
            if nodeA.name == "key" {
                nodeA.removeFromParent()
            } else {
                nodeB.removeFromParent()
            }
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
    
    // Some two objects stop colliding
    func didEnd(_ contact: SKPhysicsContact) {
        
        print("Something stop colliding")
        
        /* Get references to bodies involved in collision */
        let contactA = contact.bodyA
        let contactB = contact.bodyB
        
        /* Get references to the physics body parent nodes */
        let nodeA = contactA.node!
        let nodeB = contactB.node!
        
        // If circle stop colliding with teleports
        
        if nodeA.name == "teleport1" || nodeB.name == "teleport1" ||
            nodeA.name == "teleport2" || nodeB.name == "teleport2" {
            
            onTeleport = true
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
}
