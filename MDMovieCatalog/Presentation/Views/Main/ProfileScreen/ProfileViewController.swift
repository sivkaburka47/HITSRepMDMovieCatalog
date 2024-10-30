//
//  ProfileViewController.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 22.10.2024.
//

import UIKit

class ProfileViewController: UIViewController, UITextFieldDelegate {
    private var viewModel: ProfileViewModel!

    private var activeTextField: UITextField?
    private var avatarImageView: UIImageView!
    private var helloTextLabel: UILabel!
    private var userNameLabel: UILabel!
    private var headerProfileContainer: UIView!
    private var friendsAvatarsContainer: UIView!
    private var friendsContainer: UIView!
    private var blockNameLabel: UILabel!
    private var loginInputField: InputFieldView!
    private var mailInputField: InputFieldView!
    private var nameInputField: InputFieldView!
    private var birthDateInputField: InputFieldView!
    private var genderSwitchView: GenderSwitchView!
    private var headerImageView: UIImageView!
    private var containerView: UIView!
    
    init(appRouter: AppRouter) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = ProfileViewModel(appRouter: appRouter)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.dark
        configureHeader()
        configureContainer()
        
        viewModel.updateUI = { [weak self] in
            self?.updateProfileUI()
        }
        
        viewModel.fetchProfile()
        updateHelloText()
        
    }
    
    @objc private func avatarTapped() {
        showAvatarChangeAlert()
    }
    
    private func showAvatarChangeAlert() {
        let alertController = UIAlertController(title: "Изменить аватар", message: "Введите URL картинки", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "URL картинки"
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Сохранить", style: .default) { [weak self] _ in
            if let urlString = alertController.textFields?.first?.text, !urlString.isEmpty {
                self?.updateAvatar(with: urlString)
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func updateAvatar(with urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        avatarImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "avatar"), completed: { [weak self] (image, error, cacheType, imageURL) in
            if let error = error {
                print("Failed to load image: \(error.localizedDescription)")
            } else {
                self?.viewModel.changeProfileAvatar(urlString)
            }
        })
    }
    
    private func updateHelloText() {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        
        let totalMinutes = hour * 60 + minute
        
        switch totalMinutes {
        case 360..<720:
            helloTextLabel.text = "Доброе утро,"
        case 720..<1080:
            helloTextLabel.text = "Добрый день,"
        case 1080..<1440:
            helloTextLabel.text = "Добрый вечер,"
        case 0..<360:
            helloTextLabel.text = "Доброй ночи,"
        default:
            helloTextLabel.text = "Доброе утро,"
        }
    }
    
    private func updateProfileUI() {
        guard let profile = viewModel.profile else { return }
        if let avatarLink = profile.avatarLink, let avatarURL = URL(string: avatarLink) {
            avatarImageView.sd_setImage(with: avatarURL, completed: nil)
        } else {
            print("Invalid URL or no avatar link provided")
        }
        userNameLabel.text = profile.name
        loginInputField.textField.text = profile.nickName
        mailInputField.textField.text = profile.email
        nameInputField.textField.text = profile.name
        birthDateInputField.textField.text = profile.birthDate
        if profile.gender == 1 {
            genderSwitchView.femaleButtonTapped()
        }
        else if profile.gender == 0 {
            genderSwitchView.maleButtonTapped()
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField?.resignFirstResponder()
        
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
    
    private func configureHeader() {
        headerImageView = UIImageView(image: UIImage(named: "profileHeader"))
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerImageView)
        NSLayoutConstraint.activate([
            headerImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerImageView.topAnchor.constraint(equalTo: view.topAnchor),
        ])
    }
    
    private func configureContainer() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            scrollView.topAnchor.constraint(equalTo: headerImageView.bottomAnchor, constant: -45),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -88),
        ])
        
        
        containerView = UIView()
        containerView.backgroundColor = .clear
        containerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 694)
        ])
        
        genderSwitchView = GenderSwitchView()
        genderSwitchView.translatesAutoresizingMaskIntoConstraints = false
        genderSwitchView.maleButton.isEnabled = false
        genderSwitchView.femaleButton.isEnabled = false
        containerView.addSubview(genderSwitchView)
        NSLayoutConstraint.activate([
            genderSwitchView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            genderSwitchView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            genderSwitchView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            genderSwitchView.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        let genderLabel = UILabel()
        genderLabel.text = "Пол"
        genderLabel.font = UIFont(name: "Manrope-Regular", size: 14)
        genderLabel.textColor = UIColor.grayCustom
        genderLabel.textAlignment = .left
        genderLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(genderLabel)
        NSLayoutConstraint.activate([
            genderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            genderLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            genderLabel.bottomAnchor.constraint(equalTo: genderSwitchView.topAnchor,constant: -4),
            genderLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        birthDateInputField = InputFieldView(placeholder: "Дата рождения", type: .date, showsIconButton: false)
        birthDateInputField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(birthDateInputField)
        NSLayoutConstraint.activate([
            birthDateInputField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            birthDateInputField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            birthDateInputField.bottomAnchor.constraint(equalTo: genderLabel.topAnchor, constant: -16),
            birthDateInputField.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        let birthDateLabel = UILabel()
        birthDateLabel.text = "Дата рождения"
        birthDateLabel.font = UIFont(name: "Manrope-Regular", size: 14)
        birthDateLabel.textColor = UIColor.grayCustom
        birthDateLabel.textAlignment = .left
        birthDateLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(birthDateLabel)
        NSLayoutConstraint.activate([
            birthDateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            birthDateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            birthDateLabel.bottomAnchor.constraint(equalTo: birthDateInputField.topAnchor,constant: -4),
            birthDateLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        nameInputField = InputFieldView(placeholder: "Имя", type: .text, showsIconButton: false)
        nameInputField.textField.delegate = self
        nameInputField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameInputField)
        NSLayoutConstraint.activate([
            nameInputField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            nameInputField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            nameInputField.bottomAnchor.constraint(equalTo: birthDateLabel.topAnchor, constant: -16),
            nameInputField.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        let nameLabel = UILabel()
        nameLabel.text = "Имя"
        nameLabel.font = UIFont(name: "Manrope-Regular", size: 14)
        nameLabel.textColor = UIColor.grayCustom
        nameLabel.textAlignment = .left
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: nameInputField.topAnchor,constant: -4),
            nameLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        mailInputField = InputFieldView(placeholder: "Электронная почта", type: .text, showsIconButton: false)
        mailInputField.textField.delegate = self
        mailInputField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(mailInputField)
        NSLayoutConstraint.activate([
            mailInputField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            mailInputField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            mailInputField.bottomAnchor.constraint(equalTo: nameLabel.topAnchor, constant: -16),
            mailInputField.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        let mailLabel = UILabel()
        mailLabel.text = "Электронная почта"
        mailLabel.font = UIFont(name: "Manrope-Regular", size: 14)
        mailLabel.textColor = UIColor.grayCustom
        mailLabel.textAlignment = .left
        mailLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(mailLabel)
        NSLayoutConstraint.activate([
            mailLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            mailLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            mailLabel.bottomAnchor.constraint(equalTo: mailInputField.topAnchor,constant: -4),
            mailLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        loginInputField = InputFieldView(placeholder: "Логин", type: .text, showsIconButton: false)
        loginInputField.textField.delegate = self
        loginInputField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(loginInputField)
        NSLayoutConstraint.activate([
            loginInputField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            loginInputField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            loginInputField.bottomAnchor.constraint(equalTo: mailLabel.topAnchor, constant: -16),
            loginInputField.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        let loginLabel = UILabel()
        loginLabel.text = "Логин"
        loginLabel.font = UIFont(name: "Manrope-Regular", size: 14)
        loginLabel.textColor = UIColor.grayCustom
        loginLabel.textAlignment = .left
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(loginLabel)
        NSLayoutConstraint.activate([
            loginLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            loginLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            loginLabel.bottomAnchor.constraint(equalTo: loginInputField.topAnchor,constant: -4),
            loginLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        let blockNameLabel = UILabel()
        blockNameLabel.text = "Личная информация"
        blockNameLabel.font = UIFont(name: "Manrope-Bold", size: 20)
        blockNameLabel.textColor = UIColor.grayCustom
        blockNameLabel.textAlignment = .left
        blockNameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(blockNameLabel)
        NSLayoutConstraint.activate([
            blockNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            blockNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            blockNameLabel.bottomAnchor.constraint(equalTo: loginLabel.topAnchor, constant: -16),
            blockNameLabel.heightAnchor.constraint(equalToConstant: 24)
        ])

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(red: 0.87, green: 0.15, blue: 0, alpha: 1).cgColor,
                                UIColor(red: 1.0, green: 0.4, blue: 0.2, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = blockNameLabel.bounds
        blockNameLabel.layoutIfNeeded()
        gradientLayer.frame = blockNameLabel.bounds

        let gradientImage = UIGraphicsImageRenderer(bounds: gradientLayer.bounds).image { context in
            gradientLayer.render(in: context.cgContext)
        }
        blockNameLabel.textColor = UIColor(patternImage: gradientImage)

        
        friendsContainer = UIView()
        friendsContainer.backgroundColor = UIColor.darkFaded
        friendsContainer.layer.cornerRadius = 16
        friendsContainer.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(friendsContainer)
        NSLayoutConstraint.activate([
            friendsContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            friendsContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            friendsContainer.bottomAnchor.constraint(equalTo: blockNameLabel.topAnchor,constant: -35),
            friendsContainer.heightAnchor.constraint(equalToConstant: 64)
        ])
        
        friendsAvatarsContainer = UIView()
        friendsAvatarsContainer.backgroundColor = .clear
        friendsAvatarsContainer.translatesAutoresizingMaskIntoConstraints = false
        friendsContainer.addSubview(friendsAvatarsContainer)
        NSLayoutConstraint.activate([
            friendsAvatarsContainer.leadingAnchor.constraint(equalTo: friendsContainer.leadingAnchor, constant: 16),
            friendsAvatarsContainer.widthAnchor.constraint(equalToConstant: 80),
            friendsAvatarsContainer.bottomAnchor.constraint(equalTo: friendsContainer.bottomAnchor,constant: -16),
            friendsAvatarsContainer.topAnchor.constraint(equalTo: friendsContainer.topAnchor,constant: 16),
        ])
        
        let avatarRightImageView = UIImageView()
        avatarRightImageView.image = UIImage(named: "avatar1")
        avatarRightImageView.translatesAutoresizingMaskIntoConstraints = false
        friendsAvatarsContainer.addSubview(avatarRightImageView)
        NSLayoutConstraint.activate([
            avatarRightImageView.trailingAnchor.constraint(equalTo: friendsAvatarsContainer.trailingAnchor),
            avatarRightImageView.heightAnchor.constraint(equalToConstant: 32),
            avatarRightImageView.widthAnchor.constraint(equalToConstant: 32)
        ])
        avatarRightImageView.layer.cornerRadius = 32 / 2
        avatarRightImageView.layer.masksToBounds = true
        
        let avatarCenterImageView = UIImageView()
        avatarCenterImageView.image = UIImage(named: "avatar2")
        avatarCenterImageView.translatesAutoresizingMaskIntoConstraints = false
        friendsAvatarsContainer.addSubview(avatarCenterImageView)
        NSLayoutConstraint.activate([
            avatarCenterImageView.centerXAnchor.constraint(equalTo: friendsAvatarsContainer.centerXAnchor),
            avatarCenterImageView.centerYAnchor.constraint(equalTo: friendsAvatarsContainer.centerYAnchor),
            avatarCenterImageView.heightAnchor.constraint(equalToConstant: 32),
            avatarCenterImageView.widthAnchor.constraint(equalToConstant: 32)
        ])
        avatarCenterImageView.layer.cornerRadius = 32 / 2
        avatarCenterImageView.layer.masksToBounds = true
        
        let avatarLeftImageView = UIImageView()
        avatarLeftImageView.image = UIImage(named: "avatar3")
        avatarLeftImageView.translatesAutoresizingMaskIntoConstraints = false
        friendsAvatarsContainer.addSubview(avatarLeftImageView)
        NSLayoutConstraint.activate([
            avatarLeftImageView.leadingAnchor.constraint(equalTo: friendsAvatarsContainer.leadingAnchor),
            avatarLeftImageView.heightAnchor.constraint(equalToConstant: 32),
            avatarLeftImageView.widthAnchor.constraint(equalToConstant: 32)
        ])
        avatarLeftImageView.layer.cornerRadius = 32 / 2
        avatarLeftImageView.layer.masksToBounds = true
        
        
        let friendsLabel = UILabel()
        friendsLabel.text = "Мои друзья"
        friendsLabel.font = UIFont(name: "Manrope-Medium", size: 16)
        friendsLabel.textColor = .white
        friendsLabel.translatesAutoresizingMaskIntoConstraints = false
        friendsContainer.addSubview(friendsLabel)
        NSLayoutConstraint.activate([
            friendsLabel.leadingAnchor.constraint(equalTo: friendsAvatarsContainer.trailingAnchor, constant: 16),
            friendsLabel.trailingAnchor.constraint(equalTo: friendsContainer.trailingAnchor, constant: -16),
            friendsLabel.bottomAnchor.constraint(equalTo: friendsContainer.bottomAnchor,constant: -16),
            friendsLabel.topAnchor.constraint(equalTo: friendsContainer.topAnchor,constant: 16),
        ])
        
        
        let headerProfileContainer = UIView()
        headerProfileContainer.backgroundColor = .clear
        headerProfileContainer.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(headerProfileContainer)
        NSLayoutConstraint.activate([
            headerProfileContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            headerProfileContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            headerProfileContainer.bottomAnchor.constraint(equalTo: friendsContainer.topAnchor, constant: -35),
            headerProfileContainer.heightAnchor.constraint(equalToConstant: 96)
        ])
        
        avatarImageView = UIImageView()
        avatarImageView.image = UIImage(named: "avatar")
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        headerProfileContainer.addSubview(avatarImageView)
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: headerProfileContainer.leadingAnchor),
            avatarImageView.heightAnchor.constraint(equalToConstant: 96),
            avatarImageView.widthAnchor.constraint(equalToConstant: 96)
        ])
        avatarImageView.layer.cornerRadius = 96 / 2
        avatarImageView.layer.masksToBounds = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGesture)
        
        let signOutButtonView = SignOutButtonView()
        headerProfileContainer.addSubview(signOutButtonView)
        NSLayoutConstraint.activate([
            signOutButtonView.widthAnchor.constraint(equalToConstant: 40),
            signOutButtonView.heightAnchor.constraint(equalToConstant: 40),
            signOutButtonView.trailingAnchor.constraint(equalTo: headerProfileContainer.trailingAnchor),
            signOutButtonView.centerYAnchor.constraint(equalTo: headerProfileContainer.centerYAnchor),
        ])
        signOutButtonView.addTarget(self, action: #selector(sigOutDidTap), for: .touchUpInside)
        
        let helloContainer = UIView()
        helloContainer.backgroundColor = .clear
        helloContainer.translatesAutoresizingMaskIntoConstraints = false
        headerProfileContainer.addSubview(helloContainer)
        NSLayoutConstraint.activate([
            helloContainer.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            helloContainer.centerYAnchor.constraint(equalTo: headerProfileContainer.centerYAnchor),
            helloContainer.trailingAnchor.constraint(equalTo: signOutButtonView.leadingAnchor, constant: -16),
            helloContainer.heightAnchor.constraint(equalToConstant: 84)
        ])
        
        helloTextLabel = UILabel()
        helloTextLabel.text = "Доброе утро,"
        helloTextLabel.font = UIFont(name: "Manrope-Medium", size: 16)
        helloTextLabel.textColor = .white
        helloTextLabel.translatesAutoresizingMaskIntoConstraints = false
        helloContainer.addSubview(helloTextLabel)
        NSLayoutConstraint.activate([
            helloTextLabel.leadingAnchor.constraint(equalTo: helloContainer.leadingAnchor),
            helloTextLabel.trailingAnchor.constraint(equalTo: helloContainer.trailingAnchor),
            helloTextLabel.topAnchor.constraint(equalTo: helloContainer.topAnchor),
            helloTextLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        userNameLabel = UILabel()
        userNameLabel.text = "Васечка Пупкин"
        userNameLabel.font = UIFont(name: "Manrope-Bold", size: 24)
        userNameLabel.textColor = .white
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.numberOfLines = 0
        userNameLabel.lineBreakMode = .byWordWrapping
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.0
        paragraphStyle.minimumLineHeight = 32
        paragraphStyle.maximumLineHeight = 32
        let attributedString = NSAttributedString(string: userNameLabel.text ?? "", attributes: [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: userNameLabel.font as Any,
            NSAttributedString.Key.foregroundColor: userNameLabel.textColor
        ])
        userNameLabel.attributedText = attributedString
        helloContainer.addSubview(userNameLabel)
        NSLayoutConstraint.activate([
            userNameLabel.leadingAnchor.constraint(equalTo: helloContainer.leadingAnchor),
            userNameLabel.trailingAnchor.constraint(equalTo: helloContainer.trailingAnchor),
            userNameLabel.topAnchor.constraint(equalTo: helloTextLabel.bottomAnchor),
            userNameLabel.heightAnchor.constraint(equalToConstant: 64)
        ])
        
        
        
    }
    
    @objc private func sigOutDidTap() {
        viewModel.logOut()
    }
    
}
