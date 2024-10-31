//
//  GameDieButtonView.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 30.10.2024.
//

import UIKit

class GameDieButtonView: UIView {
    
    private let wrapperButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .clear
        return btn
    }()
    
    private let gameDieImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "gameDie")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let buttonLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "Manrope-Bold", size: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.cornerRadius = 8
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        return layer
    }()
    
    enum ButtonColor {
        case orange
        case gray
        case hint
    }
    
    init(title: String, color: ButtonColor) {
        super.init(frame: .zero)
        setupView()
        configureButton(title: title, color: color)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(wrapperButton)
        wrapperButton.addSubview(gameDieImageView)
        wrapperButton.addSubview(buttonLabel)
        
        NSLayoutConstraint.activate([
            wrapperButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            wrapperButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            wrapperButton.topAnchor.constraint(equalTo: topAnchor),
            wrapperButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            gameDieImageView.leadingAnchor.constraint(equalTo: wrapperButton.leadingAnchor, constant: 16),
            gameDieImageView.centerYAnchor.constraint(equalTo: wrapperButton.centerYAnchor),
            gameDieImageView.widthAnchor.constraint(equalToConstant: 124),
            gameDieImageView.heightAnchor.constraint(equalToConstant: 124),
            
            buttonLabel.leadingAnchor.constraint(equalTo: gameDieImageView.trailingAnchor),
            buttonLabel.trailingAnchor.constraint(equalTo: wrapperButton.trailingAnchor, constant: -16),
            buttonLabel.centerYAnchor.constraint(equalTo: wrapperButton.centerYAnchor)
        ])
        
        wrapperButton.layer.cornerRadius = 8
        wrapperButton.clipsToBounds = true
    }
    
    private func configureButton(title: String, color: ButtonColor) {
        buttonLabel.text = title
        gradientLayer.removeFromSuperlayer()
        
        switch color {
        case .orange:
            setupGradientLayer(colors: [
                UIColor(red: 223/255, green: 40/255, blue: 0/255, alpha: 1).cgColor,
                UIColor(red: 1, green: 102/255, blue: 51/255, alpha: 1).cgColor
            ])
            buttonLabel.textColor = .white
            wrapperButton.isEnabled = true
            
        case .gray:
            wrapperButton.backgroundColor = UIColor.darkFaded
            buttonLabel.textColor = .white
            wrapperButton.isEnabled = true
            
        case .hint:
            wrapperButton.backgroundColor = UIColor.darkFaded
            buttonLabel.textColor = UIColor.grayFaded
            wrapperButton.isEnabled = false
        }
    }
    
    private func setupGradientLayer(colors: [CGColor]) {
        gradientLayer.colors = colors
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        wrapperButton.addTarget(target, action: action, for: controlEvents)
    }
    
    func changeButtonType(to color: ButtonColor) {
        configureButton(title: buttonLabel.text ?? "", color: color)
    }
}
