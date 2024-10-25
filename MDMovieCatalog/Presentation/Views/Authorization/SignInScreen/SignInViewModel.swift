//
//  SignInViewModel.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 15.10.2024.
//

import Foundation

class SignInViewModel {
    
    var validationResult: ((Bool, String?) -> Void)?
    var onSuccessLogin: (() -> Void)?
    private let appRouter: AppRouter
    
    private let loginUserUseCase: LoginUserUseCaseProtocol
    
    init(appRouter: AppRouter, loginUserUseCase: LoginUserUseCaseProtocol) {
        self.loginUserUseCase = loginUserUseCase
        self.appRouter = appRouter
    }
    
    func validate(userName: String?, password: String?) {
        guard let userName = userName, !userName.isEmpty else {
            validationResult?(false, "Логин не может быть пустым")
            return
        }
        
        guard let password = password, !password.isEmpty else {
            validationResult?(false, "Пароль не может быть пустым")
            return
        }
        
        let loginCredentials = LoginCredentials(userName: userName, password: password)
        
        loginUserUseCase.execute(user: loginCredentials) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    self?.validationResult?(true, "Авторизация прошла успешно. Ваш токен: \(token)")
                    self?.onSuccessLogin?()
                case .failure(let error):
                    self?.validationResult?(false, error.localizedDescription)
                }
            }
        }
    }
    
        
    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: "authToken")
    }
    
    func navigateToMain() {
        appRouter.navigateToMain()
    }
}
