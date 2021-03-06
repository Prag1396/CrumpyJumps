//
//  GameViewController.swift
//  JumpStar
//
//  Created by Pragun Sharma on 27/06/17.
//  Copyright © 2017 Pragun Sharma. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import MessageUI
import AVFoundation

class GameViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    
    var backgroundMusic = AVAudioPlayer()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'StartScene.sks'
            if let scene = SKScene(fileNamed: "TutorialsScene") as? TutorialsScene {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                scene.size = self.view.bounds.size
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            //view.showsPhysics = true
            //view.showsFPS = true
            //view.showsNodeCount = true
        }
        
        do {
            self.backgroundMusic = try AVAudioPlayer(contentsOf: URL.init(string: Bundle.main.path(forResource: "bg", ofType: "mp3")!)!)
            
            backgroundMusic.prepareToPlay()
            
        } catch {
            print(error)
        }
        backgroundMusic.volume = 0.5
        backgroundMusic.play()


    }
    

    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        self.dismiss(animated: true, completion: nil)
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
    
    func shareScore(highScore: Int) {
        
        if MFMessageComposeViewController.canSendText()  {
            let message: MFMessageComposeViewController = MFMessageComposeViewController()
            message.messageComposeDelegate = self
            message.recipients = nil
            message.body = "I challenge you to beat my high score in JumpStar. My superscore was \(highScore).\n Link: https://itunes.apple.com/us/app/crumpy-jumps/id1328710333?ls=1&mt=8"
            self.present(message, animated: true, completion: nil)
        } else {
            //If device does not have the ability to send messages
            let alert = UIAlertController(title: "WARNING", message: "Your device does not have the ability to send text messages", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
 }










