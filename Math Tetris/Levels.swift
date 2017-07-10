//
//  Levels.swift
//  Math Tetris
//
//  Created by Saken Sydykov on 07.07.17.
//  Copyright © 2017 Strixit. All rights reserved.
//

import SpriteKit
import GameplayKit

class Levels: SKScene {
    
    // UI variable
    var rightButton: MSButtonNode!
    var leftButton: MSButtonNode!
    var cameraNode: SKCameraNode!
    
    // Variables
    var levels: Array<Level> = []
    let numberOfLevels = 11
    
    override func didMove(to view: SKView) {
        
        // Initialize variables
        rightButton = self.childNode(withName: "//rightButton") as! MSButtonNode
        leftButton = self.childNode(withName: "//leftButton") as! MSButtonNode
        cameraNode = self.childNode(withName: "camera") as! SKCameraNode
        self.camera = cameraNode
        
        
        // Right arrow button is clicked
        rightButton.selectedHandler = {
            
            print("Right arrow clicked")
            self.cameraNode.position.x += 568
        }
        
        // Left arrow button is clicked
        leftButton.selectedHandler = {
            
            print("Left arrow clicked")
            self.cameraNode.position.x -= 568
        }
        
        
        // If there are stored data with levels
        if let data = UserDefaults.standard.object(forKey: "levels") as? Data {
            if let storedData = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Level] {
                
                levels = storedData
                
                print(storedData[0].status)
            }
        }
        
        // If game was opened first time
        else {
        
            // Set first level is opened by default
            let level1 = Level(0, "Level 1", true, 0, "")
            levels.append(level1)
        
            for item in 1...numberOfLevels {
                
                // Set other levels as closed
                levels.append(Level(item, "Level \(item + 1)", false, 0, "0"))
            }
            
            // Save levels in data
            let levelsData = NSKeyedArchiver.archivedData(withRootObject: levels)
            UserDefaults.standard.set(levelsData, forKey: "levels")
            UserDefaults.standard.synchronize()
            
            print("Levels are saved")
        }
        
        // Show list of levels
        showList()
    }
    
    func showList(){
        
        for item in 0...numberOfLevels {
            
            let listItem = self.childNode(withName: "//Level \(item)") as! SKShapeNode
            
            // Print level label and their status
            print("Label: \(levels[item].label), status: \(levels[item].status)")
            
            let status = levels[item].status
            let time = levels[item].time
            
            if status {
                
                if time != "" {
                    
                    listItem.strokeColor = UIColor.green
                }
                else {
                    
                    listItem.strokeColor = UIColor.orange
                }
            }
            else {
                
                listItem.strokeColor = UIColor.red
            }
        }
    }
    
    // Calls when touch begins
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        
//        let touch = touches.first!
//        let location = touch.location(in: self)
//        let nodeAtPoint = atPoint(location)
//        
//        onTouch = true
//        
//        // Touch control logic
//        
//        if nodeAtPoint.name == "leftButton" {
//            
//            map.removeAllActions()
//            let action = SKAction.rotate(byAngle: CGFloat(Double.pi * 20), duration: 60.0)
//            map.run(action)
//            
//        }
//    }
}
