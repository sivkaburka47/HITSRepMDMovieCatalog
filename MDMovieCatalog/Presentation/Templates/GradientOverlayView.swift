//
//  GradientOverlayView.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 25.10.2024.
//

import UIKit

class GradientOverlayView: UIView {
    private var gradientLayer: CAGradientLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradientLayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradientLayer()
    }
    
    private func setupGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 223/255, green: 40/255, blue: 0/255, alpha: 0.5).cgColor,
            UIColor(red: 1, green: 102/255, blue: 51/255, alpha: 0.5).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 8
        layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.isHidden = true
    }
    
    func setGradientVisible(_ visible: Bool) {
        gradientLayer.isHidden = !visible
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
