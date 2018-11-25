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
    
    @objc func didTapView(sender: UITapGestureRecognizer) {
        let location = sender.location(in: sender.view)
        if let result = sceneView.hitTest(location, types: .existingPlane).first {
            let anchor = ARAnchor(transform: result.worldTransform)
            sceneView.session.add(anchor: anchor)
        }
    }
    
    // --------  Assignment 2  --------
    // At the end of assignment 1 we've already seen some limitations of a 2d world but let's explore that some more.
    // We're going to add some physics by having our pins "drop" into our scene.
    //
    //  1. Change our return return SKLabelNode(text: "📍") by saving the labelNode in a let called pin
    //  2. Next we're going to define a cylinder that will contain our pin in which it can fall to the bottom
    //      Define a SKShapeNode called rect with the following rect: CGRect(x: -pin.frame.width/2, y: 0, width: pin.frame.width, height: 250)
    //  3. Let's set our pin to the top of the cylinder by setting the pin.position.y to the rect.frame.height - the pin.frame.height
    //      This will move the pin to the top of our cilinder in our 2d world
    //  4. Let's add the pin as a child to our rect
    //  5. Now we're going to define a physicsbody for our pin, assign a SKPhysicsBody to our pin.physicsBody
    //      Create the SKPhysicsBody with the rectangleOf the pin frame size and define the center as x:0 y: pin.frame.width/2
    //      Our pin has some physics now but will never stop falling since it doesn't collide with anything
    //      Run the app, you'll see the rectangle but the pin will fall straight through the bottom
    //  6. Let's add a physicsbody to our rect as well, assign a SKPhysicsBody with an edgeLoopFrom: rect.frame
    //
    //
    //
    //  If you add 1 pin it will work like you'd expect it to
    //  Once you start adding more pins however you'll quickly see how this is becoming messy,
    //      pins dropping on top of other pins and other cylinders
    //  In the next assignments we'll clean that up!
    // --------------------------------
    
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        if anchor is ARPlaneAnchor {
            return SKLabelNode(text: "⛳️")
        }
        
        return SKLabelNode(text: "📍")        
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
