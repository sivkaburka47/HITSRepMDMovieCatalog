//
//  FeedScreenViewController.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 15.10.2024.
//

import UIKit
import SDWebImage

class FeedViewController: UIViewController {

    private var headerImageView: UIImageView!
    private var swipeContainerView: UIView!
    private var movieCover: UIImageView!
    private var movieCoverNext: UIImageView!
    private var movieNameLabel: UILabel!
    private var countryAndYearLabel: UILabel!
    private var labelsStackView: UIStackView!
    private var activityIndicator: UIActivityIndicatorView!
    private var dislikeMovieImageView: UIImageView!
    private var likeMovieImageView: UIImageView!
    private var overlayView: UIView!
    
    private var viewModel: FeedViewModel!
    private var isLoading: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.dark
        viewModel = FeedViewModel()
        viewModel.updateUI = { [weak self] in
            self?.updateUI()
        }
        viewModel.showLoadingIndicator = { [weak self] in
            self?.showLoadingIndicator()
        }
        viewModel.hideLoadingIndicator = { [weak self] in
            self?.hideLoadingIndicator()
        }
        configureHeader()
        configureSwipeContainer()
        setupGestures()
        configureActivityIndicator()
        configureOverlayView()
        configureDislikeMovieImageView()
        configureLikeMovieImageView()
        
    }
    
    
    
    private func configureOverlayView() {
        overlayView = GradientOverlayView()
  
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.isHidden = true 
        movieCover.addSubview(overlayView)
        
        NSLayoutConstraint.activate([
            overlayView.leadingAnchor.constraint(equalTo: movieCover.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: movieCover.trailingAnchor),
            overlayView.topAnchor.constraint(equalTo: movieCover.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: movieCover.bottomAnchor)
        ])
        
    }
    
    private func configureDislikeMovieImageView() {
        dislikeMovieImageView = UIImageView(image: UIImage(named: "dislikeMovie"))
        dislikeMovieImageView.contentMode = .scaleAspectFit
        dislikeMovieImageView.translatesAutoresizingMaskIntoConstraints = false
        dislikeMovieImageView.isHidden = true
        overlayView.addSubview(dislikeMovieImageView)
        
        NSLayoutConstraint.activate([
            dislikeMovieImageView.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            dislikeMovieImageView.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
            dislikeMovieImageView.widthAnchor.constraint(equalToConstant: 128),
            dislikeMovieImageView.heightAnchor.constraint(equalToConstant: 128)
        ])
    }
    
    private func configureLikeMovieImageView() {
        likeMovieImageView = UIImageView(image: UIImage(named: "likeMovie"))
        likeMovieImageView.contentMode = .scaleAspectFit
        likeMovieImageView.translatesAutoresizingMaskIntoConstraints = false
        likeMovieImageView.isHidden = true
        overlayView.addSubview(likeMovieImageView)
        
        NSLayoutConstraint.activate([
            likeMovieImageView.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            likeMovieImageView.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
            likeMovieImageView.widthAnchor.constraint(equalToConstant: 128),
            likeMovieImageView.heightAnchor.constraint(equalToConstant: 128)
        ])
    }
    
    private func configureActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: movieCover.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: movieCover.centerYAnchor)
        ])
    }
    
    private func showLoadingIndicator() {
        isLoading = true
        activityIndicator.startAnimating()
        movieCover.isUserInteractionEnabled = false
        movieCoverNext.isUserInteractionEnabled = false
    }
    
    private func hideLoadingIndicator() {
        isLoading = false
        activityIndicator.stopAnimating()
        movieCover.isUserInteractionEnabled = true
        movieCoverNext.isUserInteractionEnabled = true
    }
    
    private func configureHeader() {
        headerImageView = UIImageView(image: UIImage(named: "MDHeaderIcon"))
        headerImageView.contentMode = .scaleAspectFit
        headerImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerImageView)
        NSLayoutConstraint.activate([
            headerImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -16),
            headerImageView.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    private func configureSwipeContainer() {
        swipeContainerView = UIView()
        swipeContainerView.backgroundColor = .clear
        swipeContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(swipeContainerView)
        NSLayoutConstraint.activate([
            swipeContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            swipeContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            swipeContainerView.topAnchor.constraint(equalTo: headerImageView.bottomAnchor, constant: 24),
            swipeContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -88),
        ])
        
        labelsStackView = UIStackView()
        labelsStackView.axis = .horizontal
        labelsStackView.alignment = .center
        labelsStackView.distribution = .fill
        labelsStackView.spacing = 4
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        swipeContainerView.addSubview(labelsStackView)
        
        NSLayoutConstraint.activate([
            labelsStackView.centerXAnchor.constraint(equalTo: swipeContainerView.centerXAnchor),
            labelsStackView.bottomAnchor.constraint(equalTo: swipeContainerView.bottomAnchor),
            labelsStackView.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        let infoContainerView = UIView()
        infoContainerView.translatesAutoresizingMaskIntoConstraints = false
        swipeContainerView.addSubview(infoContainerView)
        NSLayoutConstraint.activate([
            infoContainerView.leadingAnchor.constraint(equalTo: swipeContainerView.leadingAnchor),
            infoContainerView.trailingAnchor.constraint(equalTo: swipeContainerView.trailingAnchor),
            infoContainerView.heightAnchor.constraint(equalToConstant: 52),
            infoContainerView.bottomAnchor.constraint(equalTo: labelsStackView.topAnchor, constant: -12)
        ])
        
        movieNameLabel = UILabel()
        movieNameLabel.font = UIFont(name: "Manrope-Bold", size: 24)
        movieNameLabel.textColor = .white
        movieNameLabel.lineBreakMode = .byTruncatingTail
        movieNameLabel.numberOfLines = 1
        movieNameLabel.textAlignment = .center
        movieNameLabel.translatesAutoresizingMaskIntoConstraints = false
        infoContainerView.addSubview(movieNameLabel)
        NSLayoutConstraint.activate([
            movieNameLabel.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor),
            movieNameLabel.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor),
            movieNameLabel.topAnchor.constraint(equalTo: infoContainerView.topAnchor),
            movieNameLabel.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        countryAndYearLabel = UILabel()
        countryAndYearLabel.font = UIFont(name: "Manrope-Medium", size: 16)
        countryAndYearLabel.textColor = UIColor.grayCustom
        countryAndYearLabel.translatesAutoresizingMaskIntoConstraints = false
        infoContainerView.addSubview(countryAndYearLabel)
        NSLayoutConstraint.activate([
            countryAndYearLabel.centerXAnchor.constraint(equalTo: infoContainerView.centerXAnchor),
            countryAndYearLabel.topAnchor.constraint(equalTo: movieNameLabel.bottomAnchor),
            countryAndYearLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        movieCoverNext = UIImageView()
        movieCoverNext.translatesAutoresizingMaskIntoConstraints = false
        movieCoverNext.layer.cornerRadius = 16
        movieCoverNext.layer.masksToBounds = true
        swipeContainerView.addSubview(movieCoverNext)
        NSLayoutConstraint.activate([
            movieCoverNext.leadingAnchor.constraint(equalTo: swipeContainerView.leadingAnchor),
            movieCoverNext.trailingAnchor.constraint(equalTo: swipeContainerView.trailingAnchor),
            movieCoverNext.topAnchor.constraint(equalTo: swipeContainerView.topAnchor),
            movieCoverNext.bottomAnchor.constraint(equalTo: infoContainerView.topAnchor, constant: -24)
        ])
        
        movieCover = UIImageView()
        movieCover.translatesAutoresizingMaskIntoConstraints = false
        movieCover.layer.cornerRadius = 16
        movieCover.layer.masksToBounds = true
        swipeContainerView.addSubview(movieCover)
        NSLayoutConstraint.activate([
            movieCover.leadingAnchor.constraint(equalTo: swipeContainerView.leadingAnchor),
            movieCover.trailingAnchor.constraint(equalTo: swipeContainerView.trailingAnchor),
            movieCover.topAnchor.constraint(equalTo: swipeContainerView.topAnchor),
            movieCover.bottomAnchor.constraint(equalTo: infoContainerView.topAnchor, constant: -24)
        ])
    }
    
    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        movieCover.addGestureRecognizer(panGesture)
        movieCover.isUserInteractionEnabled = true
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: movieCover)
        let velocity = gesture.velocity(in: movieCover)
        
        switch gesture.state {
        case .changed:
            let translationX = translation.x
            let rotationAngle = (translationX / movieCover.bounds.width) * CGFloat.pi / 60
            movieCover.transform = CGAffineTransform(translationX: translationX, y: 0).rotated(by: rotationAngle)
            
            if translationX < 0 {
                overlayView.isHidden = false
                (overlayView as? GradientOverlayView)?.setGradientVisible(false)
                overlayView.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 0.5)
                dislikeMovieImageView.isHidden = false
                likeMovieImageView.isHidden = true
            } else {
                overlayView.isHidden = false
                overlayView.backgroundColor = .clear
                (overlayView as? GradientOverlayView)?.setGradientVisible(true)
                dislikeMovieImageView.isHidden = true
                likeMovieImageView.isHidden = false
            }
            
        case .ended:
            if velocity.x > 0 {
                animateSwipe(toRight: true)
            } else {
                animateSwipe(toRight: false)
            }
            
        default:
            break
        }
    }
    
    private func animateSwipe(toRight: Bool) {
        let translationX = toRight ? view.bounds.width : -view.bounds.width
        
        UIView.animate(withDuration: 0.3, animations: {
            self.movieCover.transform = CGAffineTransform(translationX: translationX, y: 0).rotated(by: toRight ? CGFloat.pi / 60 : -CGFloat.pi / 60)
        }) { _ in
            self.movieCover.frame.origin.x = toRight ? self.view.bounds.width : -self.view.bounds.width
            self.movieCover.transform = .identity
            self.movieCover.frame.origin.x = 0
            self.dislikeMovieImageView.isHidden = true
            self.likeMovieImageView.isHidden = true
            self.overlayView.backgroundColor = .clear
            (self.overlayView as? GradientOverlayView)?.setGradientVisible(false)
            self.overlayView.isHidden = true
            if !toRight {
                self.viewModel.addToDislikeMovies()
            }
            else {
                self.viewModel.addToFavorites { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            print("Фильм успешно добавлен в избранное")
                        case .failure(let error):
                            print("Ошибка при добавлении фильма в избранное: \(error)")
                        }
                    }
                }
            }
            self.updateUI()
        }
    }
    
    private func updateUI() {
        guard let movie = viewModel.getCurrentMovie() else { return }
        
        viewModel.loadNextMovie()
        
        movieCover.sd_setImage(with: movie.coverImageURL, completed: nil)
        
        movieNameLabel.text = movie.title
        countryAndYearLabel.text = "\(movie.country) • \(movie.year)"
        updateGenres(movie.genres)
        
        guard let nextMovie = viewModel.getCurrentMovie() else { return }
        
        movieCoverNext.sd_setImage(with: nextMovie.coverImageURL, completed: nil)
    }

    private func updateGenres(_ genres: [String]) {
        for subview in labelsStackView.arrangedSubviews {
            subview.removeFromSuperview()
        }
        
        let genresToShow = genres.prefix(3)
        
        for genre in genresToShow {
            let labelContainer = UIView()
            labelContainer.backgroundColor = UIColor.darkFaded
            labelContainer.layer.cornerRadius = 8
            labelContainer.translatesAutoresizingMaskIntoConstraints = false
            
            let label = UILabel()
            label.text = genre
            label.font = UIFont(name: "Manrope-Medium", size: 16)
            label.textColor = .white
            label.translatesAutoresizingMaskIntoConstraints = false
            
            labelContainer.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: labelContainer.leadingAnchor, constant: 12),
                label.trailingAnchor.constraint(equalTo: labelContainer.trailingAnchor, constant: -12),
                label.topAnchor.constraint(equalTo: labelContainer.topAnchor, constant: 4),
                label.bottomAnchor.constraint(equalTo: labelContainer.bottomAnchor, constant: -4)
            ])
            
            labelsStackView.addArrangedSubview(labelContainer)
        }
    }
}
