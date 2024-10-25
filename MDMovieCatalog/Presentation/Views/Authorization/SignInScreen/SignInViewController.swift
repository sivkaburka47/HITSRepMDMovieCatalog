//
//  SignInViewController.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 10.10.2024.
//

import UIKit

class SignInViewController: UIViewController, InputFieldViewDelegate {
    
    private var containerView: UIView!
    private var topGradientView: UIView!
    private var bottomGradientView: UIView!
    
    private var viewModel: SignInViewModel!
    
    private var containerMenuView: UIView!
    private var signInButton: ButtonView!
    private var loginInputField: InputFieldView!
    private var passwordInputField: InputFieldView!
    
    init(appRouter: AppRouter) {
        super.init(nibName: nil, bundle: nil)
        let apiService = APIService()
        let loginUserUseCase = LoginUserUseCase(apiService: apiService)
        viewModel = SignInViewModel(appRouter: appRouter, loginUserUseCase: loginUserUseCase)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.dark
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        viewModel.validationResult = { [weak self] (isValid, message) in
            guard let self = self else { return }
            if isValid {
                self.showAlert(title: "Успех", message: message ?? "Авторизация прошла успешно", shouldNavigate: true)
            } else {
                self.showAlert(title: "Ошибка", message: message ?? "Неизвестная ошибка")
            }
        }

        viewModel.onSuccessLogin = { [weak self] in
            self?.navigateToMain()
        }
        
        configureSignInButton()
        configureContainerMenuView()
        configureImageViews()
        configureGradientViews()
        configureHeader()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let topGradientLayer = topGradientView.layer.sublayers?.first as? CAGradientLayer {
            topGradientLayer.frame = topGradientView.bounds
        }
        
        if let bottomGradientLayer = bottomGradientView.layer.sublayers?.first as? CAGradientLayer {
            bottomGradientLayer.frame = bottomGradientView.bounds
        }
    }
    
    private func configureHeader() {
        let backButton = BackButtonView()
        view.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 76)
        ])
        
        let titleLabel = UILabel()
        titleLabel.text = "Вход в аккаунт"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont(name: "Manrope-Bold", size: 24)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0

        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: 40),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 76),
            titleLabel.leadingAnchor.constraint(equalTo: backButton.leadingAnchor, constant: 48)
        ])
    }
    
    private func configureContainerMenuView() {
        containerMenuView = UIView()
        containerMenuView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(containerMenuView)
        NSLayoutConstraint.activate([
            containerMenuView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerMenuView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            containerMenuView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            containerMenuView.bottomAnchor.constraint(equalTo: signInButton.topAnchor, constant: -32),
            containerMenuView.heightAnchor.constraint(equalToConstant: 104)
        ])
        
        passwordInputField = InputFieldView(placeholder: "Пароль", type: .password)
        passwordInputField.translatesAutoresizingMaskIntoConstraints = false
        containerMenuView.addSubview(passwordInputField)
        NSLayoutConstraint.activate([
            passwordInputField.leadingAnchor.constraint(equalTo: containerMenuView.leadingAnchor),
            passwordInputField.trailingAnchor.constraint(equalTo: containerMenuView.trailingAnchor),
            passwordInputField.bottomAnchor.constraint(equalTo: containerMenuView.bottomAnchor),
            passwordInputField.heightAnchor.constraint(equalToConstant: 48)
        ])
        passwordInputField.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidEnd)
        
        loginInputField = InputFieldView(placeholder: "Логин", type: .text)
        loginInputField.translatesAutoresizingMaskIntoConstraints = false
        containerMenuView.addSubview(loginInputField)
        NSLayoutConstraint.activate([
            loginInputField.leadingAnchor.constraint(equalTo: containerMenuView.leadingAnchor),
            loginInputField.trailingAnchor.constraint(equalTo: containerMenuView.trailingAnchor),
            loginInputField.bottomAnchor.constraint(equalTo: passwordInputField.topAnchor, constant: -8),
            loginInputField.heightAnchor.constraint(equalToConstant: 48)
        ])
        loginInputField.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidEnd)
    }
    
    private func configureSignInButton() {
        signInButton = ButtonView(title: "Войти", color: .hint)
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(signInButton)
        NSLayoutConstraint.activate([
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            signInButton.heightAnchor.constraint(equalToConstant: 48),
            signInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            signInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
        signInButton.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
    }

    private func configureGradientViews() {
        topGradientView = UIView()
        topGradientView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(topGradientView)

        let topGradientLayer = CAGradientLayer()
        topGradientLayer.colors = [
            UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0).cgColor,
            UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 0.0).cgColor
        ]
        topGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        topGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        topGradientLayer.frame = topGradientView.bounds
        topGradientView.layer.addSublayer(topGradientLayer)

        NSLayoutConstraint.activate([
            topGradientView.topAnchor.constraint(equalTo: containerView.topAnchor),
            topGradientView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            topGradientView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            topGradientView.heightAnchor.constraint(equalToConstant: 314)
        ])

        bottomGradientView = UIView()
        bottomGradientView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(bottomGradientView)

        let bottomGradientLayer = CAGradientLayer()
        bottomGradientLayer.colors = [
            UIColor(red: 26/255, green: 26/255, blue: 26/255, alpha: 0.0).cgColor,
            UIColor(red: 26/255, green: 26/255, blue: 26/255, alpha: 1.0).cgColor
        ]
        bottomGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        bottomGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        bottomGradientLayer.frame = bottomGradientView.bounds
        bottomGradientView.layer.addSublayer(bottomGradientLayer)

        NSLayoutConstraint.activate([
            bottomGradientView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            bottomGradientView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            bottomGradientView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            bottomGradientView.heightAnchor.constraint(equalToConstant: 314)
        ])
    }

    private func configureImageViews() {
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 24
        containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: containerMenuView.topAnchor, constant: -32)
        ])

        var imageViews: [UIImageView] = []

        for i in 0..<6 {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.image = UIImage(named: "imgContainer_\(i + 1)")
            imageViews.append(imageView)
            containerView.addSubview(imageView)
        }

        for (index, imageView) in imageViews.enumerated() {
            NSLayoutConstraint.activate([
                imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            ])

            if index == 0 {
                imageView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            } else {
                imageView.topAnchor.constraint(equalTo: imageViews[index - 1].bottomAnchor, constant: 10).isActive = true
            }
        }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func signInButtonTapped() {
        let userName = loginInputField.textField.text
        let password = passwordInputField.textField.text
        
        viewModel.validate(userName: userName, password: password)
    }
    
    private func updateSignInButtonState() {
        let login = loginInputField.textField.text ?? ""
        let password = passwordInputField.textField.text ?? ""

        let allFieldsFilled = !login.isEmpty && !password.isEmpty

        if allFieldsFilled {
            signInButton.changeButtonType(to: .orange)
        } else {
            signInButton.changeButtonType(to: .hint)
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        updateSignInButtonState()
    }
    
    func inputFieldDidClearText(_ inputField: InputFieldView) {
        updateSignInButtonState()
    }
    
    private func showAlert(title: String, message: String, shouldNavigate: Bool = false) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            if shouldNavigate {
                self?.navigateToMain()
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }

    private func navigateToMain() {
        viewModel.navigateToMain()
    }
}
