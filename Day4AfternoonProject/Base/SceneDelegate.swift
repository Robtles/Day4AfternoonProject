//
//  SceneDelegate.swift
//  Day4AfternoonProject
//
//  Created by Rob on 09/04/2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UINavigationController(rootViewController: MenuViewController())
        window.makeKeyAndVisible()
        self.window = window
    }
}
