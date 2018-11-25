//
//  ViewController.swift
//  SceneKitWorkshop
//
//  Created by Jurian de Cocq van Delwijnen on 21/10/2018.
//  Copyright © 2018 Sogeti. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

//----- Assignment 1; setup a plane that we can actually work with
class Plane: SCNNode {
    let plane: SCNBox
    let planeNode: SCNNode
    let planeHeight: Float = 0.1 // All SceneKit measurements are in meters, 0.1 is thus 10 centimeters
    
    override init() {
        plane = SCNBox(width: 1, height: CGFloat(planeHeight), length: 1, chamferRadius: 0)
        planeNode = SCNNode(geometry: plane)
        super.init()
        addChildNode(planeNode)
        show(true)
    }
    
    func show(_ visible: Bool) {
        var materials = Array(repeating: SCNNode.material(for: UIColor.clear), count: 6) // 6 sides on the box
        if visible {
            let color = UIColor.green.withAlphaComponent(0.7)
            materials[4] = SCNNode.material(for: color)
        }
        plane.materials = materials
    }
    
    func update(for anchor: ARPlaneAnchor) {
        plane.width = CGFloat(anchor.extent.x)
        plane.length = CGFloat(anchor.extent.z)
        let shape = SCNPhysicsShape(geometry: plane, options: nil)
        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: shape)
        planeNode.position = SCNVector3(x: anchor.center.x, y: -planeHeight/2, z: anchor.center.z)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SCNNode {
    class func material(for contents: Any) -> SCNMaterial {
        let m = SCNMaterial()
        m.diffuse.contents = contents
        m.lightingModel = .physicallyBased
        
        return m
    }
}
//-----------------------------------------------------------


//----- Assignment 2; Let's add some balls to our pool table

class Sphere: SCNNode {
    let sphere: SCNSphere
    let radius: Float = 0.025
    
    override init() {
        self.sphere = SCNSphere(radius: CGFloat(radius))
//        sphere.materials = [SCNNode.material(for: UIColor.red)]
        
        //----- Assignment 4; different kind of pools balls and cleaning up
        sphere.materials = [SCNNode.material(for: sharedImageIterator.next()!)]
        //-----------------------------------------------------------
        
        super.init()
        self.geometry = sphere
        let shape = SCNPhysicsShape(geometry: sphere, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func position(at transform: matrix_float4x4) {
        position = SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }
}

//-----------------------------------------------------------

extension ViewController {

    //----- Assignment 2; Let's add some balls to our pool table
//    @objc func didTapView(sender: UITapGestureRecognizer) {
//        let location = sender.location(in: sender.view)
//        if let result = sceneView.hitTest(location, types: .existingPlane).first {
//            let sphere = Sphere()
//            sphere.position(at: result.worldTransform)
//            sphere.position.y += sphere.radius
//            sceneView.scene.rootNode.addChildNode(sphere)
//        }
//    }
    //-----------------------------------------------------------
    
    
    //----- Assignment 3; Let's see if we can shoot our pool balls
    
    @objc func didTapView(sender: UITapGestureRecognizer) {
        let location = sender.location(in: sender.view)
        
        if let result = sceneView.hitTest(location, options: [:]).first, let sphere = result.node as? Sphere {
            // LocalNormal is the angle the ball is tapped and force going outwards
            let force = result.localNormal.inverse().multiply(factor: 2)
            sphere.physicsBody?.applyForce(force, asImpulse: true)
        }
        else if let result = sceneView.hitTest(location, types: .existingPlane).first {
            let sphere = Sphere()
            sphere.position(at: result.worldTransform)
            sphere.position.y += sphere.radius
            sceneView.scene.rootNode.addChildNode(sphere)
        }
    }
    
    //-----------------------------------------------------------

    
    //----- Assignment 1; setup a plane that we can actually work with
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor {
            let plane = Plane()
            plane.update(for: planeAnchor)
            planes[planeAnchor] = plane
            node.addChildNode(plane)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor, let plane = planes[planeAnchor] {
            plane.update(for: planeAnchor)
        }
    }
    //-----------------------------------------------------------
}

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var planes: [ARPlaneAnchor: Plane] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        sceneView.delegate = self
        
        //----- Assignment 4; different kind of pools balls and cleaning up
//        sceneView.debugOptions = [.showPhysicsShapes]
        //-----------------------------------------------------------

        //        sceneView.debugOptions = [.showPhysicsShapes]
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        
        sceneView.scene = SCNScene()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTapView))
        sceneView.addGestureRecognizer(gesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = ARWorldTrackingConfiguration.PlaneDetection.horizontal
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
}
