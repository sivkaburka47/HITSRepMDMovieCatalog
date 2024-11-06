//
//  FriendsViewController.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 07.11.2024.
//

import UIKit
import SDWebImage

class FriendsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FriendsViewModelDelegate {
    
    private var viewModel: FriendsViewModel!
    private var containerFriends: UICollectionView!
    
    init(viewModel: FriendsViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.dark
        configureHeader()
        configureContainer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
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
        titleLabel.text = "Мои друзья"
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
    
    private func configureContainer() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 24
        layout.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        
        containerFriends = UICollectionView(frame: .zero, collectionViewLayout: layout)
        containerFriends.translatesAutoresizingMaskIntoConstraints = false
        containerFriends.backgroundColor = .clear
        containerFriends.dataSource = self
        containerFriends.delegate = self
        containerFriends.register(FriendCell.self, forCellWithReuseIdentifier: "FriendCell")
        
        view.addSubview(containerFriends)

        NSLayoutConstraint.activate([
            containerFriends.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerFriends.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerFriends.topAnchor.constraint(equalTo: view.topAnchor, constant: UIApplication.shared.statusBarFrame.height + 96),
            containerFriends.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.friends.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendCell", for: indexPath) as! FriendCell
        let friend = viewModel.friends[indexPath.item]
        cell.configure(with: friend)
        cell.avatarImageView.tag = indexPath.item
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(avatarTapped(_:)))
        cell.avatarImageView.addGestureRecognizer(tapGesture)
        cell.avatarImageView.isUserInteractionEnabled = true
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 48 - 32) / 3
        return CGSize(width: width, height: width + 32)
    }
    
    
    func friendsDidUpdate() {
        containerFriends.reloadData()
    }
    
    
    @objc func avatarTapped(_ sender: UITapGestureRecognizer) {
        if let imageView = sender.view as? UIImageView {
            let index = imageView.tag
            let friend = viewModel.friends[index]
            viewModel.removeFriend(friend: friend)
        }
    }
}


class FriendCell: UICollectionViewCell {
    let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 48
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let nickNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Manrope-Medium", size: 14)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nickNameLabel)
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            avatarImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 96),
            avatarImageView.heightAnchor.constraint(equalToConstant: 96),
            
            nickNameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nickNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nickNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nickNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with friend: Friend) {
        if let avatarURL = URL(string: friend.avatar ?? "") {
            avatarImageView.sd_setImage(with: avatarURL, placeholderImage: UIImage(named: "avatar"))
        } else {
            avatarImageView.image = UIImage(named: "avatar")
        }
        nickNameLabel.text = friend.nickName
    }
}
