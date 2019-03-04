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

}
