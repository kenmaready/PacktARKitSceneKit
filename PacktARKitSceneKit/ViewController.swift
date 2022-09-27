//
//  ViewController.swift
//  PacktARKitSceneKit
//
//  Created by Ken Maready on 9/26/22.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var plane: Plane!
    let planes: NSMutableDictionary! = [:]
    var configuration: ARWorldTrackingConfiguration! = nil
    var bPlaneAdded = false
    
    var bGameSetup = false
    var bGameOver = false
    var hero: Hero!
    var enemy: Enemy!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints, SCNDebugOptions.showPhysicsShapes]
        
        sceneView.scene.physicsWorld.gravity = SCNVector3Make(0, -500/100.0, 0)
        sceneView.scene.physicsWorld.contactDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if (!anchor .isKind(of: ARPlaneAnchor.self)) {
            return
        }
        
        plane = Plane(anchor as! ARPlaneAnchor)
        planes.setObject(plane, forKey: anchor.identifier as NSCopying)
        node.addChildNode(plane)
        
        bPlaneAdded = true
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        plane = planes.object(forKey: anchor.identifier) as! Plane
        
        if (plane == nil) { return }
        
        plane.update(anchor as! ARPlaneAnchor)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        planes.removeObject(forKey: anchor.identifier)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: sceneView)
        
        var hitTestOptions = [SCNHitTestOption: Any]()
        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
        
        let hitTestArray = sceneView.hitTest(location, types: [.estimatedHorizontalPlane, .existingPlane, .existingPlaneUsingExtent])
        
        for result in hitTestArray {
            if (!bGameSetup) {
                let spawnPos = SCNVector3(x: result.worldTransform.columns.3.x,
                                          y: result.worldTransform.columns.3.y,
                                          z: result.worldTransform.columns.3.z)
                if bPlaneAdded {
                    setupGame(spawnPos)
                    plane.isHidden = true
                    bGameSetup = true
                }
            } else {
                if (!bGameOver) {
                    hero.jump()
                }
            }
        }
    }
    
    func setupGame(_ spawnPos: SCNVector3) {
        configuration.planeDetection = ARWorldTrackingConfiguration.PlaneDetection(rawValue: 0)
        sceneView.session.run(configuration)
        
        // setting up lights
        let directionLight = SCNLight()
        directionLight.type = SCNLight.LightType.directional
        directionLight.castsShadow = true
        directionLight.shadowRadius = 200
        directionLight.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        directionLight.shadowMode = .deferred
        
        let directionLightNode = SCNNode()
        directionLightNode.light = directionLight
        directionLightNode.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2), 1.0, 0.0, 0.0)
        directionLightNode.position = SCNVector3(spawnPos.x + 0.2, spawnPos.y + 0.5, spawnPos.z + 0.0)
        
        sceneView.scene.rootNode.addChildNode(directionLightNode)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLight.LightType.ambient
        ambientLightNode.light!.color = UIColor.darkGray
        sceneView.scene.rootNode.addChildNode(ambientLightNode)
        
        // setting up ground
        let ground = SCNFloor()
        ground.firstMaterial?.diffuse.contents = UIColor.gray
        let groundNode = SCNNode(geometry: ground)
        groundNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: ground, options: nil))
        groundNode.position = SCNVector3(spawnPos.x + 0.2, spawnPos.y, spawnPos.z)
        
        groundNode.physicsBody?.categoryBitMask = PhysicsCategory.ground.rawValue
        groundNode.physicsBody?.collisionBitMask = PhysicsCategory.hero.rawValue
        groundNode.physicsBody?.contactTestBitMask = PhysicsCategory.hero.rawValue
        
        groundNode.physicsBody?.restitution = 0.0
        groundNode.name = "ground"
        groundNode.castsShadow = true
        
        sceneView.scene.rootNode.addChildNode(groundNode)
        
        hero = Hero(sceneView.scene, spawnPos)
        hero.castsShadow = true
        
        enemy = Enemy(sceneView.scene, spawnPos)
        enemy.castsShadow = true
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if (contact.nodeA.name == "hero" && contact.nodeB.name == "ground") || (contact.nodeA.name == "ground" && contact.nodeB.name == "hero") {
            if !hero.isGrounded {
                hero.isGrounded = true
                hero.playRunAnim()
            }
        }
        
        if (contact.nodeA.name == "hero" && contact.nodeB.name == "enemy") || (contact.nodeA.name == "enemy" && contact.nodeB.name == "hero") {
            bGameOver = true
            enemy.reset()
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if bGameSetup {
            if !bGameOver {
                enemy.update()
            }
        }
    }

    /*
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
     */

    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
