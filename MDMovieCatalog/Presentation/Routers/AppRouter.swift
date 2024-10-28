//
//  AppRouter.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 22.10.2024.
//

import UIKit

class AppRouter {
    
    private var window: UIWindow?
    private var navigationController: UINavigationController?
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    func start() {
        let welcomeScreenController = WelcomeScreenController(appRouter: self)
        self.navigationController = UINavigationController(rootViewController: welcomeScreenController)
        self.window?.rootViewController = self.navigationController
        self.window?.makeKeyAndVisible()
        if let token = UserDefaults.standard.string(forKey: "authToken"), !token.isEmpty {
            navigateToMain()
        }
    }
    
    func navigateToSignIn() {
        let signInController = SignInViewController(appRouter: self)
        self.navigationController?.pushViewController(signInController, animated: true)
    }
    
    func navigateToSignUp() {
        let signUpController = SignUpViewController(appRouter: self)
        self.navigationController?.pushViewController(signUpController, animated: true)
    }
    
    func navigateToMain() {
        let tabBarController = TabBarCustomViewController(appRouter: self)
        self.navigationController?.pushViewController(tabBarController, animated: true)
    }
    
}
