//
//  LogOutButtonView.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 27.10.2024.
//

import UIKit

class SignOutButtonView: UIButton {
    
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
        
        let chevronImage = UIImage(named: "SignOut")?.withRenderingMode(.alwaysTemplate)
        self.setImage(chevronImage, for: .normal)
        self.tintColor = .white
        self.imageView?.contentMode = .scaleAspectFit
        

        
    }


}
