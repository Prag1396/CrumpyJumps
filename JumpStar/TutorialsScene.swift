//
//  TutorialsScene.swift
//  JumpStar
//
//  Created by Pragun Sharma on 12/24/17.
//  Copyright © 2017 Pragun Sharma. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import AVFoundation

class TutorialsScene: SKScene, UIGestureRecognizerDelegate, SKPhysicsContactDelegate {
    
    var timer = Timer()
    
    var background = SKSpriteNode()
    var ground = SKSpriteNode()
    var welcomeNode = SKLabelNode()
    var cont = SKLabelNode()
    var ghost = SKSpriteNode()
    
    var moonwalk = UISwipeGestureRecognizer()
    var dragPress = UIPanGestureRecognizer()
    
    var run_animation = SKAction(named: "run")
    var fly_animation = SKAction(named: "fly")
    
    var playJumpSound = AVAudioPlayer()
    
    let SWIPE_LEFT_THRESHOLD: CGFloat = -1000.0
    
    override func didMove(to view: SKView) {
        
        
        self.view?.isUserInteractionEnabled = true
        self.physicsWorld.contactDelegate = self 
        self.physicsBody = SKPhysicsBody.init(edgeLoopFrom: self.frame)
        
        
        moonwalk = UISwipeGestureRecognizer()
        moonwalk.direction = .left
        moonwalk.delegate = self
        self.view?.addGestureRecognizer(moonwalk)
        
        dragPress = UIPanGestureRecognizer(target: self, action: #selector(performAction(gesture:)))
        dragPress.delegate = self
        dragPress.maximumNumberOfTouches = 1
        self.view?.addGestureRecognizer(dragPress)
        
        
        do {
            self.playJumpSound = try AVAudioPlayer(contentsOf: URL.init(string: Bundle.main.path(forResource: "jump", ofType: "wav")!)!)
            self.playJumpSound.prepareToPlay()
            
        } catch {
            
            print(error)
        }
        
        playJumpSound.volume = 1.4
        
        createScene()
        
        
        
        
    }
    
    
    @objc func performAction(gesture: UIPanGestureRecognizer) {
        
        
        var duration: TimeInterval = 0.0
        let maxValueForDuration = 0.42
        
        switch gesture.state {
        case .began:
            LongTouchTime.pressedStartTime = NSDate.timeIntervalSinceReferenceDate
        case .ended:
            
            let vel: CGPoint = gesture.velocity(in: self.view)
            if(vel.x < SWIPE_LEFT_THRESHOLD) {
                resetPosition()
            } else {
                
                
                duration = NSDate.timeIntervalSinceReferenceDate - LongTouchTime.pressedStartTime
                if duration > maxValueForDuration {
                    duration = maxValueForDuration
                }
                projectileMotion(duration: CGFloat(duration))
            }
        default:
            break
        }
    }
    
    func projectileMotion(duration: CGFloat) {
        
        var projectileForce = CGVector(dx: 35, dy: 100)
        projectileForce.dy = 2.0 * CGFloat(duration).squareRoot() * projectileForce.dy
        projectileForce.dx = 1.5 * CGFloat(duration).squareRoot() * projectileForce.dx
        
        playJumpSound.play()
        ghost.physicsBody?.applyImpulse(projectileForce)
        ghost.removeAllActions()
        ghost.run(SKAction.repeatForever(fly_animation!), withKey: "fly")
        
    }
    
    @objc func resetPosition() {
        
        if (ghost.position.x  < 77) {
            ghost.physicsBody?.applyImpulse(CGVector(dx: 20, dy: 0))
        }
        else {
            self.ghost.physicsBody?.applyImpulse((CGVector(dx: -50, dy: 0)))
        }
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer is UIPanGestureRecognizer || gestureRecognizer is UISwipeGestureRecognizer) {
            return true
        } else {
            return false
        }
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if(firstBody.isEqual(ghost.physicsBody) && secondBody.isEqual(self.physicsBody) || firstBody.isEqual(self.physicsBody) && secondBody.isEqual(ghost.physicsBody)) {
            
            ghost.physicsBody?.velocity = CGVector(dx: 0.5, dy: 0)
            ghost.removeAllActions()
            ghost.run(SKAction.repeatForever(run_animation!), withKey: "run")
            resetPosition()
        }
            
        else if((firstBody.categoryBitMask == PhysicsStruct.ghost && secondBody.categoryBitMask == PhysicsStruct.ground) || (firstBody.categoryBitMask == PhysicsStruct.ground && secondBody.categoryBitMask == PhysicsStruct.ghost )) {
            
            ghost.removeAllActions()
            ghost.run(SKAction.repeatForever(run_animation!), withKey: "run")
        }
        
        
    }
    
    func createScene() {
        
        
        welcomeNode.text = "WELCOME TO THE TUTORIAL"
        welcomeNode.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 + 0.2998 * self.frame.height)
        welcomeNode.fontColor = .white
        welcomeNode.fontName = "Futura"
        welcomeNode.fontSize = 20
        welcomeNode.setScale(0)
        welcomeNode.zPosition = 2
        welcomeNode.name = "wc"
        self.addChild(welcomeNode)
        welcomeNode.run(SKAction.scale(to: 1.0, duration: 0.5))
        
        cont.text = "CLICK TO CONTINUE"
        cont.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 - 0.2998 * self.frame.height)
        cont.fontColor = .white
        cont.fontSize = 15
        cont.name = "contlabel"
        cont.fontName = "Futura"
        cont.zPosition = 2
        self.addChild(cont)
        
        for i in 0..<2 {
            let background = SKSpriteNode(imageNamed: "Night_Sky")
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
        
    }
    
    
    func createHandIcon() {
        
        let smallHandIcon = SKSpriteNode(imageNamed: "Hand-small")
        smallHandIcon.name = "smallHand"
        smallHandIcon.position = CGPoint(x: self.frame.width/2 + 0.2 * self.frame.width, y: self.frame.height/2 - 0.112 * self.frame.height)
        smallHandIcon.setScale(0.25)
        smallHandIcon.zPosition = 2
        self.addChild(smallHandIcon)
        
        let label: SKLabelNode = SKLabelNode()
        label.text = "Drag in accordance to the length of the arrow"
        label.name = "Instructionlabelsmall"
        label.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 + 0.2998 * self.frame.height)
        label.fontName = "Futura"
        label.fontSize = 15
        label.zPosition = 2
        self.addChild(label)
        
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(createHandIconBig), userInfo: nil, repeats: false)
    }
    
    @objc func createHandIconBig() {
      self.childNode(withName: "Instructionlabelsmall")?.removeFromParent()
      self.childNode(withName: "smallHand")?.removeFromParent()
    }
    
    func addPlayer() {
        
        
        let run_frame1 = SKTexture.init(imageNamed: "run_0")
        let run_frame2 = SKTexture.init(imageNamed: "run_1")
        let run_frame3 = SKTexture.init(imageNamed: "run_2")
        let run_frame4 = SKTexture.init(imageNamed: "run_3")
        let run_frame5 = SKTexture.init(imageNamed: "run_4")
        let run_frame6 = SKTexture.init(imageNamed: "run_5")
        
        let fly_frame1 = SKTexture.init(imageNamed: "swim_0")
        let fly_frame2 = SKTexture.init(imageNamed: "swim_1")
        let fly_frame3 = SKTexture.init(imageNamed: "swim_2")
        let fly_frame4 = SKTexture.init(imageNamed: "swim_3")
        let fly_frame5 = SKTexture.init(imageNamed: "swim_4")
        let fly_frame6 = SKTexture.init(imageNamed: "swim_5")
        
        
        
        let run_frames: [SKTexture] = [run_frame1, run_frame2, run_frame3, run_frame4, run_frame5, run_frame6]
        let fly_frames: [SKTexture] = [fly_frame1, fly_frame2, fly_frame3, fly_frame4, fly_frame5, fly_frame6]
        
        ghost = SKSpriteNode(imageNamed: "idle_1")
        
        ghost.position = CGPoint(x: self.frame.width / 2 - 110 , y: ground.position.y + 50)
        ghost.physicsBody = SKPhysicsBody(texture: ghost.texture!, size: ghost.size)
        ghost.physicsBody?.categoryBitMask = (PhysicsStruct.ghost)
        ghost.physicsBody?.collisionBitMask = (PhysicsStruct.wall | PhysicsStruct.ground)
        ghost.physicsBody?.contactTestBitMask = (PhysicsStruct.ground | PhysicsStruct.wall | PhysicsStruct.Score)
        ghost.physicsBody?.fieldBitMask = 0
        ghost.physicsBody?.restitution = 0.5
        ghost.physicsBody?.density = 5
        ghost.physicsBody?.friction = 3
        ghost.physicsBody?.linearDamping = -0.3
        ghost.physicsBody?.usesPreciseCollisionDetection = true
        ghost.physicsBody?.affectedByGravity = true
        ghost.physicsBody?.isDynamic = true
        ghost.physicsBody?.allowsRotation = false
        ghost.physicsBody?.velocity = CGVector(dx: 0.05, dy: 0)
        ghost.zPosition = 2
        
        
        run_animation = SKAction.animate(with: run_frames, timePerFrame: 0.15, resize: false, restore: false)
        fly_animation = SKAction.animate(with: fly_frames, timePerFrame: 0.15, resize: false, restore: false)
        ghost.run(SKAction.repeatForever(run_animation!), withKey: "run")
        
        self.addChild(ghost)
        
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let _ = touches.first {
                //destroy label
            if((self.childNode(withName: "contlabel")) != nil) {
                self.childNode(withName: "wc")?.removeFromParent()
                self.childNode(withName: "contlabel")?.removeFromParent()
                addPlayer()
                createHandIcon()
            }
        }
            
        
    }
    
}
