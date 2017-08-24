//
//  GameScene.swift
//  Hoppy Bunny
//
//  Created by Chenyang Zhang on 8/22/17.
//  Copyright © 2017 Chenyang Zhang. All rights reserved.
//

import SpriteKit

enum GameSceneState {
  case Active, GameOver
}

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  var hero: SKSpriteNode!

  var sinceTouch : TimeInterval = 0
  
  var spawnTimer: TimeInterval = 0

  
  let fixedDelta: TimeInterval = 1.0/60.0
  
  let scrollSpeed: CGFloat = 160
  
  var scrollLayer: SKNode!
  
  var obstacleLayer: SKNode!

  var buttonRestart: MSButtonNode!
  
  var scoreLabel: SKLabelNode!
  
  var points = 0
  
  var gameState: GameSceneState = .Active


  
  override func didMove(to view: SKView) {
    
    hero = self.childNode(withName: "//hero") as! SKSpriteNode
    scrollLayer = self.childNode(withName: "scrollLayer")
    obstacleLayer = self.childNode(withName: "obstacleLayer")
    buttonRestart = self.childNode(withName: "buttonRestart") as! MSButtonNode
    scoreLabel = self.childNode(withName: "scoreLabel") as! SKLabelNode
    
    
    buttonRestart.selectedHandler = { [unowned self] in
      
      
      let skView = self.view as SKView!
      
      
      let scene = GameScene(fileNamed:"GameScene") as GameScene!
      
      
      scene?.scaleMode = .aspectFill
      
      
      skView?.presentScene(scene)
      
    }
    
    
    buttonRestart.state = .hidden
    
    physicsWorld.contactDelegate = self
    
    scoreLabel.text = String(points)





  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    hero.physicsBody?.velocity = CGVector(dx: 0, dy: 0)

    
    hero.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 250))
    
    
    hero.physicsBody?.applyAngularImpulse(1)
    
    
    sinceTouch = 0
    
    

    
    let flapSFX = SKAction.playSoundFileNamed("sfx_flap", waitForCompletion: false)
    self.run(flapSFX)

  }
  
  override func update(_ currentTime: TimeInterval) {
    
    if gameState != .Active { return }
    
  
    let velocityY = hero.physicsBody?.velocity.dy ?? 0
    
    if velocityY > 400 {
      hero.physicsBody?.velocity.dy = 400

    }
    
    if sinceTouch > 0.1 {
      let impulse = -20000 * fixedDelta
      hero.physicsBody?.applyAngularImpulse(CGFloat(impulse))
    }
    
    hero.zRotation = hero.zRotation.clamped(CGFloat(-20).degreesToRadians(), CGFloat(30).degreesToRadians())
    hero.physicsBody!.angularVelocity = hero.physicsBody!.angularVelocity.clamped(-2, 2)
    
    sinceTouch+=fixedDelta
    
    scrollWorld()
    updateObstacles()
    spawnTimer += fixedDelta

  }
  
  func scrollWorld() {
    
    scrollLayer.position.x -= scrollSpeed * CGFloat(fixedDelta)
    
    
    for ground in scrollLayer.children as! [SKSpriteNode] {
      
      
      let groundPosition = scrollLayer.convert(ground.position, to: self)
      
      
      if groundPosition.x <= -ground.size.width / 2 {
        
        
        let newPosition = CGPoint( x: (self.size.width / 2) + ground.size.width, y: groundPosition.y)
        
        
        ground.position = self.convert(newPosition, to: scrollLayer)
      }
    }

  }
  
  func updateObstacles() {
    
    
    obstacleLayer.position.x -= scrollSpeed * CGFloat(fixedDelta)
    
    
    for obstacle in obstacleLayer.children as! [SKReferenceNode] {
      
      
      let obstaclePosition = obstacleLayer.convert(obstacle.position, to: self)
      
      
      if obstaclePosition.x <= 0 {
        
        
        obstacle.removeFromParent()
      }
      
    }
    
    if spawnTimer >= 1.5 {
      
      
      let resourcePath = Bundle.main.path(forResource: "Obstacle", ofType: "sks")
      let newObstacle = SKReferenceNode(url: URL(fileURLWithPath: resourcePath!))
      obstacleLayer.addChild(newObstacle)
      
      
      let randomPosition = CGPoint(x: 352, y: CGFloat.random(min: 234, max: 382))
      
      
      newObstacle.position = self.convert(randomPosition, to: obstacleLayer)
      
      
      spawnTimer = 0
    }
    
    
  }
  
  func didBegin(_ contact: SKPhysicsContact) {
    
    if gameState != .Active { return }
    
    let contactA:SKPhysicsBody = contact.bodyA
    let contactB:SKPhysicsBody = contact.bodyB
  
    let nodeA = contactA.node!
    let nodeB = contactB.node!
    
    if nodeA.name == "goal" || nodeB.name == "goal" {
      points += 1
      scoreLabel.text = String(points)
      return
    }

    gameState = .GameOver
    
    hero.physicsBody?.allowsRotation = false
    hero.physicsBody?.angularVelocity = 0
    hero.removeAllActions()
  
    let heroDeath = SKAction.run({
      
      self.hero.zRotation = CGFloat(-90).degreesToRadians()
      self.hero.physicsBody?.collisionBitMask = 0
    })
    
    hero.run(heroDeath)
  
    let shakeScene:SKAction = SKAction.init(named: "Shake")!
    for node in self.children {
      
      node.run(shakeScene)
    }
    
    buttonRestart.state = .active
  }

  
}
 
