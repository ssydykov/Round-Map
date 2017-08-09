//
//  MainMenu.swift
//  Math Tetris
//
//  Created by Saken Sydykov on 07.07.17.
//  Copyright © 2017 Strixit. All rights reserved.
//

import SpriteKit
import GameplayKit

class MainMenu: SKScene {
    
    // UI variable
    var playButton: MSButtonNode!
    
    override func didMove(to view: SKView) {
        
        trackScreenView()
        
        // Set UI connection
        playButton = self.childNode(withName: "playButton") as! MSButtonNode
        
        // Set play button on click
        playButton.selectedHandler = {
            
            print("playbutton pressed")
            self.loadScene("Levels")
        } 
    }
    
    func trackScreenView() {
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Main Menu")
        tracker?.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject]?)
    }
    
    func loadScene(_ sceneName: String){
        
        print("Load scene")
        
        // 1) Grab reference to out Sprite Kit view
        guard let skView = self.view as SKView! else {
            
            print ("Couldn't get SKVeiw")
            return
        }
        
        // Load game scene
        guard let scene = MainMenu(fileNamed: sceneName) else {
            
            print("Could not make GameScene, check the name is spelled correctly")
            return
        }
        
        // 3) Ensure correct aspect mode
        scene.scaleMode = .aspectFill
        
        // Show debug
//        skView.showsPhysics = true
//        skView.showsDrawCount = true
        
        // 4) Start Game scene
        skView.presentScene(scene)
        
    }
}
