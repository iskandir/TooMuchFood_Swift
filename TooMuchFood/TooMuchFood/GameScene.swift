//
//  GameScene.swift
//  TooMuchFood
//
//  Created by Dennis Hasselbusch on 26.07.20.
//  Copyright © 2020 Iskandir. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    //physics categories
    struct PhysicsCategory {
        static let none : UInt32 = 0
        static let all : UInt32 = UInt32.max
        static let poo : UInt32 = 0b1
        static let player : UInt32 = 0b10
        static let burger : UInt32 = 0b100
        static let fries : UInt32 = 0b101
    }
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var player = SKSpriteNode(imageNamed: "right")
    
    private var foodCounter = 0
    private var pooCounter = 1
    
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
        //Background image
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(background)
        //SKALIEREN DES HINTERGRUNDS!!
        background.scale(to: SKSceneScaleMode.fill)
        
        //Player creation and physics
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.1)
        addChild(player)
        player.scale(to: CGSize(width: 100, height: 100))
        //world has no gravity
        physicsWorld.gravity = .zero
        //notification when two physics bodies collide
        physicsWorld.contactDelegate = self
        
        //run addPoo func to create poos
        run(SKAction.repeatForever(
          SKAction.sequence([
            SKAction.run(addPoo),
            SKAction.wait(forDuration: 1.0)
            ])
        ))
        
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
        poo.scale(to: CGSize(width: 60,height: 60))
        
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
        player.physicsBody?.collisionBitMask = PhysicsCategory.none
        player.physicsBody?.usesPreciseCollisionDetection = true
    }
     
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
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
    
    func playerDidCollideWithPoo(player: SKSpriteNode, poo: SKSpriteNode){
        print("Poo Counter \(pooCounter)")
        pooCounter+=1
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
        
        if ((firstBody.categoryBitMask & PhysicsCategory.poo != 0) && (secondBody.categoryBitMask & PhysicsCategory.player != 0)) {
            if let poo = firstBody.node as? SKSpriteNode, let player = secondBody.node as? SKSpriteNode {
                playerDidCollideWithPoo(player: player, poo: poo)
            }
        }
        
    }
    
    
}
