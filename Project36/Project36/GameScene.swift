//
//  GameScene.swift
//  Project36
//
//  Created by Paul on 04.03.2019.
//  Copyright © 2019 Paul. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var player: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        createPlayer()
        createSky()
        createBackground()
        createGround()
        startRocks()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    private func createPlayer() {
        let playerTexture = SKTexture(imageNamed: "player-1")
        player = SKSpriteNode(texture: playerTexture)
        player.zPosition = 10
        // player.position = CGPoint(x: frame.width/6, y: frame.height * 0.75) // TODO: change frame.width to bounds width
        player.position = CGPoint(x: size.width/6, y: size.height * 0.75)
        print("frame.width: \(frame.width), frame.height: \(frame.height)")
        print("size.width: \(size.width), size.height: \(size.height)")
        
        addChild(player)
        
        let frame2 = SKTexture(imageNamed: "player-2")
        let frame3 = SKTexture(imageNamed: "player-3")
        let animation = SKAction.animate(with: [playerTexture, frame2, frame3, frame2], timePerFrame: 0.01)
        
        let runForever = SKAction.repeatForever(animation)
        
        player.run(runForever)
    }
    
    private func createSky() {
        let topSky = SKSpriteNode(color: UIColor(hue: 0.55, saturation: 0.14, brightness: 0.97, alpha: 1), size: CGSize(width: size.width, height: size.height * 0.67))
        topSky.anchorPoint = CGPoint(x: 0.5, y: 1)
        
        let bottomSky = SKSpriteNode(color: UIColor(hue: 0.55, saturation: 0.16, brightness: 0.96, alpha: 1), size: CGSize(width: size.width, height: size.height * 0.33))
        bottomSky.anchorPoint = CGPoint(x: 0.5, y: 1)
        
        topSky.position = CGPoint(x: frame.midX, y: frame.height) // TODO: chahge frame
        bottomSky.position = CGPoint(x: frame.midX, y: bottomSky.frame.height)
        
        addChild(topSky)
        addChild(bottomSky)
        
        bottomSky.zPosition = -40
        topSky.zPosition = -40
    }
    
    private func createBackground() {
        let backgroundTexture = SKTexture(imageNamed: "background")
        
        for i in 0 ... 1 {
            let background = SKSpriteNode(texture: backgroundTexture)
            background.zPosition = -30
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: (backgroundTexture.size().width * CGFloat(i)) - CGFloat(1*i), y: 100)
            addChild(background)
            let moveLeft = SKAction.moveBy(x: -backgroundTexture.size().width, y: 0, duration: 20)
            let moveReset = SKAction.moveBy(x: backgroundTexture.size().width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft,moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            
            background.run(moveForever)
        }
    }
    
    private func createGround() {
        let groundTexture = SKTexture(imageNamed: "ground")
        
        for i in 0 ... 1 {
            let ground = SKSpriteNode(texture: groundTexture)
            ground.zPosition = -10
            // ground.position = CGPoint(x: (groundTexture.size().width / 2 + groundTexture.size().width * CGFloat(i)), y: groundTexture.size().height / 2 )
            ground.position = CGPoint(x: groundTexture.size().width * (CGFloat(0.5) + CGFloat(i)), y: groundTexture.size().height / 2 )
            addChild(ground)
            
            let moveLeft = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5)
            let moveReset = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            ground.run(moveForever)
        }
    }
    
    private func createRocks() {
        // 1
        let rockTexture = SKTexture(imageNamed: "rock")
        let topRock = SKSpriteNode(texture: rockTexture)
        topRock.zRotation = .pi
        topRock.xScale = -1.0
        
        let bottomRock = SKSpriteNode(texture: rockTexture)
        topRock.zPosition = -20
        bottomRock.zPosition = -20
        // 2
        let rockCollision = SKSpriteNode(color: UIColor.red, size: CGSize(width: 32, height: size.height)) //was frame.hight
        rockCollision.name = "scoreDetect"
        
        addChild(topRock)
        addChild(bottomRock)
        addChild(rockCollision)
        
        //3
        let xPosition = size.width + topRock.frame.width // was frame.width
        let max = CGFloat(size.height / 3)
        let yPosition = CGFloat.random(in: -50.0...max)
        // this next value affects the width of the gap between rocks
        let rockDistance = CGFloat(70)
        //4
        topRock.position = CGPoint(x: xPosition, y: yPosition + topRock.size.height + rockDistance) //was topRock.frame.height
        bottomRock.position = CGPoint(x: xPosition, y: yPosition - rockDistance)
        
        rockCollision.position = CGPoint(x: xPosition + rockCollision.frame.width * 2, y: size.height / 2)
        let endPosition = size.width + (topRock.frame.width * 2)
        let moveAction = SKAction.moveBy(x: -endPosition, y: 0, duration: 6.2)
        let moveSequence = SKAction.sequence([moveAction, SKAction.removeFromParent()])
        topRock.run(moveSequence)
        bottomRock.run(moveSequence)
        rockCollision.run(moveSequence)
    }
    
    private func startRocks() {
        let create = SKAction.run { [unowned self] in
            self.createRocks()
        }
        let wait = SKAction.wait(forDuration: 3)
        let sequence = SKAction.sequence([create, wait])
        let repeatForever = SKAction.repeatForever(sequence)
        
        run(repeatForever)
    }

}
