//
//  GameViewController.swift
//  Math Tetris
//
//  Created by Saken Sydykov on 30.06.17.
//  Copyright © 2017 Strixit. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        

        if let scene = MainMenu(fileNamed:"MainMenu") {
            
            // Google analytics
            
            if (GAI.sharedInstance().defaultTracker) != nil {
                #if DEBUG
                    
                    print("default tracker")
                    
                #endif
            }
            
            //        let tracker = GAI.sharedInstance().defaultTracker
            let tracker = GAI.sharedInstance().tracker(withTrackingId: "UA-103558946-1")
            tracker?.set(kGAIScreenName, value: "Screen Name")
            let builder = GAIDictionaryBuilder.createScreenView()
            tracker?.send(builder?.build()! as! [NSObject : AnyObject])
            
            
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill
            
            skView.presentScene(scene)
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillLayoutSubviews() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.startVideoAd), name: NSNotification.Name(rawValue: "showVideoRewardAd"), object: nil)
        
    }
    
    func startVideoAd() {
        
        // Do something - play video ad
        
    }
}
