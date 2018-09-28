//
//  SceneEditPresenter.swift
//  ARStuffNavigator
//
//  Created by Julia on 9/24/18.
//  Copyright © 2018 Julia. All rights reserved.
//

import UIKit
import SpriteKit

class SceneEditPresenter: NSObject {
    
    enum Element {
        case text(String)
        case image(UIImage)
        // TODO: case bundle
    }
    
    enum ActionSheet {
        case add(action: (Element) -> ())
        case edit(node: SKNode, action: (Element?) -> ())
    }
    
    let viewController: UIViewController
    let type: ActionSheet
    
    #warning("hack to retain self as image picker delegate")
    private var selfRef: SceneEditPresenter?
    
    init(viewController: UIViewController, type: ActionSheet) {
        self.viewController = viewController
        self.type = type
        super.init()
    }
    
    func present() {
        switch type {
        case .add(_):
            showAddItemDialog()
        case .edit(let node, _):
            showEditSheet(node: node)
        }
    }
    
    // MARK: - Private functions
    private func showAddItemDialog() {
        let sheet = UIAlertController(title: "Choose item to add", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Text", style: .default, handler: { _ in
            self.showAlert()
        }))
        sheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { _ in
            self.showPhotoLibrary()
        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        viewController.present(sheet, animated: true, completion: nil)
    }
    
    private func showEditSheet(node: SKNode) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "View", style: .default, handler: { _ in
            
        }))
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
            switch node {
            case is SKLabelNode:
                self.showAlert()
            case is SKSpriteNode:
                self.showPhotoLibrary()
            default: break
            }
        }))
        sheet.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { _ in
            if case let .edit(_, action) = self.type{
                action(nil)
            }
        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        viewController.present(sheet, animated: true, completion: nil)
    }
    private func showAlert() {
        // show alert to let user enter text
        let alert = UIAlertController(title: "Enter text", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            // TODO: use prisms :)
            if case let .edit(node: node, action: _) = self.type,
                let textNode = node as? SKLabelNode {
                textField.text = textNode.text
            }
        }
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            if let text = alert.textFields?.first?.text {
                switch self.type {
                case .edit(_, let action):
                    action(.text(text))
                case .add(let action):
                    action(.text(text))
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    private func showPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .savedPhotosAlbum
            picker.allowsEditing = false
            selfRef = self
            viewController.present(picker, animated: true, completion: nil)
        }
    }
}

extension SceneEditPresenter: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        selfRef = nil
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            switch self.type {
            case .edit(_, let action):
                action(.image(image))
            case .add(let action):
                action(.image(image))
            }
        }
        viewController.dismiss(animated: true)
    }
}
