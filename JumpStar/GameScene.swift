//
//  GameScene.swift
//  JumpStar
//
//  Created by Pragun Sharma on 27/06/17.
//  Copyright © 2017 Pragun Sharma. All rights reserved.
//



import SpriteKit
import GameplayKit
import AVFoundation



struct PhysicsStruct {
    
    static let ghost: UInt32 = 0x1 << 1
    static let ground: UInt32 = 0x1 << 2
    static let wall: UInt32 = 0x1 << 3
    static let Score: UInt32 = 0x1 << 4
    static let temp_grav: UInt32 = 0x1 << 5
}

struct hasGameStarted {
    static var gameStarted = Bool()
}

struct LongTouchTime {
    static var pressedStartTime: TimeInterval = 0.0
}


class GameScene: SKScene, SKPhysicsContactDelegate, SKViewDelegate, UIGestureRecognizerDelegate {
    
    var playSound = AVAudioPlayer()
    var playJumpSound = AVAudioPlayer()
    var collisionSound = AVAudioPlayer()
    var ground = SKSpriteNode()
    var ghost = SKSpriteNode()
    var wallPair = SKNode()
    var scoreNode = SKSpriteNode()
    var moveAndRemove = SKAction()
    var score = Int()
    var highScore = Int()
    var died = Bool()
    var shareScoreBtn = SKSpriteNode()
    var restartButton = SKSpriteNode()
    var upgradeButton = SKSpriteNode()
    var numberOfCoins = SKSpriteNode()
    var topWall = SKSpriteNode()
    var bottomWall = SKSpriteNode()
    var highScoreLabel = SKLabelNode()
    var shieldPwrUp = SKSpriteNode()
    var numberOfShieldsLabel = SKLabelNode()
    var magnetPowerUp = SKSpriteNode()
    var numberOfMagnetsLabel = SKLabelNode()
    var isDeactivated = Bool()
    var isMagnetic = Bool()
    var shieldTimer = Timer()
    var magTimer = Timer()
    var tempGravity = SKFieldNode()
    var duration = Float()
    var timer = Timer()
    var midptX = UIScreen.main.bounds.midX
    var midptY = UIScreen.main.bounds.midY
    var run_animation = SKAction(named: "run")
    var fly_animation = SKAction(named: "fly")
    var hit_animation = SKAction(named: "hit")
    var alreadyContacted = Bool()
    var maxValueForVelocity = 4.0
    
    let scoreLabel = SKLabelNode()
    let numberofCoinsLabel = SKLabelNode()
    
    var doubleTap = UITapGestureRecognizer()
    var dragPress = UIPanGestureRecognizer()
   
    
    func restartScene() {
        
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        hasGameStarted.gameStarted = false
        score = 0
        isDeactivated = false
        isMagnetic = false
        
        let startScene = GameScene(fileNamed: "StartScene")
        self.scene?.view?.presentScene(startScene!, transition: .fade(withDuration: 0.8))
        
    }
    
    func createScene() {
        
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
        
        scoreLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.5)
        scoreLabel.text = "\(score)"
        scoreLabel.fontName = "04b_19"
        scoreLabel.fontSize = 60
        scoreLabel.zPosition = 5
        self.addChild(scoreLabel)
        
        
        //Add a gravity field to the ghost (player) and have coins physics body react to player's gravityField
        tempGravity = SKFieldNode.radialGravityField()
        tempGravity.position = CGPoint(x: ghost.position.x, y: ghost.position.y)
        tempGravity.strength = 9.8
        tempGravity.categoryBitMask = PhysicsStruct.temp_grav
        tempGravity.isEnabled = false
        self.addChild(tempGravity)
        
        //Create the power ups icons to tell how many the user has purchased
        shieldPwrUp = SKSpriteNode(imageNamed: "powerupYellow_shield")
        shieldPwrUp.position = CGPoint(x: self.frame.width*0.9, y: self.frame.height - self.frame.height * 0.9771)
        shieldPwrUp.setScale(0.7)
        shieldPwrUp.zPosition = 6
        self.addChild(shieldPwrUp)
        
        
        numberOfShieldsLabel.text = "\(powerUpClicked.shieldCount)"
        numberOfShieldsLabel.fontName = "04b_19"
        numberOfShieldsLabel.fontSize = 13
        numberOfShieldsLabel.position = CGPoint(x: shieldPwrUp.position.x + 20, y: shieldPwrUp.position.y)
        numberOfShieldsLabel.zPosition = 6
        self.addChild(numberOfShieldsLabel)
        
        
        magnetPowerUp = SKSpriteNode(imageNamed: "powerupYellow_star")
        magnetPowerUp.position = CGPoint(x: shieldPwrUp.position.x - 50 , y: shieldPwrUp.position.y)
        magnetPowerUp.setScale(0.7)
        magnetPowerUp.zPosition = 6
        self.addChild(magnetPowerUp)
        
        numberOfMagnetsLabel.text = "\(powerUpClicked.magnetCount)"
        numberOfMagnetsLabel.fontName = "04b_19"
        numberOfMagnetsLabel.fontSize = 13
        numberOfMagnetsLabel.position = CGPoint(x: magnetPowerUp.position.x + 20, y: magnetPowerUp.position.y)
        numberOfMagnetsLabel.zPosition = 6
        self.addChild(numberOfMagnetsLabel)
        
        numberOfCoins.isHidden = true
        numberofCoinsLabel.isHidden = true
        
        if(hasGameStarted.gameStarted == true) {
            let spawn = SKAction.run( {
                () in
                self.createWalls()
            })
            let delay = SKAction.wait(forDuration: 4.0)
            let SpawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatForever(SpawnDelay)
            self.run(spawnDelayForever)
            
            let distance = CGFloat(self.frame.width + wallPair.frame.width)
            let movePipes = SKAction.moveBy(x: -distance - 50, y: 0, duration: TimeInterval(0.008 * distance))
            let removePipes = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePipes ,removePipes])
        }
        
        
    }
    
    override func didMove(to view: SKView) {
        
        self.view?.isUserInteractionEnabled = true
        self.physicsWorld.contactDelegate = self
        self.physicsBody = SKPhysicsBody.init(edgeLoopFrom: self.frame)


        alreadyContacted = false
        
        doubleTap = UITapGestureRecognizer(target: self, action: #selector(resetPosition))
        doubleTap.numberOfTapsRequired = 2
        self.view?.addGestureRecognizer(doubleTap)
        
        dragPress = UIPanGestureRecognizer(target: self, action: #selector(performAction(gesture:)))
        self.view?.addGestureRecognizer(dragPress)
        
        
        let highScoreDefult = UserDefaults.standard
        let getCoinsCollected = UserDefaults.standard
        let magPowerUpsSaved = UserDefaults.standard
        let shieldPowerUpsSaved = UserDefaults.standard
        
        if(highScoreDefult.value(forKey: "HighScore") != nil) {
            
            highScore = highScoreDefult.value(forKey: "HighScore") as! Int
            highScoreLabel.text = "HIGH SCORE: \(self.highScore)"
        }
        
        
        if(getCoinsCollected.value(forKey: "numberOfCoinsCollected") != nil) {
            
            PlayerScore.numberOfCoinsCollected = getCoinsCollected.value(forKey: "numberOfCoinsCollected") as! Int
            numberofCoinsLabel.text = "\(PlayerScore.numberOfCoinsCollected)"
            
        }
        
        if(shieldPowerUpsSaved.value(forKey: "NumberOfShieldCountBought") != nil) {
            
            powerUpClicked.shieldCount = shieldPowerUpsSaved.value(forKey: "NumberOfShieldCountBought") as! Int
            numberOfShieldsLabel.text = "\(powerUpClicked.shieldCount)"
            
        }
        
        if(magPowerUpsSaved.value(forKey: "NumberOfMagnetsCountBought") != nil) {
            
            powerUpClicked.magnetCount = magPowerUpsSaved.value(forKey: "NumberOfMagnetsCountBought") as! Int
            numberOfMagnetsLabel.text = "\(powerUpClicked.magnetCount)"
            
        }
        
        do {
            self.playJumpSound = try AVAudioPlayer(contentsOf: URL.init(string: Bundle.main.path(forResource: "jump", ofType: "wav")!)!)
            self.playSound = try AVAudioPlayer(contentsOf: URL.init(string: Bundle.main.path(forResource: "collect", ofType: "mp3")!)!)
            self.collisionSound = try AVAudioPlayer(contentsOf: URL.init(string: Bundle.main.path(forResource: "collision", ofType: "mp3")!)!)
            
            self.playJumpSound.prepareToPlay()
            self.playSound.prepareToPlay()
            self.collisionSound.prepareToPlay()
            
        } catch {
            
            print(error)
        }
        
        playJumpSound.volume = 1.4
        
        self.createScene()
        
    }
    
    func createButtonandLabels() {
        
        numberofCoinsLabel.text = "\(PlayerScore.numberOfCoinsCollected)"
        numberofCoinsLabel.isHidden = false
        numberOfCoins.isHidden = false
        
        //Creating the Restart Button
        restartButton = SKSpriteNode(imageNamed: "Restart_Btn")
        restartButton.size = CGSize(width: 200, height: 100)
        restartButton.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restartButton.zPosition = 6
        restartButton.setScale(0)
        self.addChild(restartButton)
        restartButton.run(SKAction.scale(to: 1.0, duration: 0.3))
        
        //Creating the ShareScore Button
        shareScoreBtn = SKSpriteNode(imageNamed: "shareIcon")
        shareScoreBtn.size = CGSize(width: 126, height: 126)
        shareScoreBtn.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 - 0.161 * self.frame.height)
        shareScoreBtn.zPosition = 7
        shareScoreBtn.setScale(0.7)
        self.addChild(shareScoreBtn)
        
        numberOfCoins = SKSpriteNode(imageNamed: "large_stack")
        numberOfCoins.position = CGPoint(x: self.frame.width/2 - 0.3866 * self.frame.width, y: self.frame.height / 2 + 0.4385 * self.frame.height)
        numberOfCoins.size = CGSize(width: 60, height: 58)
        numberOfCoins.physicsBody = SKPhysicsBody(rectangleOf: numberOfCoins.size)
        numberOfCoins.physicsBody?.affectedByGravity = false
        numberOfCoins.physicsBody?.isDynamic = false
        numberOfCoins.physicsBody?.categoryBitMask = PhysicsStruct.Score
        numberOfCoins.physicsBody?.collisionBitMask = 0
        numberOfCoins.physicsBody?.contactTestBitMask = 0
        numberOfCoins.zPosition = 6
        
        self.addChild(numberOfCoins)
        
        numberofCoinsLabel.text = "\(PlayerScore.numberOfCoinsCollected)"
        numberofCoinsLabel.fontName = "04b_19"
        numberofCoinsLabel.position = CGPoint(x: numberOfCoins.position.x + 60, y: numberOfCoins.position.y - 20)
        numberofCoinsLabel.zPosition = 6
        self.addChild(numberofCoinsLabel)
        
        
        
        highScoreLabel = SKLabelNode(fontNamed: "04b_19")
        highScoreLabel.fontColor = UIColor.white
        highScoreLabel.text = "HIGH SCORE: \(self.highScore)"
        highScoreLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + 90)
        highScoreLabel.zPosition =  6
        self.addChild(highScoreLabel)
        
        //Creating the Upgrade Button
        upgradeButton = SKSpriteNode(imageNamed: "powerupYellow_bolt")
        upgradeButton.position = CGPoint(x: self.frame.width/2 + 0.3733 * self.frame.width, y: self.frame.height / 2 + 0.4347 * self.frame.height)
        upgradeButton.zPosition = 6
        upgradeButton.setScale(1.2)
        self.addChild(upgradeButton)
        
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if(died == false) {
            
            //Test which objects collided
            let firstBody = contact.bodyA
            let secondBody = contact.bodyB
            
            if(firstBody.categoryBitMask == PhysicsStruct.Score && secondBody.categoryBitMask == PhysicsStruct.ghost) {
                
                if(self.score % 5 == 0 && self.score > 0 && self.score < 40) {
                    if ((ghost.physicsBody?.velocity.dx)! < CGFloat(maxValueForVelocity)) {
                        ghost.physicsBody?.velocity.dx += 0.05
                    }
                   
                }
                if(isMagnetic == true) {
                    turnOnMagEffect()
                }
                
                
                if alreadyContacted == false {
     
                    self.score += 1
                    PlayerScore.numberOfCoinsCollected += 1
                    scoreLabel.text = "\(score)"
                    firstBody.node?.removeFromParent()
                    playSound.play()
                
                    if(score > highScore) {
                    
                        highScore = score
                    }
                
                    let highScoreDefult = UserDefaults.standard
                    highScoreDefult.set(highScore, forKey: "HighScore")
                    highScoreDefult.synchronize()
                
                    let getCoinsCollected = UserDefaults.standard
                    getCoinsCollected.set(PlayerScore.numberOfCoinsCollected, forKey: "numberOfCoinsCollected")
                    getCoinsCollected.synchronize()
                    
                    }
                alreadyContacted = true
            }
                
                
                
            else if(firstBody.categoryBitMask == PhysicsStruct.ghost && secondBody.categoryBitMask == PhysicsStruct.Score) {
                
                if(self.score % 5 == 0 && self.score > 0 && self.score < 40) {
                    if ((ghost.physicsBody?.velocity.dx)! < CGFloat(maxValueForVelocity)) {
                        ghost.physicsBody?.velocity.dx += 0.05
                    }
                    
                }
                if(isMagnetic == true) {
                    turnOnMagEffect()
                }
                

                if alreadyContacted == false {
                    self.score += 1
                    PlayerScore.numberOfCoinsCollected += 1
                    scoreLabel.text = "\(score)"

                    secondBody.node?.removeFromParent()
                    playSound.play()
                    if(score > highScore) {
                    
                        highScore = score
                    
                    }
                
                    let highScoreDefult = UserDefaults.standard
                    highScoreDefult.set(highScore, forKey: "HighScore")
                    highScoreDefult.synchronize()
                
                    let getCoinsCollected = UserDefaults.standard
                    getCoinsCollected.set(PlayerScore.numberOfCoinsCollected, forKey: "numberOfCoinsCollected")
                    getCoinsCollected.synchronize()
                }
                alreadyContacted = true

            }
                
            else if(firstBody.categoryBitMask == PhysicsStruct.ghost && secondBody.categoryBitMask == PhysicsStruct.wall || firstBody.categoryBitMask == PhysicsStruct.wall && secondBody.categoryBitMask == PhysicsStruct.ghost) {
                enumerateChildNodes(withName: "wallPair", using: ( {
                    
                    (node, error) in
                    node.speed = 0
                    self.removeAllActions()
                    self.collisionSound.play()
                }))
                
                if(died == false) {
                    
                    died = true
                    ghost.removeAllActions()
                    ghost = SKSpriteNode(imageNamed: "idle_1")
                    createButtonandLabels()
                    
                }
            }
            
            else if(firstBody.isEqual(ghost.physicsBody) && secondBody.isEqual(self.physicsBody) || firstBody.isEqual(self.physicsBody) && secondBody.isEqual(ghost.physicsBody)) {
                
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
        
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        
        if died == false {

            if alreadyContacted == true {
                alreadyContacted = false
            }
        }
    }
    
    @objc func performAction(gesture: UIPanGestureRecognizer) {
        
        var duration: TimeInterval = 0.0
        let maxValueForDuration = 0.42

        switch gesture.state {
        case .began:
            LongTouchTime.pressedStartTime = NSDate.timeIntervalSinceReferenceDate
        case .ended:
            duration = NSDate.timeIntervalSinceReferenceDate - LongTouchTime.pressedStartTime
            if duration > maxValueForDuration {
                duration = maxValueForDuration
            }
            projectileMotion(duration: CGFloat(duration))
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
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if died == false {
            ghost.physicsBody?.velocity.dx *= 0.6
            ghost.physicsBody?.velocity.dy *= 0.6
        }
        //If restartButton is clicked
        for touch in touches {
            
            let location = touch.location(in: self)
            if(died == true) {
                
                if(restartButton.contains(location)) {
                    
                    restartScene()
                    
                }
                else if(shareScoreBtn.contains(location)) {
                    
                    //Call appropriate function
                    (self.view!.window!.rootViewController as! GameViewController).shareScore(highScore: highScore)
                    
                    
                }
                
            }
            
        }
        
        
        //If upgradeButton is clicked
        for touch in touches {
            
            let location = touch.location(in: self)
            if(died == true) {
                
                if(upgradeButton.contains(location)) {
                    
                    //load the new scene
                    let upgradeSceneload = GameScene(fileNamed: "UpgradesScene")
                    self.scene?.view?.presentScene(upgradeSceneload!, transition: SKTransition.crossFade(withDuration: 0.5))
                    
                }
                
            }
            
            //Decrement the number of power ups
            if(shieldPwrUp.contains(location)) {
                
                if(died == false) {
                    
                    if(powerUpClicked.shieldCount > 0) {
                        
                        powerUpClicked.shieldCount -= 1
                        
                        let shieldPowerUpsSaved  = UserDefaults.standard
                        shieldPowerUpsSaved.set(powerUpClicked.shieldCount, forKey: "NumberOfShieldCountBought")
                        shieldPowerUpsSaved.synchronize()
                        updateDisplayForPowerUps()
                        isDeactivated = true
                        shieldTimer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(resetPhysics), userInfo: nil, repeats: false)
                        
                    }
                    
                }
                
            }
                
            else if(magnetPowerUp.contains(location)) {
                
                if(died == false) {
                    
                    if(powerUpClicked.magnetCount > 0 && !isMagnetic) {
                        
                        powerUpClicked.magnetCount -= 1
                        let magPowerUpsSaved  = UserDefaults.standard
                        magPowerUpsSaved.set(powerUpClicked.magnetCount, forKey: "NumberOfMagnetsCountBought")
                        magPowerUpsSaved.synchronize()
                        updateDisplayForPowerUps()
                        //Impliment the magnetic effect
                        isMagnetic = true
                        magTimer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(turnOfMagEffect), userInfo: nil, repeats: false)
                        
                    }
                }
            }
        }
        
    }
    
    @objc func resetPhysics() {
        
        //Reset Physics
        isDeactivated = false
        
    }
    
    @objc func turnOfMagEffect() {
        
        isMagnetic = false
        
    }
    
    func turnOnMagEffect() {
        
        tempGravity.isEnabled = true
    }
    
    func updateDisplayForPowerUps() {
        
        numberOfShieldsLabel.text = "\(powerUpClicked.shieldCount)"
        numberOfMagnetsLabel.text = "\(powerUpClicked.magnetCount)"
        
    }
    
    @objc func resetPosition() {
        
        if (ghost.position.x  < 77) {
            ghost.physicsBody?.applyImpulse(CGVector(dx: 20, dy: 0))
        }
        else {
            self.ghost.physicsBody?.applyImpulse((CGVector(dx: -50, dy: 0)))
            }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        // Called before each frame is rendered
        if(hasGameStarted.gameStarted == true) {
            
            if(died == false) {
                
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
            
            if(isMagnetic == true) {
                
                turnOnMagEffect()
            }
            
          }
        
          if(died == true) {
            
            //Cancel the ongoing timers
            if(shieldTimer.isValid) {
                
                shieldTimer.invalidate()
                
            } else if(magTimer.isValid) {
                
                scoreNode.removeFromParent()
                magTimer.invalidate()
                
            }
            
        }
        
        if(isMagnetic && died == false) {
 
            tempGravity.position.x = ghost.position.x
            tempGravity.position.y = ghost.position.y
            
        }
        
        if(hasGameStarted.gameStarted && isDeactivated) {
            
            topWall.physicsBody = nil
            bottomWall.physicsBody = nil
            
        }
            
        else if(hasGameStarted.gameStarted && !isDeactivated) {
            
            topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
            topWall.physicsBody?.categoryBitMask = PhysicsStruct.wall
            topWall.physicsBody?.collisionBitMask = PhysicsStruct.ghost
            topWall.physicsBody?.contactTestBitMask = PhysicsStruct.ghost
            topWall.physicsBody?.isDynamic = false
            topWall.physicsBody?.affectedByGravity = false
            
            bottomWall.physicsBody = SKPhysicsBody(rectangleOf: bottomWall.size)
            bottomWall.physicsBody?.categoryBitMask = PhysicsStruct.wall
            bottomWall.physicsBody?.collisionBitMask = PhysicsStruct.ghost
            bottomWall.physicsBody?.contactTestBitMask = PhysicsStruct.ghost
            bottomWall.physicsBody?.isDynamic = false
            bottomWall.physicsBody?.affectedByGravity = false
            
        }
        
    }
    
     func createWalls() {
     
     scoreNode = SKSpriteNode(imageNamed: "star_coin")
     scoreNode.size = CGSize(width: 50, height: 50)
     scoreNode.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2)
     scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
     
     
     if(isMagnetic && hasGameStarted.gameStarted && died == false) {
     
     scoreNode.physicsBody?.isDynamic = true
     
     } else {
     
     scoreNode.physicsBody?.isDynamic = false
     
     }
     
     scoreNode.physicsBody?.categoryBitMask = PhysicsStruct.Score
     scoreNode.physicsBody?.collisionBitMask = 0
     scoreNode.physicsBody?.contactTestBitMask = PhysicsStruct.ghost
     scoreNode.physicsBody?.fieldBitMask = PhysicsStruct.temp_grav
     scoreNode.name = "coinObject"
     scoreNode.physicsBody?.affectedByGravity = false
     
     wallPair = SKNode()
     wallPair.name = "wallPair"
     topWall = SKSpriteNode(imageNamed: "Wall")
     bottomWall = SKSpriteNode(imageNamed: "Wall")
     topWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 + 350)
     
     if(!isDeactivated) {
     
     topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
     topWall.physicsBody?.categoryBitMask = PhysicsStruct.wall
     topWall.physicsBody?.collisionBitMask = PhysicsStruct.ghost
     topWall.physicsBody?.contactTestBitMask = PhysicsStruct.ghost
     topWall.physicsBody?.isDynamic = false
     topWall.physicsBody?.affectedByGravity = false
     
     }
     
     bottomWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 - 350)
     
     if(!isDeactivated) {
     
     bottomWall.physicsBody = SKPhysicsBody(rectangleOf: bottomWall.size)
     bottomWall.physicsBody?.categoryBitMask = PhysicsStruct.wall
     bottomWall.physicsBody?.collisionBitMask = PhysicsStruct.ghost
     bottomWall.physicsBody?.contactTestBitMask = PhysicsStruct.ghost
     bottomWall.physicsBody?.isDynamic = false
     bottomWall.physicsBody?.affectedByGravity = false
     
     }
     
     topWall.setScale(0.5)
     bottomWall.setScale(0.5)
     topWall.zRotation = CGFloat(Double.pi)
     wallPair.addChild(topWall)
     wallPair.addChild(bottomWall)
     wallPair.zPosition = 1
     let randomPosition = CGFloat(arc4random_uniform(300)) - 150
     wallPair.position.y = wallPair.position.y + randomPosition
     wallPair.addChild(scoreNode)
     wallPair.run(moveAndRemove)
     self.addChild(wallPair)
     
     }
    
    
}

