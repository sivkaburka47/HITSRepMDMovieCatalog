//
//  WelcomeViewModel.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 22.10.2024.
//

import Foundation

class WelcomeViewModel {
    
    private let appRouter: AppRouter
    
    init(appRouter: AppRouter) {
        self.appRouter = appRouter
    }
    
    func navigateToSignIn() {
        appRouter.navigateToSignIn()
    }
    
    func navigateToSignUp() {
        appRouter.navigateToSignUp()
    }
}
