//
//  WelcomeScreenController.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 10.10.2024.
//

import UIKit

class WelcomeScreenController: UIViewController {
    
    private var containerView: UIView!
    private var topGradientView: UIView!
    private var bottomGradientView: UIView!
    private var viewModel: WelcomeViewModel!
    
    init(appRouter: AppRouter) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = WelcomeViewModel(appRouter: appRouter)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.dark
        
        setupImageViews()
        setupGradientViews()
        configureTitle()
        configureButtonMenu()
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

    private func setupGradientViews() {
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
            topGradientView.heightAnchor.constraint(equalToConstant: 434)
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
            bottomGradientView.heightAnchor.constraint(equalToConstant: 434)
        ])
    }

    func setupImageViews() {
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.clipsToBounds = true
        view.addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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

    func configureTitle() {
        let titleLabel = UILabel()
        titleLabel.text = "Добро пожаловать в MovieCatalog"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont(name: "Manrope-Bold", size: 36)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0

        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.widthAnchor.constraint(equalToConstant: 364),
            titleLabel.heightAnchor.constraint(equalToConstant: 100),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 76),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24)
        ])
    }

    func configureButtonMenu() {
        let orangeButton = ButtonView(title: "Войти в аккаунт", color: .orange)
        orangeButton.translatesAutoresizingMaskIntoConstraints = false
        orangeButton.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        let grayButton = ButtonView(title: "Зарегистрироваться", color: .gray)
        grayButton.translatesAutoresizingMaskIntoConstraints = false
        grayButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        self.view.addSubview(orangeButton)
        self.view.addSubview(grayButton)
        NSLayoutConstraint.activate([
            orangeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            orangeButton.bottomAnchor.constraint(equalTo: grayButton.topAnchor, constant: -8),
            orangeButton.heightAnchor.constraint(equalToConstant: 48),
            orangeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            orangeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])

        NSLayoutConstraint.activate([
            grayButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            grayButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            grayButton.heightAnchor.constraint(equalToConstant: 48),
            grayButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            grayButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    @objc func signInButtonTapped() {
        viewModel.navigateToSignIn()
    }

    @objc func signUpButtonTapped() {
        viewModel.navigateToSignUp()
    }
}
