//
//  StartScene.swift
//  JumpStar
//
//  Created by Pragun Sharma on 07/07/17.
//  Copyright © 2017 Pragun Sharma. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import AVFoundation

class StartScene: SKScene {
    
    
    var startLabel = SKLabelNode()
    var gameScene: GameScene!

    
    
    let texture = [SKTexture(imageNamed: "Wall"), SKTexture(imageNamed: "backbtn"), SKTexture(imageNamed: "Ground"), SKTexture(imageNamed: "idle_1"), SKTexture(imageNamed: "idle_2"), SKTexture(imageNamed: "large_stack"), SKTexture(imageNamed: "Night_Sky"), SKTexture(imageNamed: "powerupYellow_bolt"), SKTexture(imageNamed: "powerupYellow_shield"), SKTexture(imageNamed: "powerupYellow_star"), SKTexture(imageNamed: "Restart_Btn"), SKTexture(imageNamed: "run_0"), SKTexture(imageNamed: "run_1"), SKTexture(imageNamed: "run_2"),
                   SKTexture(imageNamed: "run_3"), SKTexture(imageNamed: "run_4"), SKTexture(imageNamed: "run_5"), SKTexture(imageNamed: "shareIcon"), SKTexture(imageNamed: "star_coin"), SKTexture(imageNamed: "swim_0"), SKTexture(imageNamed: "swim_1"), SKTexture(imageNamed: "swim_2"), SKTexture(imageNamed: "swim_3"), SKTexture(imageNamed: "swim_4"), SKTexture(imageNamed: "swim_5") ]
    
    override func didMove(to view: SKView) {
        
        SKTexture.preload(texture, withCompletionHandler: {})
        
        
      
        
        let background = SKSpriteNode(imageNamed: "Night_Sky")
        background.anchorPoint = CGPoint.zero
        background.position = CGPoint(x: 0, y: 0)
        background.name = "Background"
        background.size = (self.view?.bounds.size)!
        self.addChild(background)
        
        
        startLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 + 100)
        startLabel.zPosition = 2
        startLabel.text = "TAP TO START!"
        startLabel.fontSize = 50
        self.addChild(startLabel)
        
        let ground = SKSpriteNode(imageNamed: "Ground")
        ground.setScale(0.5)
        ground.position = CGPoint(x: self.frame.width / 2, y: 0 + ground.frame.height / 2)
        self.addChild(ground)
        
        //Load Game Scene
        gameScene = GameScene(fileNamed: "GameScene")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
 
        hasGameStarted.gameStarted = true

        self.scene?.view?.presentScene(gameScene!)
        
    }
    
}
