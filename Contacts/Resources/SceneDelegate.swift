//
//  SceneDelegate.swift
//  Contacts
//
//  Created by James Hager on 4/15/22.
//

import UIKit
import CloudKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        guard let scene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: scene)
        
        let navController = UINavigationController(rootViewController: ContactListViewController())
        
        window.rootViewController = navController
        
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        
        checkICoudAccountStatus() { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let connected):
                    ContactController.shared.handleICloud(connected: connected)
                    if !connected {
                        let message = "You must be signed into your iCloud account in order to use this app."
                        self.window?.rootViewController?.presentSimpleAlert(title: "Warning", message: message)
                    }
                    
                case .failure(let error):
                    print("\(#function) - error: \(error)")
                    self.window?.rootViewController?.presentErrorAlert(for: error)
                }
            }
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        print("\(#function)")
    }
    
    // MARK: - Misc Methods

    func checkICoudAccountStatus(completion: @escaping (Result<Bool, Error>) -> Void) {
        
        CKContainer.default().accountStatus { accountStatus, error in
            if let error = error {
                print("Error obtaining iCloud account status: \(error.localizedDescription)\n---\n\(error)")
                return completion(.failure(error))
            }
            
            completion(.success(accountStatus == .available))
        }
    }
}
