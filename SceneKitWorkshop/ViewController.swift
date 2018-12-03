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

// --------  Assignment 1  --------
//  In this assignment for SceneKit we're going to build the basics for our very own pool game
//  Let's start with creating a virtual table on a physical table in the real world
//  Don't worry, this is a long assignment but it's by far the largest chunk of the work
//
//  1. Let's start by extending the Plane class that's defined below.
//  First off let's define some let variables in it, we're going to need a SCNBox called plane
//      a SCNNode called planeNode and a Float called planeHeight.
//  All SceneKit measurements are in meters so let's set planeHeight to 0.1 to represent 10 centimeters
//
//  2. Now we're going to create a method called show which will take a Bool called visible so we can make our table visible
//  Add a var called materials and fill it with an Array of 6 items of type
//      SCNNode.material(for: and pass UIColor.clear to the SCNNode
//  If check visible and if it's true set materials[4] to an SCNNode with UIColor.green.withAlphaComponent(0.7)
//      The fifth element in the array here will represent the top of our box and thus the 'playalbe' part of our pool table.
//  Outside of the if statement set plane.materials to our newly created materials
//
//  3. Now let's implement the init method of our Plane
//  Start with setting plane to an SCNBox of width 1, height of CGFloat(planeHeight) lenght: 1 and chamferRadius: 0
//  Set planeNode to an SCNNode with geometry: plane, call super.init(), addChildNode(planeNode)
//  We've now created our virtual plane but can't see it yet, that's why we're going to call show(true)
//
//  4. We're able to make a visible pool table now but we don't have a way to position it in the physical world
//  That's what we're going to need the update method for
//  Set the plane.width to a CGFloat of anchor.extent.x
//  Set the plane.length to a CGFloat of anchor.extent.z
//  Define a let shape and fill it with a SCNPhysicsShape with geometry: plane, options: nil
//  Set the planeNode it's physicsBody to a SCNPhysicsBody with type: .static and shape: shape
//  Set the planeNode it's position to an SCNVector3 with x: anchor.center.x,
//      y will get an interesting position here since we're looking for the center of our shape to position it correctly
//      that means we'll need to fill it with -planeHeight/2
//      z will get anchor.center.z
//
//  5. Now we have a way to create a virtual pool table and we know how to position it, let's start rendering it
//  We're going to add some logic to the extension of our ViewController
//      since we want it to map our virtual table on a real world surface
//  Let's start by implementing the rendererDidAddNodeForAnchor method
//  Add an if let planeAnchor and check anchor as? ARPlaneAnchor
//  If that statements succeeds we know we've found a suitable surface for our table
//  Define a new let plane and fill it with a fresh Plane()
//  Call plane.update(for: planeAnchor) to position it to the place we've detected it
//  I've already prepared an object for you where you can store your plane
//      so you can simply call planes[planeAnchor] = plane
//  We're going to reuse these references later
//  Lastly add our plane as a child node to the detected node
//
//  If you run the app now you'll see a nice green box appearing on any viable surface
//  What we haven't taken into account yet is that we've now started rendering a 3d world
//  Which means that if you walk around the pooltable to take your shot the app might detect that the table is bigger
//
//  6. Let's make sure our virtual pooltable updates with any updates for our plane
//  Implement the renderer didUpdateNodeForAnchor method
//  Define an if let planeAnchor and check anchor as? ARPlanceAnchor
//  If that's true define a second check which is let plane = planes[planeAnchor]
//      this is where we retrieve our old plane references
//      if we actually have a plane let's call plane.update with our newly updated planeAnchor
//
//
//  Phew, this was a big chunk of work but most of the heavy lifting is done now.
//  With all this code in place you should be able to detect planes to which we'll map a green "play area"
//  As long as SceneKit is updating it's detected plane we'll update our playing field
//  In part 2 we're going to add some pool balls to our game!
// --------------------------------

class Plane: SCNNode {
    let plane: SCNBox
    let planeNode: SCNNode
    let planeHeight: Float = 0.1
    
    override init() {
        plane = SCNBox(width: 1, height: CGFloat(planeHeight), length: 1, chamferRadius: 0)
        planeNode = SCNNode(geometry: plane)
        super.init()
        addChildNode(planeNode)
        show(true)
    }
    
    func show(_ visible: Bool) {
        var materials = Array(repeating: SCNNode.material(for: UIColor.clear), count: 6)
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
        fatalError("Ignore this method. It's required but won't serve us now.")
    }
}

extension ViewController {
    
    @objc func didTapView(sender: UITapGestureRecognizer) {
        
    }
    
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
}

// Everything below this line is boilerplate, just some code to get SceneKit up and running

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    var planes: [ARPlaneAnchor: Plane] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.showsStatistics = true
        
        sceneView.delegate = self
        
        sceneView.debugOptions = [.showPhysicsShapes]
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
        sceneView.session.pause()
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
