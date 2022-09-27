//
//  Hero.swift
//  PacktARKitSceneKit
//
//  Created by Ken Maready on 9/27/22.
//

import SceneKit
import ARKit

class Hero: SCNNode {
    var isGrounded = false
    var monsterNode = SCNNode()
    var jumpPlayer = SCNAnimationPlayer()
    var runPlayer = SCNAnimationPlayer()
    
    static func time(atFrame frame: Int, fps: Double = 30) -> TimeInterval {
        return TimeInterval(frame) / fps
    }
    
    static func timeRange(startFrame start: Int, endFrame end: Int, fps: Double = 30) -> (offset: TimeInterval, duration: TimeInterval) {
        let startTime = self.time(atFrame: start, fps: fps)
        let endTime = self.time(atFrame: end, fps: fps)
        return (offset: startTime, duration: endTime - startTime)
    }
    
    static func animation(from full: CAAnimation, startFrame start: Int, endFrame end: Int, fps: Double = 30) -> CAAnimation {
        let range = self.timeRange(startFrame: start, endFrame: end, fps: fps)
        let animation = CAAnimationGroup()
        let sub = full.copy() as! CAAnimation
        
        sub.timeOffset = range.offset
        animation.animations = [sub]
        animation.duration = range.duration
        return animation
    }

    required init?(coder: NSCoder) { fatalError("init?(coder:) has not been implemented.") }
    
    init(_ currentScene: SCNScene, _ spawnPosition: SCNVector3) {
        super.init()
        let monsterScene: SCNScene = SCNScene(named: "art.scnassets/theDude.DAE")!
        monsterNode = monsterScene.rootNode.childNode(withName: "CATRigHub001", recursively: false)!
        self.addChildNode(monsterNode)
        
        let (minVec, maxVec) = self.boundingBox
        let bound = SCNVector3(x: maxVec.x - minVec.x, y: maxVec.y - minVec.y, z: maxVec.z - minVec.z)
        monsterNode.pivot = SCNMatrix4MakeTranslation(bound.x * 1.1, 0, 0)
        
        let animKeys = monsterNode.animationKeys.first
        let animPlayer = monsterNode.animationPlayer(forKey: animKeys!)
        let anims = CAAnimation(scnAnimation: (animPlayer?.animation)!)
        
        let runAnimation = Hero.animation(from: anims, startFrame: 31, endFrame: 50)
        runAnimation.repeatCount = .greatestFiniteMagnitude
        runAnimation.fadeInDuration = 0.0
        runAnimation.fadeOutDuration = 0.0
        runPlayer = SCNAnimationPlayer(animation: SCNAnimation(caAnimation: runAnimation))
        monsterNode.addAnimationPlayer(runPlayer, forKey: "run")
        
        let jumpAnimation = Hero.animation(from: anims, startFrame: 81, endFrame: 100)
        jumpAnimation.repeatCount = .greatestFiniteMagnitude
        jumpAnimation.fadeInDuration = 0.0
        jumpAnimation.fadeOutDuration = 0.0
        jumpPlayer = SCNAnimationPlayer(animation: SCNAnimation(caAnimation: jumpAnimation))
        monsterNode.addAnimationPlayer(jumpPlayer, forKey: "jump")
        
        monsterNode.removeAllAnimations()

        monsterNode.animationPlayer(forKey: "run")?.play()

        let collisionBox = SCNBox(width: 2/100.0, height: 8/100.0, length: 2/100.0, chamferRadius: 0.0)
        collisionBox.firstMaterial?.diffuse.contents = UIColor.orange
        
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: collisionBox, options: nil))
        self.physicsBody?.categoryBitMask = PhysicsCategory.hero.rawValue
        self.physicsBody?.collisionBitMask = PhysicsCategory.ground.rawValue
        self.physicsBody?.contactTestBitMask = PhysicsCategory.enemy.rawValue | PhysicsCategory.ground.rawValue
        
        self.physicsBody?.angularVelocityFactor = SCNVector3(0,0,0)
        self.physicsBody?.restitution = 0.0
        self.physicsBody?.mass = 20/100.0
        
        self.transform = SCNMatrix4MakeRotation(Float(Double.pi / 2), 0.0, 1.0, 0.0)
        
        self.scale = SCNVector3(0.1/100.0, 0.1/100.0, 0.1/100.0)
        self.name = "hero"
        
        self.position = SCNVector3(spawnPosition.x, spawnPosition.y + 0.25, spawnPosition.z)
        currentScene.rootNode.addChildNode(self)
    }
    
    func jump() {
        if (isGrounded == true) {
            self.physicsBody?.applyForce(SCNVector3Make(0,0.2,0), asImpulse: true)
            isGrounded = false
            playJumpAnim()
        }
    }
    
    func playRunAnim() {
        monsterNode.removeAllAnimations()
        monsterNode.addAnimationPlayer(runPlayer, forKey: "run")
        monsterNode.animationPlayer(forKey: "run")?.play()
    }
    
    func playJumpAnim() {
        monsterNode.removeAllAnimations()
        monsterNode.addAnimationPlayer(jumpPlayer, forKey: "jump")
        monsterNode.animationPlayer(forKey: "jump")?.play()
    }
}
