//
//  MainSceneViewController.swift
//  ARStuffNavigator
//
//  Created by Julia on 9/24/18.
//  Copyright © 2018 Julia. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit

class MainSceneViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSKView!
    private var sceneCoordinator: SceneCoordinator?
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and node count
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        
        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
            sceneCoordinator = SceneCoordinator(viewController: self,
                                                addAction: { anchor, _ in
                                                    self.sceneView.session.add(anchor: anchor)
            })
            scene.delegate = sceneCoordinator
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
}

// MARK: - ARSKViewDelegate
extension MainSceneViewController: ARSKViewDelegate {
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        return sceneCoordinator?.node(for: anchor)
    }
}
