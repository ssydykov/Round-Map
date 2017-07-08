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
    
    // Variables
    var levels: Array<Level> = []
    
    override func didMove(to view: SKView) {
        
        let level1 = Level(1, "Level 1", true, 0, "0")
        levels.append(level1)
        
        let levelsData = NSKeyedArchiver.archivedData(withRootObject: levels)
        UserDefaults.standard.set(levelsData, forKey: "levels")
        
        UserDefaults.standard.synchronize()
        
        print("Level is in store")
        
        if let data = UserDefaults.standard.object(forKey: "levels") as? Data {
            if let storedData = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Level] {
                // In here you can access your array
                
                print("Levels \(storedData[0].label)") 
            }
        }
    }
}
