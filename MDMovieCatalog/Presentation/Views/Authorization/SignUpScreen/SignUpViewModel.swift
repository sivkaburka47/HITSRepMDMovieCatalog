//
//  SignUpViewModel.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 15.10.2024.
//

import Foundation

class SignUpViewModel {
    
    var validationResult: ((Bool, String?) -> Void)?
    var onSuccessRegistration: (() -> Void)?
    private let appRouter: AppRouter
    
    private let registerUserUseCase: RegisterUserUseCaseProtocol
    
    init(appRouter: AppRouter, registerUserUseCase: RegisterUserUseCaseProtocol) {
        self.registerUserUseCase = registerUserUseCase
        self.appRouter = appRouter
    }
    
    func validate(userName: String?, name: String?, password: String?, confirmPassword: String?, email: String?, birthDate: String?, gender: Int?) {
        guard let userName = userName, !userName.isEmpty else {
            validationResult?(false, "Логин не может быть пустым")
            return
        }
        
        guard let name = name, !name.isEmpty else {
            validationResult?(false, "Имя не может быть пустым")
            return
        }
        
        guard let password = password, !password.isEmpty else {
            validationResult?(false, "Пароль не может быть пустым")
            return
        }
        
        guard let confirmPassword = confirmPassword, !confirmPassword.isEmpty else {
            validationResult?(false, "Подтверждение пароля не может быть пустым")
            return
        }
        
        guard password == confirmPassword else {
            validationResult?(false, "Пароли не совпадают")
            return
        }
        
        guard let email = email, !email.isEmpty else {
            validationResult?(false, "Email не может быть пустым")
            return
        }
        
        guard isValidEmail(email) else {
            validationResult?(false, "Неверный формат email")
            return
        }
        
        guard let birthDate = birthDate, !birthDate.isEmpty else {
            validationResult?(false, "Дата рождения не может быть пустой")
            return
        }
        
        guard let gender = gender else {
            validationResult?(false, "Пол не может быть пустым")
            return
        }
        
        let iso8601Date = formatDateToISO8601(birthDate)
        guard let iso8601Date = iso8601Date else {
            validationResult?(false, "Неверный формат даты рождения")
            return
        }
        
        let registrationCredentials = RegistrationCredentials(userName: userName, name: name, password: password, email: email, birthDate: iso8601Date, gender: gender)
        
        registerUserUseCase.execute(user: registrationCredentials) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    self?.validationResult?(true, "Регистрация прошла успешно. Ваш токен: \(token)")
                    self?.onSuccessRegistration?()
                case .failure(let error):
                    self?.validationResult?(false, error.localizedDescription)
                }
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func formatDateToISO8601(_ dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        guard let date = dateFormatter.date(from: dateString) else {
            return nil
        }
        
        let iso8601Formatter = ISO8601DateFormatter()
        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        return iso8601Formatter.string(from: date)
    }
    
        
    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: "authToken")
    }
    
    func navigateToMain() {
        appRouter.navigateToMain()
    }
}
