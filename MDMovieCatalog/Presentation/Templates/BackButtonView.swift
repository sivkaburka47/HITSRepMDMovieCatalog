//
//  BackButtonView.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 10.10.2024.
//

import UIKit

class BackButtonView: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        self.backgroundColor = UIColor.darkFaded
        self.layer.cornerRadius = 8
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let chevronImage = UIImage(named: "ChevronLeft")?.withRenderingMode(.alwaysTemplate)
        self.setImage(chevronImage, for: .normal)
        self.tintColor = .white
        self.imageView?.contentMode = .scaleAspectFit
        

        self.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }

    @objc private func backButtonTapped() {
        if let topController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
            topController.popViewController(animated: true)
        }
    }
}
