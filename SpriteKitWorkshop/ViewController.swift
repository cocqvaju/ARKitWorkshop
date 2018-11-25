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
    
    // --------  Assignment 3  --------
    //  At the end of assignment 2 we've seen how quickly it can become messy if you don't watch out
    //  In this assignment we're going to clean up that mess and have it behave like you'd expect it to
    //  First off, please note the bitmask that's defined in the ViewController class, that bitmask will represent
    //      what nodes our pin can interact with so we get rid of the unwanted collisions
    //
    //  1. Let's start by setting the collisionBitmask and categoryBitmask of both the pin and the rect to the value of bitmask
    //      Our pin can collide with it's own rect now but unless we change the bitmask it can collide with others as well
    //  2. Let's bitwise shift our bitmask 1 further by assigning it bitmask << 1
    //      To prevent getting stuck add an if statement to check if bitmask == 0 and if it is assign 1 to it
    //      Run the code and see how the behavior is better already but collissions are still possible
    //  3. Let's clean up the boxes first though, set the rect it's lineWidth to 0 and our app is much cleaner already
    //  4. Now for the final step let's get rid of the last collissions
    //      Add an asyncAfter 2 seconds where we're going to set the physicsBody of the pin and the rect to nil
    //      Just for good measure let's set the pin.position.y to 0 as well
    //
    //
    //
    //  Run the app again and notice how it behaves like you'd expect it to
    //  There are still limitations since this is a 2d world mapped in a 3d space but you're already able to build cool stuff
    //  Note that if you get further away the framework will handle everything for you but also note how you can still see pins through walls
    //
    //  In the next assignments we're going to take a look at how to create a 3d world with SceneKit
    // --------------------------------
    
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        if anchor is ARPlaneAnchor {
            return SKLabelNode(text: "⛳️")
        }

        let pin = SKLabelNode(text: "📍")
        let rect = SKShapeNode(rect: CGRect(x: -pin.frame.width/2, y: 0, width: pin.frame.width, height: 250))
        pin.position.y = rect.frame.height - pin.frame.height
        rect.addChild(pin)
        pin.physicsBody = SKPhysicsBody(rectangleOf: pin.frame.size, center: CGPoint(x: 0, y: pin.frame.width/2))
        rect.physicsBody = SKPhysicsBody(edgeLoopFrom: rect.frame)
        
        pin.physicsBody?.collisionBitMask = bitmask
        pin.physicsBody?.categoryBitMask = bitmask
        rect.physicsBody?.collisionBitMask = bitmask
        rect.physicsBody?.categoryBitMask = bitmask
        rect.lineWidth = 0
        
        bitmask = bitmask << 1
        if bitmask == 0 {
            bitmask = 1
        }
        
        // Since pins after overflow may collide, let's empty the physicsbody after fall animation
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            pin.physicsBody = nil
            rect.physicsBody = nil
            
            // Clean up to make sure
            pin.position.y = 0
        })

        return rect
    }
}

// Everything below this line is boilerplate, just some code to get SpriteKit up and running

class ViewController: UIViewController, ARSKViewDelegate {
    
    @IBOutlet var sceneView: ARSKView!
    
    var bitmask: UInt32 = 1
    
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
