//
//  AppRouter.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 22.10.2024.
//

import UIKit
import SwiftUI

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
        DispatchQueue.main.async {
            self.navigateToFeed()
        }
    }
    
    func navigateToFeed() {
        let feedViewController = FeedViewController()
        if let tabBarController = self.navigationController?.topViewController as? TabBarCustomViewController {
            tabBarController.displayContentController(feedViewController)
            tabBarController.updateTabBarSelection(selectedIndex: 0)
        }
    }
    
    func navigateToMovies() {
        let moviesViewController = MoviesViewController(appRouter: self)
        if let tabBarController = self.navigationController?.topViewController as? TabBarCustomViewController {
            tabBarController.displayContentController(moviesViewController)
            tabBarController.updateTabBarSelection(selectedIndex: 1)
        }
    }
    
    func navigateToFavourites() {
        let favouritesView = FavouritesViewController()
        let favouritesViewController = UIHostingController(rootView: favouritesView)
        if let tabBarController = self.navigationController?.topViewController as? TabBarCustomViewController {
            tabBarController.displayContentController(favouritesViewController)
            tabBarController.updateTabBarSelection(selectedIndex: 2)
        }
    }
    
    func navigateToProfile() {
        let profileViewController = ProfileViewController(appRouter: self)
        if let tabBarController = self.navigationController?.topViewController as? TabBarCustomViewController {
            tabBarController.displayContentController(profileViewController)
            tabBarController.updateTabBarSelection(selectedIndex: 3)
        }
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "authToken")
        start()
    }
    
    func navigateToDetails(idRandMovie: String) {
        let viewModel = DetailsViewModel(appRouter: self)
        let detailsView = DetailsView(viewModel: viewModel, idRandMovie: idRandMovie, onBack: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
            if let tabBarController = self?.navigationController?.topViewController as? TabBarCustomViewController {
                tabBarController.updateTabBarSelection(selectedIndex: 1)
            }
        })
        let detailsViewController = UIHostingController(rootView: detailsView)
        if let navigationController = self.navigationController {
            navigationController.pushViewController(detailsViewController, animated: true)
        }
    }
}
