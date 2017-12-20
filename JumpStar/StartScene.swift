//
//  StartScene.swift
//  JumpIn
//
//  Created by Pragun Sharma on 07/07/17.
//  Copyright © 2017 Pragun Sharma. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class StartScene: SKScene {
    
    var base_viewController: GameViewController!
    var startLabel = SKLabelNode()
    var gameScene: GameScene!
    override func didMove(to view: SKView) {
        
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
