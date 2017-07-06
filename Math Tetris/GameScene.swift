//
//  GameScene.swift
//  Math Tetris
//
//  Created by Saken Sydykov on 30.06.17.
//  Copyright © 2017 Strixit. All rights reserved.
//

import SpriteKit
import GameplayKit

// Global Variables
var currentLevel: Int = 1

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Nodes and Buttons
    var leftButton: SKSpriteNode!
    var rightButton: SKSpriteNode!
    var map: SKSpriteNode!
    var endDialog: SKSpriteNode!
    var circle: SKSpriteNode!
    var nextLevelButton: MSButtonNode!
    var scoreLabel: SKLabelNode!
    
    // Booleans
    var onTouch: Bool = false
    
    // Variables
    var score: Int = 0
    
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
        scoreLabel = childNode(withName: "//score") as! SKLabelNode
        
        // createCircle(160.0, 225.0)
        
        // Next level button clicked
        nextLevelButton.selectedHandler = {
            
            print("Start next level")
        
            currentLevel += 1
            guard let scene = GameScene.loadLevel(currentLevel ) else {

                print ("Level is missing?")
                return
            }
            
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
        if nodeA.name == "exit" || nodeB.name == "exit" {
            
            print("Exit is collide")

            // Show dialog
            endDialog.zPosition = 5
            
            // Remove all actions
            map.removeAllActions()

            // Remove circle
            circle.removeFromParent()
            
            return
            
        } else if nodeA.name == "obstacle" || nodeB.name == "obstacle" {
            
            print("Hits obstacle")
            
            guard let scene = GameScene.loadLevel(currentLevel) else {
                
                print ("Level is missing?")
                return
            }
            
            self.view?.presentScene(scene)
        } else if nodeA.name == "star" || nodeB.name == "star" {
            
            score += 1
            scoreLabel.text = ": \(score)"
            
            if nodeA.name == "star" {
                nodeA.removeFromParent()
            } else {
                nodeB.removeFromParent()
            }
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
