//
//  ViewController.swift
//  SpriteKitWorkshop
//
//  Created by Jurian de Cocq van Delwijnen on 21/10/2018.
//  Copyright © 2018 Sogeti. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit

extension ViewController {
    
    // --------  Assignment 1  --------
    //  1. First off we're going to implement the nodeForAnchor method.
    //  This method will determine what kind of Node we'll show in the world.
    //
    //  For now let's return an SKLabelNode filled with the ⛳️ emoji if anchor is of type ARPlanceAnchor,
    //      if the anchor is anything else let's return an SKLabelNode filled with the 📍 emoji.
    //
    //
    //
    //  2. Let's implement didTapView now.
    //  On tapping we want to add a Node to the world for which we're going to need an Anchor.
    //
    //  Let's get a location first, define a let location with the sender.location(in: sender.view)
    //  Then we'll determine if we've tapped a detected plane.
    //  Do this by defining an if let result where we'll take sceneView.hitTest or our location with the type .existingPlane take the .first from that.
    //  In the if let block define a let anchor and fill it with a freshly created ARAnchor with the tranform of our result.worldTransform.
    //  Finish up by adding the newly defined anchor to our scene by calling sceneView.session.add(anchor: anchor)
    //
    //
    //
    //  If you've done everything correctly until now we've added an anchor to our scene.
    //  The nodeForAnchor method will automatically fill it with a pin when tapping.
    //  Run the app now, point the camera across the room and see the ⛳️ appear where ARKit has detected a surface.
    //  Tap the screen near that area and you can see the 📍 appear
    //  Note how this is all 2d, hold your camera right above the nodes and you'll see how they start rotating
    //  This is an example of the limitations of mapping a 2d world in the 3d world
    // --------------------------------
    
    @objc func didTapView(sender: UITapGestureRecognizer) {
        
    }
    
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {        

    }
}

// Everything below this line is boilerplate, just some code to get SpriteKit up and running

class ViewController: UIViewController, ARSKViewDelegate {
    
    @IBOutlet var sceneView: ARSKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        
        sceneView.delegate = self
        
        let scene = SKScene(size: CGSize(width: 512, height: 768))
        sceneView.presentScene(scene)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTapView))
        sceneView.addGestureRecognizer(gesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = ARWorldTrackingConfiguration.PlaneDetection.horizontal
        sceneView.session.run(configuration, options: [])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
}
