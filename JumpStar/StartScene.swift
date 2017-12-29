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
    
    let texture = [SKTexture(imageNamed: "Wall"), SKTexture(imageNamed: "backbtn"), SKTexture(imageNamed: "Ground"), SKTexture(imageNamed: "idle_1"), SKTexture(imageNamed: "idle_2"), SKTexture(imageNamed: "large_stack"), SKTexture(imageNamed: "Night_Sky"), SKTexture(imageNamed: "powerupYellow_bolt"), SKTexture(imageNamed: "powerupYellow_shield"), SKTexture(imageNamed: "powerupYellow_star"), SKTexture(imageNamed: "Restart_Btn"), SKTexture(imageNamed: "run_0"), SKTexture(imageNamed: "run_1"), SKTexture(imageNamed: "run_2"),
                   SKTexture(imageNamed: "run_3"), SKTexture(imageNamed: "run_4"), SKTexture(imageNamed: "run_5"), SKTexture(imageNamed: "shareIcon"), SKTexture(imageNamed: "star_coin"), SKTexture(imageNamed: "swim_0"), SKTexture(imageNamed: "swim_1"), SKTexture(imageNamed: "swim_2"), SKTexture(imageNamed: "swim_3"), SKTexture(imageNamed: "swim_4"), SKTexture(imageNamed: "swim_5") ]
    
    var startLabel = SKLabelNode()
    var DescpLabel_1 = SKLabelNode()
    var DescpLabel_2 = SKLabelNode()
    var DescpLabel_3 = SKLabelNode()
    var PowerUpLabel_1 = SKLabelNode()
    var PowerUpLabel_2 = SKLabelNode()
    var gameScene: GameScene!
    var background = SKSpriteNode()
    var ground = SKSpriteNode()
    
    
    override func didMove(to view: SKView) {
        
        
        startLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 + 0.15 * self.frame.height)
        startLabel.zPosition = 2
        startLabel.text = "TAP TO START!"
        startLabel.fontName = "Futura"
        startLabel.fontSize = 44
        self.addChild(startLabel)
        
        for i in 0..<2 {
            background = SKSpriteNode(imageNamed: "Night_Sky")
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: -CGFloat(i) * self.frame.width, y: 0)
            background.name = "background"
            background.size = (self.view?.bounds.size)!
            self.addChild(background)
        }
        
        for i in 0..<3 {
            ground = SKSpriteNode(imageNamed: "Ground")
            ground.name = "ground"
            ground.setScale(0.5)
            ground.size.width = (self.scene?.size.width)!
            ground.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            ground.position = CGPoint(x: CGFloat(i) * ground.size.width, y: 0 + ground.frame.height / 2 - 10)
            ground.zPosition = 2
            ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
            ground.physicsBody?.categoryBitMask = (PhysicsStruct.ground)
            ground.physicsBody?.collisionBitMask = (PhysicsStruct.ghost)
            ground.physicsBody?.contactTestBitMask = (PhysicsStruct.ghost)
            ground.physicsBody?.affectedByGravity = false
            ground.physicsBody?.isDynamic = false
            self.addChild(ground)
            
        }
        
        let shieldPwrUp = SKSpriteNode(imageNamed: "powerupYellow_shield")
        shieldPwrUp.position = CGPoint(x: self.frame.width/2 - 0.38 * self.frame.width , y: self.frame.height/2 - 0.075 * self.frame.height)
        shieldPwrUp.setScale(0.7)
        shieldPwrUp.zPosition = 6
        self.addChild(shieldPwrUp)
        
        PowerUpLabel_1.position = CGPoint(x: shieldPwrUp.position.x + 0.4 * self.frame.width , y: shieldPwrUp.position.y - 0.01174 * self.frame.height)
        PowerUpLabel_1.zPosition = 2
        PowerUpLabel_1.text = "Shield: Makes you Indestructible."
        PowerUpLabel_1.fontName = "Futura"
        PowerUpLabel_1.fontSize = 15
        self.addChild(PowerUpLabel_1)
        
        let magnetPowerUp = SKSpriteNode(imageNamed: "powerupYellow_star")
        magnetPowerUp.position = CGPoint(x: self.frame.width/2 - 0.38 * self.frame.width, y: self.frame.height/2 - 0.15 * self.frame.height)
        magnetPowerUp.setScale(0.7)
        magnetPowerUp.zPosition = 6
        self.addChild(magnetPowerUp)
        
        PowerUpLabel_2.position = CGPoint(x: magnetPowerUp.position.x + 0.32 * self.frame.width, y: magnetPowerUp.position.y - 0.01174 * self.frame.height)
        PowerUpLabel_2.zPosition = 2
        PowerUpLabel_2.fontName = "Futura"
        PowerUpLabel_2.text = "Magnet: Attracts Coins."
        PowerUpLabel_2.fontSize = 15
        self.addChild(PowerUpLabel_2)
        
        //Load Game Scene
        gameScene = GameScene(fileNamed: "GameScene")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
 
        hasGameStarted.gameStarted = true

        self.scene?.view?.presentScene(gameScene!)
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        enumerateChildNodes(withName: "background", using: ({
            (node, error) in
            
            let bg = node as! SKSpriteNode
            bg.position = CGPoint(x: bg.position.x - 2, y: bg.position.y)
            if(bg.position.x <= -bg.size.width) {
                
                bg.position = CGPoint(x: bg.position.x + bg.size.width * 2, y: bg.position.y)
                
            }
        }))
        
        enumerateChildNodes(withName: "ground", using: ({
            (node, error) in
            
            node.position.x -= 2
            if node.position.x < -((self.scene?.size.width))! {
                node.position.x += (self.scene?.size.width)! * 3
            }
            
        }))
    }
    
}
