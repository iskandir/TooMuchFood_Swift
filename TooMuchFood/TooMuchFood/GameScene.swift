//
//  GameScene.swift
//  TooMuchFood
//
//  Created by Dennis Hasselbusch on 26.07.20.
//  Copyright © 2020 Iskandir. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreGraphics

class GameScene: SKScene {
    private let background = SKSpriteNode(imageNamed: "background")
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var player = SKSpriteNode(imageNamed: "right")
    private var foodCounter : Int = 1
    private var pooCounter :Int = 1
    private var highscore : Int = 0
    let scoreLabel = SKLabelNode(fontNamed: "CoolFont")
    
    //physics categories
    struct PhysicsCategory {
            static let none : UInt32 = 0
            static let all : UInt32 = UInt32.max
            static let player : UInt32 = 0b10
            static let poo : UInt32 = 0b1
            static let burger : UInt32 = 0b100
            static let fries : UInt32 = 0b101
    }
    
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        
    }
    override func didMove(to view: SKView) {
        //Background image and scaling
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(background)
        background.zPosition = 0
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        self.background.size = CGSize(width: self.size.width, height: self.size.height)
        
        //Player creation and physics
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.1)
        addChild(player)
        player.scale(to: CGSize(width: 100, height: 100))
        player.zPosition = 1
        
        //world has no gravity
        physicsWorld.gravity = .zero
        //notification when two physics bodies collide
        physicsWorld.contactDelegate = self
        
        scoreLabel.text = "Highscore:  \(highscore)"
        scoreLabel.fontSize = 30
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height / 1.1)
        scoreLabel.zPosition = 2
        scoreLabel.horizontalAlignmentMode = .center
        addChild(scoreLabel)
        
        let myDoublePoo = random(min: 1.0, max: 3.0)
        let myDoubleFries = random(min: 1.0, max: 3.0)
        //run addPoo func to create poos
        run(SKAction.repeatForever(
          SKAction.sequence([
            SKAction.run(addPoo),
            SKAction.wait(forDuration: TimeInterval(myDoublePoo))
            ]))
        )
        run(SKAction.repeatForever(
          SKAction.sequence([
            SKAction.run(addFries),
            SKAction.wait(forDuration: TimeInterval(myDoubleFries))
            ]))
        )
        //background music
        /*
         let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
         backgroundMusic.autoplayLooped = true
         addChild(backgroundMusic)
         */
    }
    func random() -> CGFloat {
      return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
      return random() * (max - min) + min
    }
    func addPoo() {
        let poo = SKSpriteNode(imageNamed: "poo")
        poo.name = "poo"
        poo.scale(to: CGSize(width: 40,height: 40))
        poo.physicsBody = SKPhysicsBody(rectangleOf: poo.size)
        poo.physicsBody?.isDynamic = true
        poo.physicsBody?.categoryBitMask = PhysicsCategory.poo
        poo.physicsBody?.contactTestBitMask = PhysicsCategory.player
        poo.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min: poo.size.height/2, max: size.height - poo.size.height/2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        poo.position = CGPoint(x: size.width + poo.size.width/2, y: actualY)
        
        // Add the monster to the scene
        addChild(poo)
        poo.zPosition = 1
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        // Create the actions
        let actionMove = SKAction.move(to: CGPoint(x: -poo.size.width/2, y: actualY),
                                       duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
//        gameoverscreen!!!
//        let loseAction = SKAction.run() { [weak self] in
//          guard let `self` = self else { return }
//          let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
//          let gameOverScene = GameOverScene(size: self.size, won: false)
//          self.view?.presentScene(gameOverScene, transition: reveal)
//        }
        poo.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    func addFries()
    {
        let fries = SKSpriteNode(imageNamed: "fries")
        
        //for better information add a name
        fries.name = "fries"
        fries.scale(to: CGSize(width: 40,height: 40))
        fries.physicsBody = SKPhysicsBody(rectangleOf: fries.size)
        fries.physicsBody?.isDynamic = true
        fries.physicsBody?.categoryBitMask = PhysicsCategory.poo
        fries.physicsBody?.contactTestBitMask = PhysicsCategory.player
        fries.physicsBody?.collisionBitMask = PhysicsCategory.none
        let actualY = random(min: fries.size.height/2,  max:size.height - fries.size.height/2)
        fries.position = CGPoint(x: size.width + fries.size.width/2, y: actualY)
        addChild(fries)
        fries.zPosition = 1
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        let actionMove = SKAction.move(to: CGPoint(x: -fries.size.width/2, y: actualY), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        fries.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            player.position.x = location.x
            player.position.y = location.y
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.poo
        player.physicsBody?.contactTestBitMask = PhysicsCategory.fries
        
        player.physicsBody?.collisionBitMask = PhysicsCategory.none
        player.physicsBody?.usesPreciseCollisionDetection = true
    }
    override func update(_ currentTime: TimeInterval) {
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        self.lastUpdateTime = currentTime
    }
    //Spieler vs POO
    func playerDidCollideWithPoo(player: SKSpriteNode, poo: SKSpriteNode){
        if poo.name == "poo"
        {
            print("pooooooo!")
            print("Poo Counter \(pooCounter)")
            self.pooCounter-=1
            self.highscore-=1
            scoreLabel.text = "Highscore is: \(highscore)"
            poo.removeFromParent()
        }
    }
    //Spieler vs FOOD
    func playerDidCollideWithFood(player: SKSpriteNode, fries: SKSpriteNode){
        if fries.name == "fries"
        {
            print("FRIIIIES!")
            print("Food Counter \(foodCounter)")
            self.foodCounter+=1
            self.highscore+=1
            fries.removeFromParent()
            scoreLabel.text = "Highscore is: \(highscore)"
        }
    }
}


extension GameScene : SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        //Collide with poo, call function playerDidCollideWithPoo
       if ((firstBody.categoryBitMask & PhysicsCategory.poo != 0) && (secondBody.categoryBitMask & PhysicsCategory.player != 0)) {
            if let poo = firstBody.node as? SKSpriteNode, let player = secondBody.node as? SKSpriteNode {
                playerDidCollideWithPoo(player: player, poo: poo)
            }
        }
        //Collide with food, call function playerDidCollideWithFood
        if((firstBody.categoryBitMask & PhysicsCategory.fries != 0) && (secondBody.categoryBitMask & PhysicsCategory.player != 0))
        {
            if let fries = firstBody.node as? SKSpriteNode, let player = secondBody.node as? SKSpriteNode
            {
                playerDidCollideWithFood(player: player, fries: fries)
            }
        }
        
    }
    
    
}
