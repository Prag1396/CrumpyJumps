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
    
    
    let texture = [SKTexture(imageNamed: "Wall"), SKTexture(imageNamed: "backbtn"), SKTexture(imageNamed: "Ground"), SKTexture(imageNamed: "idle_1"), SKTexture(imageNamed: "idle_2"), SKTexture(imageNamed: "large_stack"), SKTexture(imageNamed: "Night_Sky"), SKTexture(imageNamed: "powerupYellow_bolt"), SKTexture(imageNamed: "powerupYellow_shield"), SKTexture(imageNamed: "powerupYellow_star"), SKTexture(imageNamed: "Restart_Btn"), SKTexture(imageNamed: "run_0"), SKTexture(imageNamed: "run_1"), SKTexture(imageNamed: "run_2"),
                   SKTexture(imageNamed: "run_3"), SKTexture(imageNamed: "run_4"), SKTexture(imageNamed: "run_5"), SKTexture(imageNamed: "shareIcon"), SKTexture(imageNamed: "star_coin"), SKTexture(imageNamed: "swim_0"), SKTexture(imageNamed: "swim_1"), SKTexture(imageNamed: "swim_2"), SKTexture(imageNamed: "swim_3"), SKTexture(imageNamed: "swim_4"), SKTexture(imageNamed: "swim_5") ]
    
    var timer = Timer()
    var background = SKSpriteNode()
    var ground = SKSpriteNode()
    var welcomeNode = SKLabelNode()
    var cont = SKLabelNode()
    var ghost = SKSpriteNode()
    var doneIcon = SKSpriteNode()
    var moonwalk = UISwipeGestureRecognizer()
    var dragPress = UIPanGestureRecognizer()
    
    var run_animation = SKAction(named: "run")
    var fly_animation = SKAction(named: "fly")
    
    var playJumpSound = AVAudioPlayer()
    
    let SWIPE_LEFT_THRESHOLD: CGFloat = -1000.0
    
    var dragHandAnimation = SKAction()
    var swipeLeftAnimation = SKAction()
    var tutorialCount: Int = 0
    let tutorialStatusCheck = UserDefaults.standard
    
    var sceneToLoad: StartScene!
    
    override func didMove(to view: SKView) {
        
        SKTexture.preload(texture, withCompletionHandler: {})

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
        
        //Load Start Scene
        sceneToLoad = StartScene(fileNamed: "StartScene")
        
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
        
        
        welcomeNode.text = "CRUMPY JUMPS"
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
        
        let label: SKLabelNode = SKLabelNode()
        label.text = "Drag more to jump higher and less to jump lower"
        label.name = "Instructionlabelsmall"
        label.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 + 0.2998 * self.frame.height)
        label.fontName = "Futura"
        label.fontSize = 15
        label.zPosition = 2
        self.addChild(label)
        
        let smallHandIcon = SKSpriteNode(imageNamed: "iPhone 8_00")
        smallHandIcon.name = "dragAnimation"
        smallHandIcon.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        smallHandIcon.setScale(0.8)
        smallHandIcon.zPosition = 2
        
        let handDrag_frame1 = SKTexture.init(imageNamed: "iPhone 8_00")
        let handDrag_frame2 = SKTexture.init(imageNamed: "iPhone 8_01")
        let handDrag_frame3 = SKTexture.init(imageNamed: "iPhone 8_02")
        let handDrag_frame4 = SKTexture.init(imageNamed: "iPhone 8_03")
        let handDrag_frame5 = SKTexture.init(imageNamed: "iPhone 8_04")
        let handDrag_frame6 = SKTexture.init(imageNamed: "iPhone 8_05")
        let handDrag_frame7 = SKTexture.init(imageNamed: "iPhone 8_06")
        let handDrag_frame8 = SKTexture.init(imageNamed: "iPhone 8_07")

        
        let handDrags: [SKTexture] = [handDrag_frame1, handDrag_frame2, handDrag_frame3, handDrag_frame4, handDrag_frame5, handDrag_frame6, handDrag_frame7, handDrag_frame8]
        
        dragHandAnimation = SKAction.animate(with: handDrags, timePerFrame: 0.12, resize: false, restore: false)
        smallHandIcon.run(SKAction.repeatForever(dragHandAnimation))
        
        
        self.addChild(smallHandIcon)
        

        
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(createHandIconBig), userInfo: nil, repeats: false)
    }
    
    @objc func createHandIconBig() {
       self.childNode(withName: "Instructionlabelsmall")?.removeFromParent()
       self.childNode(withName: "dragAnimation")?.removeFromParent()
        
        //Create Swipe Left Animation
        
        let label: SKLabelNode = SKLabelNode()
        label.text = "Swipe Left fast to perform a moonwalk"
        label.name = "Instructionlabelsmall"
        label.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 + 0.2998 * self.frame.height)
        label.fontName = "Futura"
        label.fontSize = 15
        label.zPosition = 2
        self.addChild(label)
        
        
        let swipeLeftIcon = SKSpriteNode(imageNamed: "iPhone_00")
        swipeLeftIcon.name = "swipeLeft"
        swipeLeftIcon.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        swipeLeftIcon.setScale(1.3)
        swipeLeftIcon.zPosition = 2
        self.addChild(swipeLeftIcon)
        
        let swipteLeft_frame1 = SKTexture.init(imageNamed: "iPhone_00")
        let swipteLeft_frame2 = SKTexture.init(imageNamed: "iPhone_01")
        let swipteLeft_frame3 = SKTexture.init(imageNamed: "iPhone_02")
        let swipteLeft_frame4 = SKTexture.init(imageNamed: "iPhone_03")
        let swipteLeft_frame5 = SKTexture.init(imageNamed: "iPhone_04")
        
        let swipeleftFrames: [SKTexture] = [swipteLeft_frame1, swipteLeft_frame2, swipteLeft_frame3, swipteLeft_frame4, swipteLeft_frame5]
        
        swipeLeftAnimation = SKAction.animate(with: swipeleftFrames, timePerFrame: 0.12, resize: false, restore: false)
        swipeLeftIcon.run(SKAction.repeatForever(swipeLeftAnimation))
        
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(createTouchIcon), userInfo: nil, repeats: false)
    
    }
    
    
    @objc func createTouchIcon() {
        
        self.childNode(withName: "Instructionlabelsmall")?.removeFromParent()
        self.childNode(withName: "swipeLeft")?.removeFromParent()
        
        let label: SKLabelNode = SKLabelNode()
        label.text = "Tap the screen to decrease velocity in air."
        label.name = "Instructionlabelsmall"
        label.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 + 0.2998 * self.frame.height)
        label.fontName = "Futura"
        label.fontSize = 15
        label.zPosition = 2
        self.addChild(label)
        
        let touchIcon = SKSpriteNode(imageNamed: "Tap")
        touchIcon.name = "touch"
        touchIcon.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        touchIcon.setScale(0.6)
        touchIcon.zPosition = 2
        self.addChild(touchIcon)
        
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(tutorialDone), userInfo: nil, repeats: false)
    }
    
    
    
    @objc func tutorialDone() {
        
        doneIcon = SKSpriteNode(imageNamed: "done")
        doneIcon.position = CGPoint(x: self.frame.width/2 + 0.3733 * self.frame.width, y: self.frame.height / 2 + 0.4347 * self.frame.height)
        doneIcon.zPosition = 2
        doneIcon.setScale(0.7)
        self.addChild(doneIcon)
        
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
                if(tutorialStatusCheck.value(forKey: "donePressed") != nil) {
                    tutorialCount = tutorialStatusCheck.value(forKey: "donePressed") as! Int
                    if(tutorialCount > 0) {
                        self.view?.presentScene(sceneToLoad)
                    }
                    
                }
                addPlayer()
                createHandIcon()
            }
        }
        
        ghost.physicsBody?.velocity.dx *= 0.6
        ghost.physicsBody?.velocity.dy *= 0.6
        
        for touch in touches  {
            
            let location = touch.location(in: self)
            if(doneIcon.contains(location)) {
                tutorialCount += 1
                let tutorialStatusCheck = UserDefaults.standard
                tutorialStatusCheck.set(tutorialCount, forKey: "donePressed")
                tutorialStatusCheck.synchronize()
                self.view?.presentScene(sceneToLoad)
                
            }
            

                    
        }
   }
    
    

}

