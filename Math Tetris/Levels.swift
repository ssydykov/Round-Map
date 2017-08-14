//
//  Levels.swift
//  Math Tetris
//
//  Created by Saken Sydykov on 07.07.17.
//  Copyright © 2017 Strixit. All rights reserved.
//

import SpriteKit
import Foundation
import SystemConfiguration
import Google

// Variables
var isGameOver = false
var gameCompleted = false
var counter = 5 * 60
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
    var xButton: MSButtonNode!
    var goPremiumButton: MSButtonNode!
    var watchAddButton: MSButtonNode!
    var restoreButton: MSButtonNode!
    
    // Nodes
    var cameraNode: SKCameraNode!
    var liveNumberLabel: SKLabelNode!
    var liveStatusLabel: SKLabelNode!
    var gameOverDialog: SKSpriteNode!
    var blackScreen: SKSpriteNode!
    
    // Variables
    var levels: Array<Level> = []
    let numberOfLevels = 11
    let activityInd = UIActivityIndicatorView()
    
    // Labels
    var internetLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        
        trackScreenView()
        
        // In app
        NotificationCenter.default.addObserver(self, selector: #selector(handlePurchaseNotification(_:)),
            name: NSNotification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification), object: nil)
        
        // Initialize variables
        rightButton = self.childNode(withName: "//rightButton") as! MSButtonNode
        leftButton = self.childNode(withName: "//leftButton") as! MSButtonNode
        cameraNode = self.childNode(withName: "camera") as! SKCameraNode
        self.camera = cameraNode
        liveStatusLabel = self.childNode(withName: "//liveStatus") as! SKLabelNode
        liveNumberLabel = self.childNode(withName: "//liveNumber") as! SKLabelNode
        addButton = self.childNode(withName: "//addButton") as! MSButtonNode
        hiddenButton = self.childNode(withName: "//hiddenButton") as! MSButtonNode
        gameOverDialog = self.childNode(withName: "//watchAddDialog") as! SKSpriteNode
        xButton = self.childNode(withName: "//xButton") as! MSButtonNode
        goPremiumButton = self.childNode(withName: "//goPremiumButton") as! MSButtonNode
        watchAddButton = self.childNode(withName: "//watchAddButton") as! MSButtonNode
        internetLabel = self.childNode(withName: "//internetLabel") as! SKLabelNode
        blackScreen = self.childNode(withName: "//blackScreen") as! SKSpriteNode
        restoreButton = self.childNode(withName: "//restoreButton") as! MSButtonNode
        
        // X Button clicked
        xButton.selectedHandler = {
            
            self.gameOverDialog.isHidden = true
        }
        
        // Go premium button clicked
        goPremiumButton.selectedHandler = {
            
            // Link to paid version
            
            // Unhide black background
            self.blackScreen.isHidden = false
            
            // Add loading spiner
            self.activityInd.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
            self.activityInd.startAnimating()
            self.view?.addSubview(self.activityInd)
            
            // Turn off touches
            self.view?.isUserInteractionEnabled = false
            
            // Hide label and dialog
            self.gameOverDialog.isHidden = true
            self.internetLabel.isHidden = true
            
            
            IAPProducts.store.requestProducts{success, productArray in
                
                if success && productArray != nil && productArray!.count > 0 {
                    let product = productArray![0]
                    
                    //if non then, direct to the sales page
                    IAPProducts.store.buyProduct(product)
                    
                } else {
                    
                    self.stopSpiner()
                }
            }
        }
        
        // Restore button clicked
        restoreButton.selectedHandler = {
            
            IAPProducts.store.restorePurchases()
        }
        
        // Watch add button clicked
        watchAddButton.selectedHandler = {
            
            if self.isInternetAvailable() {
                
                // Unhide black background
                self.blackScreen.isHidden = false
                
                // Add loading spiner
                self.activityInd.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
                self.activityInd.startAnimating()
                self.view?.addSubview(self.activityInd)
                
                // Turn off touches
                self.view?.isUserInteractionEnabled = false
                
                // Hide label and dialog
                self.gameOverDialog.isHidden = true
                self.internetLabel.isHidden = true
                
                // Show reward video
                Chartboost.showRewardedVideo(CBLocationMainMenu)
                
                // Cache video
                self.cacheRewardVideo()
            }
            else if Chartboost.hasInterstitial(CBLocationMainMenu) {
                
                Chartboost.showInterstitial(CBLocationMainMenu)
            }
            else {
                
                self.internetLabel.isHidden = false
            }
        }
        
        // Reward video delegate
        Chartboost.setDelegate(self)
        
        // Right arrow button is clicked
        rightButton.selectedHandler = {
            
            print("Right arrow clicked")
            
            let action = SKAction.moveTo(x: 568, duration: 0.3)
            self.cameraNode.run(action)
        }
        
        // Left arrow button is clicked
        leftButton.selectedHandler = {
            
            print("Left arrow clicked")
            
            let action = SKAction.moveTo(x: 0, duration: 0.3)
            self.cameraNode.run(action)
        }
        
        // Add button is clicked
        addButton.selectedHandler = {
            
            print("Add button clicked")
        
            self.gameOverDialog.isHidden = false
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
                
                // If lives equals 0
                if lives == 0 {
                    
                    isGameOver = true
                }
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
        
        // If game over show dialog
        if isGameOver {
            
            gameOverDialog.isHidden = false
        }
        
        // If game completed
        if gameCompleted {
            
            // Show completed message
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
            print("Label: \(levels[item].label), status: \(levels[item].status), time: \(levels[item].time)")
            
            let status = levels[item].status
            let time = levels[item].time
            let star = levels[item].stars
            let lockItem = listItem.childNode(withName: "lock") as! SKSpriteNode
            let starOrange0 = listItem.childNode(withName: "star_0_orange") as! SKSpriteNode
            let star0 = listItem.childNode(withName: "star_0") as! SKSpriteNode
            let star1 = listItem.childNode(withName: "star_1") as! SKSpriteNode
            let star2 = listItem.childNode(withName: "star_2") as! SKSpriteNode
            let star3 = listItem.childNode(withName: "star_3") as! SKSpriteNode
            
            // If level is open
            if status {
                
                // If level is not passed
                if time != "" {
                    
                    // Set level border color to green
                    listItem.strokeColor = UIColor(red: 170/255, green: 238/255, blue: 101/255, alpha: 1)
                    
                    switch star {
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
                }
                    
                // If level already passed
                else {
                    
                    // Set level border color to orange
                    listItem.strokeColor = UIColor(red: 215/255, green: 158/255, blue: 65/255, alpha: 1)
                    
                    // Set orange star visible
                    starOrange0.isHidden = false
                }
                
                // Set lock item invissible
                lockItem.isHidden = true
            }
                
            // If level is closed
            else {
                
                // Set level border color to red
                listItem.strokeColor = UIColor(red: 255/255, green: 57/255, blue: 93/255, alpha: 1)
                
                // Set lock item vissible
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
                    counter = 5 * 60
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
        else if (lives >= 10){
            
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
                else if status {
                    
                    self.gameOverDialog.isHidden = false
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
        
        // Stop spiner
        stopSpiner()
        
        lives += Int(reward)
        
        // Save lives number
        UserDefaults.standard.set(lives, forKey: "lives")
    }
    
    // Reward video closed
    func didCloseRewardedVideo(location: String!) {
    
        // Stop spiner
        stopSpiner()
    }
    
    func didFail(toLoadRewardedVideo location: String!, withError error: CBLoadError) {
        print("Failed to load rewarded video: \(error)")
    }
    
    // Stop spiner
    func stopSpiner() {
        
        print("Display ad video")
        
        // Unhide black background
        self.blackScreen.isHidden = true
        
        // Stop loading spiner
        self.activityInd.stopAnimating()
        
        // Turn on touches
        self.view?.isUserInteractionEnabled = true
    }
    
    func trackScreenView() {
        
        let tracker = GAI.sharedInstance().tracker(withTrackingId: "UA-103558946-1")
        tracker?.set(kGAIScreenName, value: "Levels")
        tracker?.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject]?)
    }
    
    func cacheRewardVideo(){
        
        Chartboost.cacheInterstitial(CBLocationMainMenu);
        Chartboost.cacheRewardedVideo(CBLocationMainMenu);
    }
    
    func handlePurchaseNotification(_ notification: Notification) {
        
        // Activate premium
        stopSpiner()
        
    }
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
}
