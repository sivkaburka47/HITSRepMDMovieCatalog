//
//  ButtonView.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 10.10.2024.
//

import UIKit

class ButtonView: UIView {
    private let button: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont(name: "Manrope-Bold", size: 16)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.titleLabel?.textAlignment = .center
        return btn
    }()
    
    private let gradientLayer = CAGradientLayer()
    
    init(title: String, color: ButtonColor) {
        super.init(frame: .zero)
        setupView()
        configureButton(title: title, color: color)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(button)
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func configureButton(title: String, color: ButtonColor) {
        button.setTitle(title, for: .normal)
        gradientLayer.removeFromSuperlayer()
        
        switch color {
        case .orange:
            button.backgroundColor = UIColor.clear
            button.setTitleColor(.white, for: .normal)
            gradientLayer.colors = [
                UIColor(red: 223/255, green: 40/255, blue: 0/255, alpha: 1).cgColor,
                UIColor(red: 1, green: 102/255, blue: 51/255, alpha: 1).cgColor
            ]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            gradientLayer.frame = bounds
            gradientLayer.cornerRadius = 8
            layer.insertSublayer(gradientLayer, at: 0)
            button.layer.cornerRadius = 8
            button.clipsToBounds = true
            button.isEnabled = true
            
        case .gray:
            button.backgroundColor = UIColor.darkFaded
            button.layer.cornerRadius = 8
            button.clipsToBounds = true
            button.isEnabled = true
            
        case .hint:
            gradientLayer.removeFromSuperlayer()
            button.backgroundColor = UIColor.darkFaded
            button.setTitleColor(UIColor.grayFaded, for: .normal)
            button.layer.cornerRadius = 8
            button.clipsToBounds = true
            button.isEnabled = false
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        button.addTarget(target, action: action, for: controlEvents)
    }
    
    func changeButtonType(to color: ButtonColor) {
        configureButton(title: button.currentTitle ?? "", color: color)
    }
    
    enum ButtonColor {
        case orange
        case gray
        case hint
    }
}
