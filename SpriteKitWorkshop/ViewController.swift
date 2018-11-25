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

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            pin.physicsBody = nil
            rect.physicsBody = nil

            pin.position.y = 0
        })

        return rect
    }
}

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
