//
//  Enemy.swift
//  PacktARKitSceneKit
//
//  Created by Ken Maready on 9/27/22.
//

import SceneKit

class Enemy: SCNNode {
    var _currentScene: SCNScene!
    var spawnPos: SCNVector3!
    var score: Int = 0
    
    init(_ currentScene: SCNScene, _ spawnPosition: SCNVector3) {
        super.init()
        self._currentScene = currentScene
        self.spawnPos = SCNVector3(spawnPosition.x + 0.8, spawnPosition.y + 2.0/100, spawnPosition.z)
        
        let geo = SCNBox(width: 4.0/100, height: 4.0/100, length: 4.0/100, chamferRadius: 0.0)
        geo.firstMaterial?.diffuse.contents = UIColor.yellow
        self.geometry = geo
        
        self.position = spawnPos
        self.name = "enemy"
        
        self.physicsBody = SCNPhysicsBody.kinematic()
        self.physicsBody?.categoryBitMask = PhysicsCategory.enemy.rawValue
        self.physicsBody?.contactTestBitMask = PhysicsCategory.hero.rawValue
        
        currentScene.rootNode.addChildNode(self)
    }
    
    required init?(coder: NSCoder) { fatalError("init?(coder:) has not been implemented for Enemy class.") }
    
    func update() {
        self.position.x += -0.9/100
        if (self.position.x - 5.0/100) < -60.0/100 {
            let factor = arc4random_uniform(2) + 1
            
            if factor == 1 {
                self.position = spawnPos
            } else {
                self.position = SCNVector3Make(spawnPos.x, spawnPos.y + 0.1, spawnPos.z)
            }
            
            score += 1
        }
    }
    
    func reset() {
        self.position = spawnPos
        self.score = 0
    }
}
