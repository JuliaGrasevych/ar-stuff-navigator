//
//  SceneCoordinator.swift
//  ARStuffNavigator
//
//  Created by Julia on 9/24/18.
//  Copyright © 2018 Julia. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit

class SceneCoordinator: NSObject {
    let viewController: UIViewController
    let addAction: (ARAnchor, SKNode) -> ()
    
    private var anchorNodes = [ARAnchor: SKNode]()
    
    init(viewController: UIViewController,
         addAction: @escaping (ARAnchor, SKNode) -> ()) {
        self.viewController = viewController
        self.addAction = addAction
        super.init()
    }
    
    func node(for anchor: ARAnchor) -> SKNode? {
        return anchorNodes[anchor]
    }
    
    private func node(for element: SceneEditPresenter.Element) -> SKNode {
        switch element {
        case .text(let text):
            // Create and configure a node for the anchor added to the view's session.
            let labelNode = SKLabelNode(text: text)
            labelNode.horizontalAlignmentMode = .center
            labelNode.verticalAlignmentMode = .center
            labelNode.zPosition = 1
            return labelNode
        case .image(let image):
            var newImage = image
            if let cgImage = image.cgImage {
                let currentSize = image.size
                let scaleFactor = max(currentSize.width, currentSize.height) / 50
                newImage = UIImage(cgImage: cgImage, scale: scaleFactor, orientation: .up)
            }
            let texture = SKTexture(image: newImage)
            texture.filteringMode = .nearest
            
            let imageNode = SKSpriteNode(texture: texture, size: CGSize(width: 50, height: 50))
            imageNode.zPosition = 1
            return imageNode
        }
    }
    
    private func add(element: SceneEditPresenter.Element, at anchor: ARAnchor) {
        let anchor = anchor
        let node = self.node(for: element)
        self.anchorNodes[anchor] = node
        self.addAction(anchor, node)
    }
    private func edit(element: SceneEditPresenter.Element?, in node: SKNode) {
        guard let (anchor, _) = self.anchorNodes.first(where: { $1 == node }) else {
            return
        }
        guard let element = element else {
            self.anchorNodes[anchor] = nil
            node.removeFromParent()
            return
        }
        switch (node, element) {
        case (let textNode as SKLabelNode, .text(let text)):
            textNode.text = text
        case (let imageNode as SKSpriteNode, .image(let image)):
            imageNode.texture = SKTexture(image: image)
        default: break
        }
    }
}
extension SceneCoordinator: SceneDelegate {
    func scene(_ scene: Scene, didHit hit: ARHitTestResult) {
        SceneEditPresenter(viewController: viewController,
                           type: .add(action: {
                            self.add(element: $0, at: ARAnchor(transform: hit.worldTransform))
                           }))
            .present()
    }
    
    func scene(_ scene: Scene, didHitNode node: SKNode) {
        SceneEditPresenter(viewController: viewController,
                           type: .edit(node: node, action: {
                            self.edit(element: $0, in: node)
                           }))
            .present()
    }
    
    func scene(_ scene: Scene, modify node: SKNode, with action: SKAction) {
        node.run(action)
    }
}
