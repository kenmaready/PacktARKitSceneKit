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
        
        
    }
}
