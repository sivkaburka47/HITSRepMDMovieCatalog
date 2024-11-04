//
//  MovieRowCell.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 01.11.2024.
//
import UIKit
import SDWebImage

protocol MovieRowCellDelegate: AnyObject {
    func didTapCover(for movieId: String)
}


class MovieRowCell: UITableViewCell {
    static let identifier = "MovieRowCell"
    
    weak var delegate: MovieRowCellDelegate?
    
    private var imageViews: [UIImageView] = []
    private var ratingLabels: [UILabel] = []
    private var favoriteIcons: [UIImageView] = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        for _ in 0..<3 {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 8
            imageView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(imageView)
            imageViews.append(imageView)
            
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 110),
                imageView.heightAnchor.constraint(equalToConstant: 166)
            ])
            
            let ratingLabel = UILabel()
            ratingLabel.textColor = .white
            ratingLabel.font = UIFont(name: "Manrope-Medium", size: 12)
            ratingLabel.textAlignment = .center
            ratingLabel.layer.cornerRadius = 4
            ratingLabel.clipsToBounds = true
            ratingLabel.translatesAutoresizingMaskIntoConstraints = false
            imageView.addSubview(ratingLabel)
            ratingLabels.append(ratingLabel)
            
            NSLayoutConstraint.activate([
                ratingLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 8),
                ratingLabel.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 8),
                ratingLabel.widthAnchor.constraint(equalToConstant: 32),
                ratingLabel.heightAnchor.constraint(equalToConstant: 22)
            ])
            
            let favoriteIcon = UIImageView()
            favoriteIcon.contentMode = .scaleAspectFit
            favoriteIcon.translatesAutoresizingMaskIntoConstraints = false
            imageView.addSubview(favoriteIcon)
            favoriteIcons.append(favoriteIcon)
            
            NSLayoutConstraint.activate([
                favoriteIcon.leadingAnchor.constraint(equalTo: ratingLabel.trailingAnchor, constant: 4),
                favoriteIcon.centerYAnchor.constraint(equalTo: ratingLabel.centerYAnchor),
                favoriteIcon.widthAnchor.constraint(equalToConstant: 22),
                favoriteIcon.heightAnchor.constraint(equalToConstant: 22)
            ])
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(tapGesture)
        }
    }
    
    func configure(with movies: [Movie]) {
        for (index, imageView) in imageViews.enumerated() {
            if index < movies.count {
                let movie = movies[index]
                imageView.sd_setImage(with: movie.coverImageURL, completed: nil)
                
                let averageRating = ((Double(movie.reviews.reduce(0, +)) / Double(movie.reviews.count)) * 10).rounded() / 10
                ratingLabels[index].text = String(format: "%.1f", averageRating)
                
                let redColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
                let greenColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
                
                let normalizedRating = (averageRating - 1.0) / (10.0 - 1.0)
                let backgroundColor = interpolateColor(from: redColor, to: greenColor, with: normalizedRating)
                
                ratingLabels[index].backgroundColor = backgroundColor
                if movie.isFavorite {
                    favoriteIcons[index].image = UIImage(named: "favoriteIcon")
                } else {
                    favoriteIcons[index].image = nil
                }
                
                imageViews[index].accessibilityIdentifier = movie.id
            } else {
                imageView.image = nil
                ratingLabels[index].text = nil
                ratingLabels[index].backgroundColor = .clear
                favoriteIcons[index].image = nil
            }
        }
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        if let coverImageView = sender.view as? UIImageView, let movieId = coverImageView.accessibilityIdentifier {
            delegate?.didTapCover(for: movieId)
        }
    }
    
    private func interpolateColor(from startColor: UIColor, to endColor: UIColor, with fraction: CGFloat) -> UIColor {
        var startRed: CGFloat = 0, startGreen: CGFloat = 0, startBlue: CGFloat = 0, startAlpha: CGFloat = 0
        var endRed: CGFloat = 0, endGreen: CGFloat = 0, endBlue: CGFloat = 0, endAlpha: CGFloat = 0
        
        startColor.getRed(&startRed, green: &startGreen, blue: &startBlue, alpha: &startAlpha)
        endColor.getRed(&endRed, green: &endGreen, blue: &endBlue, alpha: &endAlpha)
        
        let red = startRed + (endRed - startRed) * fraction
        let green = startGreen + (endGreen - startGreen) * fraction
        let blue = startBlue + (endBlue - startBlue) * fraction
        let alpha = startAlpha + (endAlpha - startAlpha) * fraction
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
