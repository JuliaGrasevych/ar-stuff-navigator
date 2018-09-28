//
//  Scene.swift
//  ARStuffNavigator
//
//  Created by Julia on 9/24/18.
//  Copyright © 2018 Julia. All rights reserved.
//

import SpriteKit
import ARKit

protocol SceneDelegate: SKSceneDelegate {
    func scene(_ scene: Scene, didHit hit: ARHitTestResult)
    func scene(_ scene: Scene, didHitNode node: SKNode)
    func scene(_ scene: Scene, modify node: SKNode, with action: SKAction)
}

class Scene: SKScene {
    
    override func didMove(to view: SKView) {
        addTapHandler()
        addPinchHandler()
    }
    
    // MARK: - Gesture recognizers
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        let touch = sender.location(ofTouch: 0, in: self.view)
        let touchInScene = self.convertPoint(fromView: touch)
        if let node = nodes(at: touchInScene).first {
            (delegate as? SceneDelegate)?.scene(self, didHitNode: node)
            return
        }
        if let hit = sceneView.hitTest(touch, types: .featurePoint).first {
            (delegate as? SceneDelegate)?.scene(self, didHit: hit)
            return
        }
    }
    @objc private func handlePinch(_ sender: UIPinchGestureRecognizer) {
        let touch = sender.location(ofTouch: 0, in: self.view)
        let touchInScene = self.convertPoint(fromView: touch)
        guard let node = nodes(at: touchInScene).first as? SKSpriteNode else {
            return
        }
        let scale = sender.scale - 1
        let resizeAction = SKAction.resize(byWidth: node.size.width * scale,
                                           height: node.size.height * scale,
                                           duration: 0)
        (delegate as? SceneDelegate)?.scene(self, modify: node, with: resizeAction)
        sender.scale = 1
    }
    
    // MARK: - Private functions
    private func addTapHandler() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.view?.addGestureRecognizer(tap)
    }
    private func addPinchHandler() {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        self.view?.addGestureRecognizer(pinch)
    }
}
