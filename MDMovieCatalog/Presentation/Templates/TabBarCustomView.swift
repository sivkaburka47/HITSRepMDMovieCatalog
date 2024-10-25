//
//  TabBarCustomView.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 22.10.2024.
//

import UIKit

class TabBarCustomViewController: UIViewController {
    
    private var tabBarBackgroundView: UIView?
    private var stackView: UIStackView?
    private var currentViewController: UIViewController?
    
    private var tabBarItems: [UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTabBarBackgroundView()
        configureTabBarItems()
        

        showFeed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.hidesBackButton = true
    }
    
    private func configureTabBarBackgroundView() {
        let tabBarBackgroundView = UIView()
        tabBarBackgroundView.backgroundColor = UIColor.darkFaded
        tabBarBackgroundView.layer.cornerRadius = 16
        tabBarBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabBarBackgroundView)
        
        NSLayoutConstraint.activate([
            tabBarBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            tabBarBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            tabBarBackgroundView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            tabBarBackgroundView.heightAnchor.constraint(equalToConstant: 64)
        ])
        
        self.tabBarBackgroundView = tabBarBackgroundView
    }
    
    private func configureTabBarItems() {
        guard let tabBarBackgroundView = tabBarBackgroundView else { return }
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 0
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        tabBarBackgroundView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: tabBarBackgroundView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: tabBarBackgroundView.trailingAnchor, constant: -8),
            stackView.topAnchor.constraint(equalTo: tabBarBackgroundView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: tabBarBackgroundView.bottomAnchor, constant: -8)
        ])
        
        self.stackView = stackView
        
        tabBarItems = [
            createTabBarItem(title: "Лента", icon: UIImage(named: "feed")!, target: self, action: #selector(showFeed)),
            createTabBarItem(title: "Фильмы", icon: UIImage(named: "movies")!, target: self, action: #selector(showMovies)),
            createTabBarItem(title: "Избранное", icon: UIImage(named: "favourites")!, target: self, action: #selector(showFavourites)),
            createTabBarItem(title: "Профиль", icon: UIImage(named: "profile")!, target: self, action: #selector(showProfile))
        ]
        
        for item in tabBarItems {
            stackView.addArrangedSubview(item)
        }
    }
    
    private func createTabBarItem(title: String, icon: UIImage, target: Any?, action: Selector) -> UIView {
        let itemView = UIView()
        itemView.backgroundColor = UIColor.clear
        itemView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView(image: icon.withRenderingMode(.alwaysTemplate))
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = UIColor.grayFaded
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        itemView.addSubview(iconView)
        
        let label = UILabel()
        label.text = title
        label.font = UIFont(name: "Manrope-Medium", size: 12)
        label.textColor = UIColor.grayFaded
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        itemView.addSubview(label)
        
        let tapGesture = UITapGestureRecognizer(target: target, action: action)
        itemView.addGestureRecognizer(tapGesture)
        
        NSLayoutConstraint.activate([
            itemView.heightAnchor.constraint(equalToConstant: 48),
            
            iconView.topAnchor.constraint(equalTo: itemView.topAnchor),
            iconView.centerXAnchor.constraint(equalTo: itemView.centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),
            
            label.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 4),
            label.leadingAnchor.constraint(equalTo: itemView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: itemView.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: itemView.bottomAnchor)
        ])
        
        return itemView
    }
    
    private func displayContentController(_ content: UIViewController) {
        if let currentVC = currentViewController {
            currentVC.willMove(toParent: nil)
            currentVC.view.removeFromSuperview()
            currentVC.removeFromParent()
        }
        
        addChild(content)
        content.view.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(content.view, belowSubview: tabBarBackgroundView!)
        NSLayoutConstraint.activate([
            content.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            content.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            content.view.topAnchor.constraint(equalTo: view.topAnchor),
            content.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        content.didMove(toParent: self)
        currentViewController = content
    }
    
    @objc private func showFeed() {
        let feedViewController = FeedViewController()
        displayContentController(feedViewController)
        updateTabBarSelection(selectedIndex: 0)
    }
    
    @objc private func showMovies() {
        let moviesViewController = MoviesViewController()
        displayContentController(moviesViewController)
        updateTabBarSelection(selectedIndex: 1)
    }
    
    @objc private func showFavourites() {
        let favouritesViewController = FavouritesViewController()
        displayContentController(favouritesViewController)
        updateTabBarSelection(selectedIndex: 2)
    }
    
    @objc private func showProfile() {
        let profileViewController = ProfileViewController()
        displayContentController(profileViewController)
        updateTabBarSelection(selectedIndex: 3)
    }
    
    private func updateTabBarSelection(selectedIndex: Int) {
        for (index, item) in tabBarItems.enumerated() {
            if let label = item.subviews.compactMap({ $0 as? UILabel }).first,
               let iconView = item.subviews.compactMap({ $0 as? UIImageView }).first {
                
                if index == selectedIndex {
                    let gradientLayer = CAGradientLayer()
                    gradientLayer.colors = [
                        UIColor(red: 223/255, green: 40/255, blue: 0/255, alpha: 1).cgColor,
                        UIColor(red: 1, green: 102/255, blue: 51/255, alpha: 1).cgColor
                    ]
                    gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
                    gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
                    gradientLayer.frame = label.bounds
                    
                    let textMask = CALayer()
                    textMask.frame = label.bounds
                    textMask.contents = label.layer.contents
                    gradientLayer.mask = textMask
                    
                    
                    let iconGradientLayer = CAGradientLayer()
                    iconGradientLayer.colors = gradientLayer.colors
                    iconGradientLayer.startPoint = gradientLayer.startPoint
                    iconGradientLayer.endPoint = gradientLayer.endPoint
                    iconGradientLayer.frame = iconView.bounds
                    
                    let iconMask = CALayer()
                    iconMask.frame = iconView.bounds
                    iconMask.contents = iconView.image?.cgImage
                    iconGradientLayer.mask = iconMask
                    
                    iconView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
                    iconView.layer.addSublayer(iconGradientLayer)
                    label.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
                    label.layer.addSublayer(gradientLayer)

                } else {
                    label.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
                    label.textColor = UIColor.grayFaded
                    

                    iconView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
                    iconView.tintColor = UIColor.grayFaded
                }
            }
        }
    }


    
    
}
