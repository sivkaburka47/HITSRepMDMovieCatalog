//
//  MoviesViewController.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 22.10.2024.
//

import UIKit
import SDWebImage

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MovieRowCellDelegate {
    
    private var viewModel: MoviesViewModel!
    
    private var tableView: UITableView!
    
    private var favoritesCarousel: UICollectionView!
    
    private var images: [URL] = []
    
    private var gameDieButton: GameDieButtonView!
    private var labelsStackViewTop: UIStackView!
    private var labelsStackViewBottom: UIStackView!
    private var movieNameLabel: UILabel!
    private var carouselStackView: UIStackView!
    private var carouselContainer: UIImageView!
    private var containerView: UIView!
    private var progressViews: [UIView] = []
    private var progressFillViews: [UIView] = []
    private var progressFillWidthConstraints: [NSLayoutConstraint] = []
    private var currentStep = 0
    private var timer: Timer?
    private let totalSteps = 5
    private var currentProgress = 0.0
    private var activityIndicator: UIActivityIndicatorView!
    
    private var fadeOutTop: UIView!
    private var fadeOutBottom: UIView!
    
    init(appRouter: AppRouter) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = MoviesViewModel(appRouter: appRouter)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = UIColor.dark
        configureContainer()
        configureCarousel()
        configureGameDieButton()
        configureFavouritesCarousel()

        configureActivityIndicator()
        activityIndicator.startAnimating()
        viewModel.fetchMoviesForCarousel { [weak self] in
            DispatchQueue.main.async {
                self?.startProgressTimer()
                self?.activityIndicator.stopAnimating()
            }
        }
        
        viewModel.fetchFavorites { [weak self] in
            DispatchQueue.main.async {
                self?.images = self?.viewModel.getMoviesForFavoritesCarousel().map { $0.coverImageURL } ?? []
                self?.favoritesCarousel.reloadData()
            }
        }
        
        configureAllMoviesContainer()
    }

    @objc private func handleCarouselTap(_ gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: carouselContainer)
        let containerWidth = carouselContainer.bounds.width
        
        if tapLocation.x < containerWidth / 2 {
            if currentStep == 0 {
                currentStep = totalSteps - 1
            } else {
                currentStep -= 1
            }
        } else {
            currentStep = (currentStep + 1) % totalSteps
        }
        
        currentProgress = 0.0
        updateCarouselMovie()
        updateProgress(to: currentStep)
    }

    private func configureActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        carouselContainer.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: carouselContainer.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: carouselContainer.centerYAnchor)
        ])
    }

    private func configureContainer() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
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
            containerView.heightAnchor.constraint(equalToConstant: 1427)
        ])
    }
    
    private func configureCarousel() {
        carouselContainer = UIImageView()
        carouselContainer.clipsToBounds = true
        carouselContainer.layer.cornerRadius = 24
        carouselContainer.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        carouselContainer.translatesAutoresizingMaskIntoConstraints = false
        carouselContainer.contentMode = .scaleAspectFill
        
        containerView.addSubview(carouselContainer)
        NSLayoutConstraint.activate([
            carouselContainer.topAnchor.constraint(equalTo: containerView.topAnchor),
            carouselContainer.heightAnchor.constraint(equalToConstant: 464),
            carouselContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            carouselContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCarouselTap(_:)))
        carouselContainer.isUserInteractionEnabled = true
        carouselContainer.addGestureRecognizer(tapGesture)
        configureFadeOutOverlays()
        
        carouselStackView = UIStackView()
        carouselStackView.backgroundColor = .clear
        carouselStackView.axis = .horizontal
        carouselStackView.spacing = 4
        carouselStackView.distribution = .fillEqually
        carouselStackView.translatesAutoresizingMaskIntoConstraints = false
        carouselContainer.addSubview(carouselStackView)
        NSLayoutConstraint.activate([
            carouselStackView.topAnchor.constraint(equalTo: carouselContainer.topAnchor, constant: UIApplication.shared.statusBarFrame.height + 4),
            carouselStackView.trailingAnchor.constraint(equalTo: carouselContainer.trailingAnchor, constant: -24),
            carouselStackView.leadingAnchor.constraint(equalTo: carouselContainer.leadingAnchor, constant: 24),
            carouselStackView.heightAnchor.constraint(equalToConstant: 4)
        ])
        
        for _ in 0..<totalSteps {
            let lineView = UIView()
            lineView.backgroundColor = .grayCustom
            lineView.layer.cornerRadius = 4
            lineView.translatesAutoresizingMaskIntoConstraints = false
            carouselStackView.addArrangedSubview(lineView)
            NSLayoutConstraint.activate([
                lineView.heightAnchor.constraint(equalTo: carouselStackView.heightAnchor)
            ])
            progressViews.append(lineView)
            
            let fillView = UIView()
            fillView.layer.cornerRadius = 4
            fillView.clipsToBounds = true
            fillView.translatesAutoresizingMaskIntoConstraints = false
            lineView.addSubview(fillView)
            NSLayoutConstraint.activate([
                fillView.leadingAnchor.constraint(equalTo: lineView.leadingAnchor),
                fillView.topAnchor.constraint(equalTo: lineView.topAnchor),
                fillView.bottomAnchor.constraint(equalTo: lineView.bottomAnchor),
            ])
            let widthConstraint = fillView.widthAnchor.constraint(equalToConstant: 0)
            widthConstraint.isActive = true
            progressFillViews.append(fillView)
            progressFillWidthConstraints.append(widthConstraint)

            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [UIColor(red: 223/255, green: 40/255, blue: 0/255, alpha: 1).cgColor,
                                    UIColor(red: 255/255, green: 102/255, blue: 51/255, alpha: 1).cgColor]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            gradientLayer.frame = fillView.bounds
            fillView.layer.addSublayer(gradientLayer)
        }
        
        let infoBlock = UIView()
        infoBlock.backgroundColor = .clear
        infoBlock.translatesAutoresizingMaskIntoConstraints = false
        carouselContainer.addSubview(infoBlock)
        NSLayoutConstraint.activate([
            infoBlock.leadingAnchor.constraint(equalTo: carouselContainer.leadingAnchor, constant: 24),
            infoBlock.trailingAnchor.constraint(equalTo: carouselContainer.trailingAnchor, constant: -24),
            infoBlock.bottomAnchor.constraint(equalTo: carouselContainer.bottomAnchor, constant: -24),
            infoBlock.heightAnchor.constraint(equalToConstant: 118)
        ])
        
        movieNameLabel = UILabel()
        movieNameLabel.font = UIFont(name: "Manrope-Bold", size: 36)
        movieNameLabel.textColor = .white
        movieNameLabel.lineBreakMode = .byTruncatingTail
        movieNameLabel.numberOfLines = 1
        movieNameLabel.textAlignment = .left
        movieNameLabel.translatesAutoresizingMaskIntoConstraints = false
        infoBlock.addSubview(movieNameLabel)
        NSLayoutConstraint.activate([
            movieNameLabel.leadingAnchor.constraint(equalTo: infoBlock.leadingAnchor),
            movieNameLabel.trailingAnchor.constraint(equalTo: infoBlock.trailingAnchor),
            movieNameLabel.topAnchor.constraint(equalTo: infoBlock.topAnchor),
            movieNameLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        labelsStackViewBottom = UIStackView()
        labelsStackViewBottom.axis = .horizontal
        labelsStackViewBottom.alignment = .leading
        labelsStackViewBottom.distribution = .fillProportionally
        labelsStackViewBottom.spacing = 4
        labelsStackViewBottom.translatesAutoresizingMaskIntoConstraints = false
        infoBlock.addSubview(labelsStackViewBottom)
        
        NSLayoutConstraint.activate([
            labelsStackViewBottom.leadingAnchor.constraint(equalTo: infoBlock.leadingAnchor),
            labelsStackViewBottom.bottomAnchor.constraint(equalTo: infoBlock.bottomAnchor),
            labelsStackViewBottom.heightAnchor.constraint(equalToConstant: 28),
        ])
        
        labelsStackViewTop = UIStackView()
        labelsStackViewTop.axis = .horizontal
        labelsStackViewTop.alignment = .leading
        labelsStackViewTop.distribution = .fillProportionally
        labelsStackViewTop.spacing = 4
        labelsStackViewTop.translatesAutoresizingMaskIntoConstraints = false
        infoBlock.addSubview(labelsStackViewTop)
        
        NSLayoutConstraint.activate([
            labelsStackViewTop.leadingAnchor.constraint(equalTo: infoBlock.leadingAnchor),
            labelsStackViewTop.bottomAnchor.constraint(equalTo: labelsStackViewBottom.topAnchor, constant: -4),
            labelsStackViewTop.heightAnchor.constraint(equalToConstant: 28),
        ])
        
        let lookButton = ButtonView(title: "Смотреть", color: .orange)
        lookButton.translatesAutoresizingMaskIntoConstraints = false
        infoBlock.addSubview(lookButton)
        NSLayoutConstraint.activate([
            lookButton.heightAnchor.constraint(equalToConstant: 48),
            lookButton.widthAnchor.constraint(equalToConstant: 118),
            lookButton.trailingAnchor.constraint(equalTo: infoBlock.trailingAnchor),
            lookButton.bottomAnchor.constraint(equalTo: infoBlock.bottomAnchor),
        ])
        lookButton.addTarget(self, action: #selector(lookButtonTapped), for: .touchUpInside)
        
        updateProgress(to: currentStep)
    }
    
    private func configureGameDieButton() {
        gameDieButton = GameDieButtonView(title: "Случайный фильм", color: .orange)
        gameDieButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(gameDieButton)
        NSLayoutConstraint.activate([
            gameDieButton.heightAnchor.constraint(equalToConstant: 96),
            gameDieButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            gameDieButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            gameDieButton.topAnchor.constraint(equalTo: carouselContainer.bottomAnchor, constant: 32),
        ])
        gameDieButton.addTarget(self, action: #selector(didTapGameDieButton), for: .touchUpInside)
    }
    
    @objc private func lookButtonTapped() {
        viewModel.getCarouselMoviesDetails()
    }
    
    @objc private func didTapGameDieButton() {
        viewModel.getRandMovieDetails()
    }
    
    private func configureFavouritesCarousel() {
        let headerFavouritesCarousel = UIView()

        headerFavouritesCarousel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(headerFavouritesCarousel)
        NSLayoutConstraint.activate([
            headerFavouritesCarousel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            headerFavouritesCarousel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            headerFavouritesCarousel.topAnchor.constraint(equalTo: gameDieButton.bottomAnchor, constant: 32),
            headerFavouritesCarousel.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        let likedLabel = UILabel()
        likedLabel.text = "Мне нравится"
        likedLabel.font = UIFont(name: "Manrope-Bold", size: 20)
        likedLabel.textColor = UIColor.grayCustom
        likedLabel.textAlignment = .left
        likedLabel.translatesAutoresizingMaskIntoConstraints = false
        headerFavouritesCarousel.addSubview(likedLabel)
        NSLayoutConstraint.activate([
            likedLabel.leadingAnchor.constraint(equalTo: headerFavouritesCarousel.leadingAnchor),
            likedLabel.centerYAnchor.constraint(equalTo: headerFavouritesCarousel.centerYAnchor),
        ])

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(red: 0.87, green: 0.15, blue: 0, alpha: 1).cgColor,
                                UIColor(red: 1.0, green: 0.4, blue: 0.2, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = likedLabel.bounds
        likedLabel.layoutIfNeeded()
        gradientLayer.frame = likedLabel.bounds

        let gradientImage = UIGraphicsImageRenderer(bounds: gradientLayer.bounds).image { context in
            gradientLayer.render(in: context.cgContext)
        }
        likedLabel.textColor = UIColor(patternImage: gradientImage)
        
        
        let allLabel = UILabel()
        allLabel.text = "Все"
        allLabel.font = UIFont(name: "Manrope-Bold", size: 20)
        allLabel.textColor = UIColor.grayCustom
        allLabel.textAlignment = .right
        allLabel.translatesAutoresizingMaskIntoConstraints = false
        headerFavouritesCarousel.addSubview(allLabel)
        NSLayoutConstraint.activate([
            allLabel.trailingAnchor.constraint(equalTo: headerFavouritesCarousel.trailingAnchor),
            allLabel.centerYAnchor.constraint(equalTo: headerFavouritesCarousel.centerYAnchor),
        ])
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        
        favoritesCarousel = UICollectionView(frame: .zero, collectionViewLayout: layout)
        favoritesCarousel.translatesAutoresizingMaskIntoConstraints = false
        favoritesCarousel.backgroundColor = .clear
        favoritesCarousel.showsHorizontalScrollIndicator = false
        
        favoritesCarousel.delegate = self
        favoritesCarousel.dataSource = self
        favoritesCarousel.register(FavoriteCell.self, forCellWithReuseIdentifier: FavoriteCell.identifier)
        
        view.addSubview(favoritesCarousel)
        
        NSLayoutConstraint.activate([
            favoritesCarousel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            favoritesCarousel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            favoritesCarousel.topAnchor.constraint(equalTo: headerFavouritesCarousel.bottomAnchor, constant: 16),
            favoritesCarousel.heightAnchor.constraint(equalToConstant: 252)
        ])
        
    }
    
    private func configureAllMoviesContainer() {
        let headerAllMovies = UIView()

        headerAllMovies.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(headerAllMovies)
        NSLayoutConstraint.activate([
            headerAllMovies.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            headerAllMovies.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            headerAllMovies.topAnchor.constraint(equalTo: favoritesCarousel.bottomAnchor, constant: 32),
            headerAllMovies.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        let allMoviesLabel = UILabel()
        allMoviesLabel.text = "Все фильмы"
        allMoviesLabel.font = UIFont(name: "Manrope-Bold", size: 20)
        allMoviesLabel.textColor = UIColor.grayCustom
        allMoviesLabel.textAlignment = .left
        allMoviesLabel.translatesAutoresizingMaskIntoConstraints = false
        headerAllMovies.addSubview(allMoviesLabel)
        NSLayoutConstraint.activate([
            allMoviesLabel.leadingAnchor.constraint(equalTo: headerAllMovies.leadingAnchor),
            allMoviesLabel.centerYAnchor.constraint(equalTo: headerAllMovies.centerYAnchor),
        ])

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(red: 0.87, green: 0.15, blue: 0, alpha: 1).cgColor,
                                UIColor(red: 1.0, green: 0.4, blue: 0.2, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = allMoviesLabel.bounds
        allMoviesLabel.layoutIfNeeded()
        gradientLayer.frame = allMoviesLabel.bounds

        let gradientImage = UIGraphicsImageRenderer(bounds: gradientLayer.bounds).image { context in
            gradientLayer.render(in: context.cgContext)
        }
        allMoviesLabel.textColor = UIColor(patternImage: gradientImage)
        
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(MovieRowCell.self, forCellReuseIdentifier: MovieRowCell.identifier)
        containerView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerAllMovies.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        viewModel.fetchAllMovies { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    private func startProgressTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if floor(self.currentProgress) == self.currentProgress {
                self.updateCarouselMovie()
            }
            self.currentProgress += 0.1 / 5.0
            if self.currentProgress >= 1.0 {
                self.currentProgress = 0.0
                self.currentStep += 1
                
                if self.currentStep >= self.totalSteps {
                    self.currentStep = 0
                }
            }
            self.updateProgress(to: self.currentStep)
        }
    }
    
    private func updateProgress(to step: Int) {
        for (index, view) in progressViews.enumerated() {
            if let fillView = progressFillViews[safe: index], let widthConstraint = progressFillWidthConstraints[safe: index] {
                if index < step {
                    widthConstraint.constant = view.frame.width
                } else if index == step {
                    let newWidth = view.frame.width * CGFloat(currentProgress)
                    UIView.animate(withDuration: 0.1) {
                        widthConstraint.constant = newWidth
                        fillView.layoutIfNeeded()
                    }
                } else {
                    widthConstraint.constant = 0
                }
                
                if let gradientLayer = fillView.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer {
                    gradientLayer.frame = fillView.bounds
                }
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func updateCarouselMovie() {
        guard let movie = viewModel.getCurrentMovieForCarousel(index: currentStep) else { return }
        carouselContainer.sd_setImage(with: movie.coverImageURL, completed: nil)
        movieNameLabel.text = movie.title
        updateGenres(movie.genres)
    }
    
    private func configureFadeOutOverlays() {
        fadeOutTop = UIView()
        fadeOutTop.backgroundColor = .clear
        fadeOutTop.translatesAutoresizingMaskIntoConstraints = false

        let topGradientLayer = CAGradientLayer()
        topGradientLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 80)
        topGradientLayer.colors = [UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1).cgColor,
                                   UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 0).cgColor]
        topGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        topGradientLayer.endPoint = CGPoint(x: 0, y: 1)
        fadeOutTop.layer.insertSublayer(topGradientLayer, at: 0)

        carouselContainer.addSubview(fadeOutTop)
        NSLayoutConstraint.activate([
            fadeOutTop.topAnchor.constraint(equalTo: carouselContainer.topAnchor),
            fadeOutTop.leadingAnchor.constraint(equalTo: carouselContainer.leadingAnchor),
            fadeOutTop.trailingAnchor.constraint(equalTo: carouselContainer.trailingAnchor),
            fadeOutTop.heightAnchor.constraint(equalToConstant: 80)
        ])

        fadeOutBottom = UIView()
        fadeOutBottom.backgroundColor = .clear
        fadeOutBottom.translatesAutoresizingMaskIntoConstraints = false

        let bottomGradientLayer = CAGradientLayer()
        bottomGradientLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 148)
        bottomGradientLayer.colors = [UIColor(red: 26/255, green: 26/255, blue: 26/255, alpha: 0).cgColor,
                                      UIColor(red: 26/255, green: 26/255, blue: 26/255, alpha: 1).cgColor]
        bottomGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        bottomGradientLayer.endPoint = CGPoint(x: 0, y: 1)
        fadeOutBottom.layer.insertSublayer(bottomGradientLayer, at: 0)

        carouselContainer.addSubview(fadeOutBottom)
        NSLayoutConstraint.activate([
            fadeOutBottom.bottomAnchor.constraint(equalTo: carouselContainer.bottomAnchor),
            fadeOutBottom.leadingAnchor.constraint(equalTo: carouselContainer.leadingAnchor),
            fadeOutBottom.trailingAnchor.constraint(equalTo: carouselContainer.trailingAnchor),
            fadeOutBottom.heightAnchor.constraint(equalToConstant: 148)
        ])
    }
    
    private func updateGenres(_ genres: [String]) {
        for subview in labelsStackViewTop.arrangedSubviews {
            subview.removeFromSuperview()
        }
        for subview in labelsStackViewBottom.arrangedSubviews {
            subview.removeFromSuperview()
        }
        
        var totalWidthTopLine = 0
        var totalWidthBottomLine = 0
        var totalGenresCount = 0
        
        for genre in genres {
            let labelContainer = UIView()
            labelContainer.backgroundColor = UIColor.darkFaded
            labelContainer.layer.cornerRadius = 8
            labelContainer.translatesAutoresizingMaskIntoConstraints = false
            
            let label = UILabel()
            label.text = genre
            label.font = UIFont(name: "Manrope-Medium", size: 16)
            label.textColor = .white
            label.translatesAutoresizingMaskIntoConstraints = false
            let labelWidth = Int(label.intrinsicContentSize.width) + 24
            
            NSLayoutConstraint.activate([
                labelContainer.widthAnchor.constraint(equalToConstant: label.intrinsicContentSize.width + 24),
            ])
            
            labelContainer.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: labelContainer.leadingAnchor, constant: 12),
                label.trailingAnchor.constraint(equalTo: labelContainer.trailingAnchor, constant: -12),
                label.topAnchor.constraint(equalTo: labelContainer.topAnchor, constant: 4),
                label.bottomAnchor.constraint(equalTo: labelContainer.bottomAnchor, constant: -4)
            ])
            if totalGenresCount < 3 {
                if totalWidthTopLine + labelWidth <= 211 {
                    labelsStackViewTop.addArrangedSubview(labelContainer)
                    totalWidthTopLine += labelWidth
                } else if totalWidthBottomLine + labelWidth <= 211 {
                    labelsStackViewBottom.addArrangedSubview(labelContainer)
                    totalWidthBottomLine += labelWidth
                }
                totalGenresCount += 1
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (viewModel.getAllMovies().count ) / 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieRowCell.identifier, for: indexPath) as! MovieRowCell
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        let startIndex = indexPath.row * 3
        let endIndex = min(startIndex + 3, viewModel.getAllMovies().count)
        let movies = Array(viewModel.getAllMovies()[startIndex..<endIndex])
        cell.configure(with: movies)
        cell.delegate = self
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let startIndex = (indexPath.row + 1) * 3
        viewModel.loadNextPageIfNeeded(currentIndex: startIndex) { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    func didTapCover(for movieId: String) {
        viewModel.getAllMoviesDetails(id: movieId)
    }
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension MoviesViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoriteCell.identifier, for: indexPath) as! FavoriteCell
        if let imageURL = images[safe: indexPath.item] {
            cell.imageView.sd_setImage(with: imageURL, completed: nil)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let isMainCell = indexPath.item == 0 || (collectionView.contentOffset.x > CGFloat(indexPath.item) * (138 + 8))
        return isMainCell ? CGSize(width: 166, height: 252) : CGSize(width: 138, height: 238)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let firstVisibleIndexPath = favoritesCarousel.indexPathsForVisibleItems.sorted().first else { return }
        favoritesCarousel.reloadItems(at: [firstVisibleIndexPath])
    }
}

