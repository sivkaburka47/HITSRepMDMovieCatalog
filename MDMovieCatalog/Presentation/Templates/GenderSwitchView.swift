//
//  SwitchButton.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 11.10.2024.
//

import UIKit

class GenderSwitchView: UIView {
    
    public let maleButton = UIButton(type: .system)
    public let femaleButton = UIButton(type: .system)
    private var selectedButton: UIButton?
    
    var selectedGender: Int? {
            return selectedButton == maleButton ? 0 : 1
        }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
        selectButton(maleButton)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
        
        selectButton(maleButton)
        
    }
    
    private func setupButtons() {
        maleButton.setTitle("Мужчина", for: .normal)
        maleButton.setTitleColor(.white, for: .normal)
        maleButton.titleLabel?.font = UIFont(name: "Manrope-Bold", size: 16)
        maleButton.translatesAutoresizingMaskIntoConstraints = false
        maleButton.titleLabel?.textAlignment = .center
        maleButton.backgroundColor = UIColor.darkFaded
        maleButton.layer.cornerRadius = 8
        maleButton.clipsToBounds = true
        maleButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        maleButton.addTarget(self, action: #selector(maleButtonTapped), for: .touchUpInside)
        
        femaleButton.setTitle("Женщина", for: .normal)
        femaleButton.setTitleColor(.white, for: .normal)
        femaleButton.titleLabel?.font = UIFont(name: "Manrope-Bold", size: 16)
        femaleButton.translatesAutoresizingMaskIntoConstraints = false
        femaleButton.titleLabel?.textAlignment = .center
        femaleButton.backgroundColor = UIColor.darkFaded
        femaleButton.layer.cornerRadius = 8
        femaleButton.clipsToBounds = true
        femaleButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        femaleButton.addTarget(self, action: #selector(femaleButtonTapped), for: .touchUpInside)
        
        self.addSubview(maleButton)
        self.addSubview(femaleButton)
        
        NSLayoutConstraint.activate([
            maleButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            maleButton.topAnchor.constraint(equalTo: self.topAnchor),
            maleButton.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            maleButton.widthAnchor.constraint(equalTo: femaleButton.widthAnchor),
            
            femaleButton.leadingAnchor.constraint(equalTo: maleButton.trailingAnchor),
            femaleButton.topAnchor.constraint(equalTo: self.topAnchor),
            femaleButton.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            femaleButton.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    private func selectButton(_ button: UIButton) {
        resetButtonStyle(maleButton)
        resetButtonStyle(femaleButton)
        
        button.backgroundColor = .clear
        setupGradientLayer(for: button)
        selectedButton = button
        
        if button == maleButton {
            setupGradientCorners(for: button, corners: [.layerMinXMinYCorner, .layerMinXMaxYCorner])
        } else {
            setupGradientCorners(for: button, corners: [.layerMaxXMinYCorner, .layerMaxXMaxYCorner])
        }
    }
    
    private func setupGradientCorners(for button: UIButton, corners: CACornerMask) {
            if let gradientLayer = button.layer.sublayers?.first as? CAGradientLayer {
                gradientLayer.cornerRadius = 8
                gradientLayer.maskedCorners = corners
            }
        }
    
    private func resetButtonStyle(_ button: UIButton) {
        button.layer.sublayers?.forEach { layer in
            if layer is CAGradientLayer {
                layer.removeFromSuperlayer()
            }
        }
        button.backgroundColor = UIColor.darkFaded
    }
    
    private func setupGradientLayer(for button: UIButton) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 223/255, green: 40/255, blue: 0/255, alpha: 1).cgColor,
            UIColor(red: 1, green: 102/255, blue: 51/255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = button.bounds
        
        button.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    @objc public func maleButtonTapped() {
        selectButton(maleButton)
    }
    
    @objc public func femaleButtonTapped() {
        selectButton(femaleButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let selectedButton = selectedButton {
            setupGradientLayer(for: selectedButton)
        }
    }
}
