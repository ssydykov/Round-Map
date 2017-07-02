//
//  GameScene.swift
//  Math Tetris
//
//  Created by Saken Sydykov on 30.06.17.
//  Copyright © 2017 Strixit. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var leftButton: SKSpriteNode!
    var rightButton: SKSpriteNode!
    var map: SKSpriteNode!
    
    var onTouch: Bool = false
    
    override func didMove(to view: SKView) {
        
        leftButton = childNode(withName: "leftButton") as! SKSpriteNode
        rightButton = childNode(withName: "rightButton") as! SKSpriteNode
        map = childNode(withName: "map") as! SKSpriteNode
        
        createCircle()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        let touch = touches.first!
        let location = touch.location(in: self)
        let nodeAtPoint = atPoint(location)
        
        onTouch = true

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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        map.removeAllActions()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    // Round map
    func roundMap(){
        
        while onTouch {
            
            map.zRotation =  CGFloat(4.0)
        }
    }
    
    // Create circle
    func createCircle(){
        
        // Create circle, radius, color and position
        
        let radius: CGFloat = 10
        let circle = SKShapeNode(circleOfRadius: radius)
        circle.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        circle.fillColor = SKColor.orange
        circle.strokeColor = SKColor.orange
        
        // Circle physics
        
        circle.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        circle.physicsBody?.categoryBitMask = 1
        circle.physicsBody?.friction = 0.6
        circle.physicsBody?.mass = 0.5
        
        self.addChild(circle)
    }
}
