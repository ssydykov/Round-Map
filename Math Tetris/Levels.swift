//
//  Levels.swift
//  Math Tetris
//
//  Created by Saken Sydykov on 07.07.17.
//  Copyright © 2017 Strixit. All rights reserved.
//

import SpriteKit

// Variables
var counter = 10 * 60
var currentLevel: Int = 0
var lives: Int = 10
var isTimer: Bool = false
var timerText: String = ""
let timer = TimerModel.sharedTimer

// Method for timer
func getTimer() -> String {

    counter -= 1

    let minutes: Int = counter / 60 as Int
    let seconds: Int = counter % 60 as Int

    if (seconds < 10) {

        print("Minutes: \(minutes), seconds: 0\(seconds)")
        timerText = "\(minutes):0\(seconds)"

    } else {

        print("Minutes: \(minutes), seconds: \(seconds)")
        timerText = "\(minutes):\(seconds)"
    }

    return timerText
}

class Levels: SKScene, ChartboostDelegate {
    
    // Buttons
    var rightButton: MSButtonNode!
    var leftButton: MSButtonNode!
    var addButton: MSButtonNode!
    var hiddenButton: MSButtonNode!
    
    // Nodes
    var cameraNode: SKCameraNode!
    var liveNumberLabel: SKLabelNode!
    var liveStatusLabel: SKLabelNode!
    
    // Variables
    var levels: Array<Level> = []
    let numberOfLevels = 11
    
    override func didMove(to view: SKView) {
        
        // Initialize variables
        rightButton = self.childNode(withName: "//rightButton") as! MSButtonNode
        leftButton = self.childNode(withName: "//leftButton") as! MSButtonNode
        cameraNode = self.childNode(withName: "camera") as! SKCameraNode
        self.camera = cameraNode
        liveStatusLabel = self.childNode(withName: "//liveStatus") as! SKLabelNode
        liveNumberLabel = self.childNode(withName: "//liveNumber") as! SKLabelNode
        addButton = self.childNode(withName: "//addButton") as! MSButtonNode
        hiddenButton = self.childNode(withName: "//hiddenButton") as! MSButtonNode
        
        // Reward video delegate
        Chartboost.setDelegate(self)
        
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
        
        // Add button is clicked
        addButton.selectedHandler = {
            
            print("Add button clicked")
        
            Chartboost.showRewardedVideo(CBLocationMainMenu)
        }
        
        // Hidden button is clicked
        hiddenButton.selectedHandler = {
            
            // Set lives number
            lives += 1
            UserDefaults.standard.set(lives, forKey: "lives")
            
            // Show lives number
            self.showLives()
        }
        
        // If there are stored data with levels
        if let data = UserDefaults.standard.object(forKey: "levels") as? Data {
            if let storedData = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Level] {
                
                levels = storedData
                
                // Get lives number
                lives = UserDefaults.standard.integer(forKey: "lives")
                
                print("Data came from storage")
            }
        }
        
        // If game was opened first time
        else {
        
            // Set first level is opened by default
            let level1 = Level(0, "Level 1", true, 0, "")
            levels.append(level1)
        
            for item in 1...numberOfLevels {
                
                // Set other levels as closed
                levels.append(Level(item, "Level \(item + 1)", false, 0, ""))
            }
            
            // Save levels in data
            let levelsData = NSKeyedArchiver.archivedData(withRootObject: levels)
            UserDefaults.standard.set(levelsData, forKey: "levels")
            UserDefaults.standard.synchronize()
            
            // Set lives number
            UserDefaults.standard.set(lives, forKey: "lives")
            
            print("Levels and lives are saved")
        }
        
        // Show list of levels
        showList()
        
        // Show lives 
        showLives()
    }
    
    func showList(){
        
        for item in 0...numberOfLevels {
            
            let listItem = self.childNode(withName: "//Level \(item)") as! SKShapeNode
            
            // Print level label and their status
            print("Label: \(levels[item].label), status: \(levels[item].status)")
            
            let status = levels[item].status
            let time = levels[item].time
            let lockItem = listItem.childNode(withName: "lock") as! SKSpriteNode
            
            // If level is open
            if status {
                
                // If level is not passed
                if time != "" {
                    
                    // Set level border color to green
                    listItem.strokeColor = UIColor.green
                }
                    
                // If level already passed
                else {
                    
                    // Set level border color to orange
                    listItem.strokeColor = UIColor.orange
                }
                
                // Set lock item vissible
                lockItem.isHidden = true
            }
                
            // If level is closed
            else {
                
                // Set level border color to red
                listItem.strokeColor = UIColor.red
                
                // Set lock item invissible
                lockItem.isHidden = false
            }
            
        }
    }
    
    // Show lives number
    func showLives(){
        
        // Set lives number label
        print("Live number is \(lives)")
        liveNumberLabel.text = String(lives)
        
        print("Show lives")
        
        if (lives < 10 && !isTimer){
            
            print("Timer is start, lives = \(lives)")
            
            // Set live status text to start:
            let minutes: Int = counter / 60 as Int
            let seconds: Int = counter % 60 as Int
            
            if (seconds < 10) {
                
                print("Minutes: \(minutes), seconds: 0\(seconds)")
                timerText = "\(minutes):0\(seconds)"
                
            } else {
                
                print("Minutes: \(minutes), seconds: \(seconds)")
                timerText = "\(minutes):\(seconds)"
            }
            liveStatusLabel.text = timerText
            
            timer.startTimer(withInterval: 1.00) {
                
                isTimer = true
                timerText = getTimer()
                
                if counter == 0 {
                    
                    print("Timer is stop, lives = \(lives)")
                    
                    lives += 1
                    UserDefaults.standard.set(lives, forKey: "lives")
                    timer.stopTimer()
                    isTimer = false
                    counter = 10 * 60
                    self.showLives()
                }
            }
            
        } else if (lives == 10){
            
            // Set lives
            liveStatusLabel.text = "FULL"
        }
        
        
    }
    
    // Update function
    override func update(_ currentTime: TimeInterval) {
     
        if (isTimer && lives < 10) {
            
            liveStatusLabel.text = timerText
        }
        else if (lives == 10){
            
            // Set lives
            liveStatusLabel.text = "FULL"
        }
        liveNumberLabel.text = String(lives)
    }
    
    // Calls when touch begins
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first!
        let location = touch.location(in: self)
        let nodeAtPoint = atPoint(location)
        
        // On of the levels is clicked
        
        for item in 0...numberOfLevels {
            
            if nodeAtPoint.name == "item \(item)" {
                
                // Print which item is clicked
                print("Item \(item + 1) is clicked")
                
                let status = levels[item].status
                
                // Check is level open
                if status && lives > 0 {
                    
                    currentLevel = item
                    self.loadScene("Level_\(item)")
                }
            }
        }
    }
    
    // Load scene
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
    
    // Did finish watching reward video
    func didCompleteRewardedVideo(_ location: String!, withReward reward: Int32) {
        
        lives += Int(reward)
    }
}
