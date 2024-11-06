//
//  DetailsView.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 02.11.2024.
//

import SwiftUI

struct DetailsView: View {
    @State private var showAddReviewPopup = false
    @ObservedObject var viewModel: DetailsViewModel
    @State var idRandMovie: String
    @State private var currentReviewIndex: Int = 0
    var onBack: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.dark.edgesIgnoringSafeArea(.all)
                if let movieDetails = viewModel.movieDetails, let posterURL = URL(string: movieDetails.poster ?? "") {
                    AsyncImage(url: posterURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: geometry.size.width, height: 464)
                                .position(x: geometry.size.width / 2, y: 232)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: 464)
                                .clipped()
                                .cornerRadius(32)
                                .position(x: geometry.size.width / 2, y: 232)
                                .edgesIgnoringSafeArea(.top)
                        case .failure:
                            Image(systemName: "xmark.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.red)
                                .position(x: geometry.size.width / 2, y: 232)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                
                VStack {
                    HStack {
                        Button(action: {
                            onBack()
                        }) {
                            Image("ChevronLeft")
                                .renderingMode(.template)
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                                .background(Color.darkFaded)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        Spacer()
                        Button(action: {
                            viewModel.toggleFavorite()
                        }) {
                            Image(viewModel.isFavorite ? "like" : "notlike")
                                .renderingMode(.template)
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                                .background(
                                    Group {
                                        if viewModel.isFavorite {
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color(hex: "#DF2800"), Color(hex: "#FF6633")]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        } else {
                                            Color.darkFaded
                                        }
                                    }
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(.horizontal, 24)
                    if viewModel.isLoading {
                        ProgressView("Загрузка данных...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .foregroundColor(.white)
                    } else if let movieDetails = viewModel.movieDetails {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                Spacer().frame(height: 280)
                                VStack(alignment: .leading) {
                                    if let name = movieDetails.name {
                                        Text(name)
                                            .font(.custom("Manrope-Bold", size: 36))
                                            .foregroundColor(.white)
                                    }
                                    if let tagLine = movieDetails.tagline {
                                        Text(tagLine)
                                            .font(.custom("Manrope-Regular", size: 20))
                                            .foregroundColor(.white)
                                    }

                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(hex: "#DF2800"), Color(hex: "#FF6633")]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                
                                if viewModel.getFriendCount(forMovieId: idRandMovie) > 0 {
                                    VStack(alignment: .leading) {
                                        HStack(spacing: 8) {
                                            Image("avatarcombo")
                                                .resizable()
                                                .frame(width: 80, height: 32)
                                            Text("нравится \(viewModel.getFriendCount(forMovieId: idRandMovie)) вашим друзьям")
                                                .font(.custom("Manrope-Medium", size: 16))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .padding(16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(.darkFaded)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                                
                                
                                VStack(alignment: .leading) {
                                    if let description = movieDetails.description {
                                        Text(description)
                                            .font(.custom("Manrope-Medium", size: 16))
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.darkFaded)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                
                                VStack(alignment: .leading) {
                                    if let averageRating = viewModel.averageRating {
                                        HStack {
                                            Image("ratingIcon")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Text("Рейтинг")
                                                .font(.custom("Manrope-Medium", size: 16))
                                                .foregroundColor(.grayCustom)
                                        }

                                        HStack(spacing: 8) {

                                        HStack(spacing: 8) {
                                            Image("MDHeaderIcon")
                                                    .resizable()
                                                    .frame(width: 40, height: 21)
                                            Text(averageRating)
                                                .font(.custom("Manrope-Bold", size: 20))
                                                .foregroundColor(.white)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                                            .background(.dark)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            
                                            if let kinopoiskRating = viewModel.filmKinopoisk?.ratingKinopoisk {
                                                HStack(spacing: 8) {
                                                    Image("klogo")
                                                        .resizable()
                                                        .frame(width: 24, height: 24)
                                                    Text(String(format: "%.1f", kinopoiskRating))
                                                        .font(.custom("Manrope-Bold", size: 20))
                                                        .foregroundColor(.white)
                                                }
                                                .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                                                .background(.dark)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                            }
                                            if let imdbRating = viewModel.filmKinopoisk?.ratingImdb {
                                                HStack(spacing: 8) {
                                                    Image("imdblogo")
                                                        .resizable()
                                                        .frame(width: 24, height: 24)
                                                    Text(String(format: "%.1f", imdbRating))
                                                        .font(.custom("Manrope-Bold", size: 20))
                                                        .foregroundColor(.white)
                                                }
                                                .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                                                .background(.dark)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                            }
                                            
                                        }
                                        
                                    }
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.darkFaded)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                
                                
                                //Информация
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image("informationlogo")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        Text("Информация")
                                            .font(.custom("Manrope-Medium", size: 16))
                                            .foregroundColor(.grayCustom)
                                    }
                                    
                                    HStack {
                                        if let country = movieDetails.country {
                                            VStack(alignment: .leading) {
                                                Text("Страны")
                                                    .font(.custom("Manrope-Regular", size: 14))
                                                    .foregroundColor(.grayCustom)
                                                Text(country)
                                                    .font(.custom("Manrope-Medium", size: 16))
                                                    .foregroundColor(.white)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                                            .background(.dark)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        }
                                        VStack(alignment: .leading) {
                                            Text("Возраст")
                                                .font(.custom("Manrope-Regular", size: 14))
                                                .foregroundColor(.grayCustom)
                                            Text(String(movieDetails.ageLimit) + "+")
                                                .font(.custom("Manrope-Medium", size: 16))
                                                .foregroundColor(.white)
                                        }
                                        .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                                        .background(.dark)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                    
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("Время")
                                                .font(.custom("Manrope-Regular", size: 14))
                                                .foregroundColor(.grayCustom)
                                            
                                            Text("\(movieDetails.time / 60) ч \(movieDetails.time % 60) мин")
                                                .font(.custom("Manrope-Medium", size: 16))
                                                .foregroundColor(.white)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                                        .background(.dark)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        
                                        VStack(alignment: .leading) {
                                            Text("Год выхода")
                                                .font(.custom("Manrope-Regular", size: 14))
                                                .foregroundColor(.grayCustom)
                                            Text(String(movieDetails.year))
                                                .font(.custom("Manrope-Medium", size: 16))
                                                .foregroundColor(.white)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                                        .background(.dark)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.darkFaded)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                
                                //Режиссер
                                VStack(alignment: .leading) {
                                    HStack {
                                        Image("directorlogo")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        Text("Режиссер")
                                            .font(.custom("Manrope-Medium", size: 16))
                                            .foregroundColor(.grayCustom)
                                    }
                                    HStack (spacing: 8){
                                        if let director = viewModel.director, let posterURL = URL(string: director.posterUrl ?? "") {
                                            AsyncImage(url: posterURL) { phase in
                                                switch phase {
                                                case .empty:
                                                    ProgressView()
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 48, height: 48)
                                                        .clipShape(Circle())
                                                case .failure:
                                                    Image(systemName: "xmark.circle")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 48, height: 48)
                                                        .foregroundColor(.red)
                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }
                                        }
                                        Text(viewModel.movieDetails?.director ?? "")
                                            .font(.custom("Manrope-Medium", size: 16))
                                            .foregroundColor(.white)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                                    .background(.dark)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.darkFaded)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                
                                
                                //жанры
                                VStack(alignment: .leading) {
                                    if let genres = viewModel.movieDetails?.genres {
                                        HStack {
                                            Image("genrelogo")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Text("Жанры")
                                                .font(.custom("Manrope-Medium", size: 16))
                                                .foregroundColor(.grayCustom)
                                        }

                                        VStack(alignment: .leading, spacing: 8) {
                                            ForEach(0..<genres.count, id: \.self) { index in
                                                if index % 3 == 0 {
                                                    HStack(spacing: 8) {
                                                        ForEach(index..<min(index + 3, genres.count), id: \.self) { innerIndex in
                                                            if let genreName = genres[innerIndex].name {
                                                                Text(genreName)
                                                                    .font(.custom("Manrope-Medium", size: 16))
                                                                    .foregroundColor(.white)
                                                                    .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                                                                    .background(.dark)
                                                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.darkFaded)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                
                                //финансы
                                VStack(alignment: .leading) {
                                    HStack {
                                        Image("directorlogo")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        Text("Финансы")
                                            .font(.custom("Manrope-Medium", size: 16))
                                            .foregroundColor(.grayCustom)
                                    }
                                    HStack (spacing: 8){
                                        VStack(alignment: .leading) {
                                            Text("Бюджет")
                                                .font(.custom("Manrope-Regular", size: 14))
                                                .foregroundColor(.grayCustom)
                                            
                                            Text("$ \(String(movieDetails.budget ?? 0).withGroupingSeparator())")
                                                .font(.custom("Manrope-Medium", size: 16))
                                                .foregroundColor(.white)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                                        .background(.dark)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        
                                        VStack(alignment: .leading) {
                                            Text("Сборы в мире")
                                                .font(.custom("Manrope-Regular", size: 14))
                                                .foregroundColor(.grayCustom)
                                            Text("$ \(String(movieDetails.fees ?? 0).withGroupingSeparator())")
                                                .font(.custom("Manrope-Medium", size: 16))
                                                .foregroundColor(.white)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                                        .background(.dark)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.darkFaded)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                
                                
                                //отзывы
                                VStack(alignment: .leading) {
                                    if let reviews = viewModel.movieDetails?.reviews {
                                        HStack {
                                            Image("reviewlogo")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Text("Отзывы")
                                                .font(.custom("Manrope-Medium", size: 16))
                                                .foregroundColor(.grayCustom)
                                        }

                                        VStack(alignment: .leading, spacing: 8) {
                                            let review = reviews[currentReviewIndex]
                                            VStack(alignment: .leading, spacing: 12) {
                                                HStack {
                                                    if review.isAnonymous {
                                                        Image("anonym")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 32, height: 32)
                                                        VStack(alignment: .leading) {
                                                            Text("Анонимный пользователь")
                                                                .font(.custom("Manrope-Medium", size: 12))
                                                                .foregroundColor(.white)
                                                            Text(formattedDate(from: review.createDateTime))
                                                                .font(.custom("Manrope-Medium", size: 12))
                                                                .foregroundColor(.grayFaded)
                                                        }
                                                    }
                                                    else {
                                                        let author = review.author
                                                        let posterURL = URL(string: author.avatar ?? "")
                                                        AsyncImage(url: posterURL) { phase in
                                                            switch phase {
                                                            case .empty:
                                                                ProgressView()
                                                            case .success(let image):
                                                                image
                                                                    .resizable()
                                                                    .scaledToFill()
                                                                    .frame(width: 32, height: 32)
                                                                    .clipShape(Circle())
                                                                    .onTapGesture {
                                                                        if review.author.nickName != viewModel.profile?.nickName {
                                                                            viewModel.addFriend(author: review.author, idMovie: idRandMovie, rating: review.rating)
                                                                        }
                                                                    }
                                                            case .failure:
                                                                Image("anonym")
                                                                    .resizable()
                                                                    .scaledToFit()
                                                                    .frame(width: 32, height: 32)
                                                                    .onTapGesture {
                                                                        if review.author.nickName != viewModel.profile?.nickName {
                                                                            viewModel.addFriend(author: review.author, idMovie: idRandMovie, rating: review.rating)
                                                                        }
                                                                    }
                                                            @unknown default:
                                                                Image("anonym")
                                                                    .resizable()
                                                                    .scaledToFit()
                                                                    .frame(width: 32, height: 32)
                                                                    .onTapGesture {
                                                                        if review.author.nickName != viewModel.profile?.nickName {
                                                                            viewModel.addFriend(author: review.author, idMovie: idRandMovie, rating: review.rating)
                                                                        }
                                                                    }
                                                            }
                                                        }
                                                        VStack(alignment: .leading) {
                                                            Text(review.author.nickName ?? "Анонимный пользователь")
                                                                .font(.custom("Manrope-Medium", size: 12))
                                                                .foregroundColor(.white)
                                                                .onTapGesture {
                                                                    if review.author.nickName != viewModel.profile?.nickName {
                                                                        viewModel.addFriend(author: review.author, idMovie: idRandMovie, rating: review.rating)
                                                                    }
                                                                }
                                                            Text(formattedDate(from: review.createDateTime))
                                                                .font(.custom("Manrope-Medium", size: 12))
                                                                .foregroundColor(.grayFaded)
                                                        }
                                                    }

                                                    Spacer()
                                                    HStack {
                                                        Image("ratingIcon")
                                                            .renderingMode(.template)
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 16, height: 16)
                                                            .foregroundColor(.white)
                                                        Text(String(review.rating))
                                                            .font(.custom("Manrope-Medium", size: 16))
                                                            .foregroundColor(.white)
                                                    }
                                                    .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                                                    .background(interpolateColor(rating: review.rating))
                                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                                    
                                                }
                                                if let description = review.reviewText {
                                                    Text(description)
                                                        .font(.custom("Manrope-Medium", size: 16))
                                                        .foregroundColor(.white)
                                                }
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                                            .background(.dark)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        
                                        }
                                        
                                        //ОТЗЫВЫ ДОБАВИТЬ ПРОЛИСТАТЬ
                                        HStack(spacing: 24) {
                                            if viewModel.isReviewWritten {
                                                HStack( spacing: 4) {
                                                    Button(action: {
                                                        showAddReviewPopup = true
                                                    }) {
                                                        Text("Изменить отзыв")
                                                            .font(.custom("Manrope-Bold", size: 14))
                                                            .lineLimit(1)
                                                            .multilineTextAlignment(.center)
                                                            .foregroundColor(.white)
                                                            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                                            .frame(maxWidth: .infinity)
                                                            .background(
                                                                LinearGradient(
                                                                    gradient: Gradient(colors: [Color(hex: "#DF2800"), Color(hex: "#FF6633")]),
                                                                    startPoint: .leading,
                                                                    endPoint: .trailing
                                                                )
                                                            )
                                                            .cornerRadius(8)

                                                    }
                                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                                    Button(action: {
                                                        viewModel.didTapDeleteReview(movieId: idRandMovie)
                                                    }) {
                                                        Image("deleteIcon")
                                                            .renderingMode(.template)
                                                            .frame(width: 40, height: 40)
                                                            .foregroundColor(.white)
                                                            .background(Color.dark)
                                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                                    }
                                                }

                                            }
                                            else {
                                                Button(action: {
                                                    showAddReviewPopup = true
                                                }) {
                                                    Text("Добавить отзыв")
                                                        .font(.custom("Manrope-Bold", size: 14))
                                                        .lineLimit(1)
                                                        .multilineTextAlignment(.center)
                                                        .foregroundColor(.white)
                                                        .padding(EdgeInsets(top: 10, leading: 24, bottom: 10, trailing: 24))
                                                        .frame(maxWidth: .infinity)
                                                        .background(
                                                            LinearGradient(
                                                                gradient: Gradient(colors: [Color(hex: "#DF2800"), Color(hex: "#FF6633")]),
                                                                startPoint: .leading,
                                                                endPoint: .trailing
                                                            )
                                                        )
                                                        .cornerRadius(8)

                                                }
                                                .padding(.trailing, 24)
                                                .frame(maxWidth: .infinity, alignment: .trailing)
                                            }
                                            HStack (spacing: 4){
                                                Button(action: {
                                                    if currentReviewIndex > 0 {
                                                        currentReviewIndex -= 1
                                                    }
                                                }) {
                                                    Image("ChevronLeft")
                                                        .renderingMode(.template)
                                                        .frame(width: 40, height: 40)
                                                        .foregroundColor(.white)
                                                        .background(Color.dark)
                                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                                }
                                                Button(action: {
                                                    if currentReviewIndex < reviews.count - 1 {
                                                        currentReviewIndex += 1
                                                    }
                                                }) {
                                                    Image("ChevronRight")
                                                        .renderingMode(.template)
                                                        .frame(width: 40, height: 40)
                                                        .foregroundColor(.white)
                                                        .background(Color.dark)
                                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                                }
                                            }
                                        }
                                        
                                    }
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.darkFaded)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                
                                
                            }
                            .padding(.horizontal, 24)
                        }
                    } else {
                        Text("Нет данных")
                            .font(.title)
                            .padding()
                            .foregroundColor(.white)
                    }
                }
            }
            if showAddReviewPopup {
                
                ZStack{
                    VStack(spacing: 24) {
                        HStack{
                            if viewModel.isReviewWritten {
                                Text("Изменить отзыв")
                                    .font(.custom("Manrope-Bold", size: 20))
                                    .foregroundColor(.white)
                            }
                            else {
                                Text("Добавить отзыв")
                                    .font(.custom("Manrope-Bold", size: 20))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                        }
                        VStack {
                            HStack{
                                Text("Оценка")
                                    .font(.custom("Manrope-Regular", size: 14))
                                    .foregroundColor(.grayCustom)
                                Spacer()
                            }
                            Slider(value: $viewModel.rating, in: 0...10, step: 1)
                                .accentColor(.orange)
                                .frame(height: 44)
                        }

                        VStack{
                            ZStack{
                                TextEditor(text: $viewModel.reviewText)
                                    .font(.custom("Manrope-Regular", size: 14))
                                    .foregroundColor(.grayCustom)
                                    .padding(16)
                                    .scrollContentBackground(.hidden)
                                    .background(.clear)
                                    .overlay(
                                        Text("Текст отзыва")
                                            .padding(16)
                                            .font(.custom("Manrope-Regular", size: 14))
                                            .foregroundColor(.grayFaded)
                                            .opacity($viewModel.reviewText.wrappedValue == "" ? 1 : 0),
                                        alignment: .topLeading
                                    )
                            }
                            .frame(maxWidth: .infinity, minHeight: 120, maxHeight: 120)
                            .background(.darkFaded)
                            .cornerRadius(8)
                            
                            Toggle("Анонимный отзыв", isOn: $viewModel.isAnonymous)
                                .font(.custom("Manrope-Regular", size: 14))
                                .foregroundColor(.grayCustom)
                        }
                            
                        
                        HStack {
                            Spacer()
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Button(action: {
                                if viewModel.isReviewWritten {
                                    viewModel.didTapEditReview(movieId: idRandMovie)
                                } else {
                                    viewModel.didTapAddReview(movieId: idRandMovie)
                                }
                                
                                showAddReviewPopup = false
                                print("Review submitted")
                            }) {
                                Text("Отправить")
                                    .font(.custom("Manrope-Bold", size: 14))
                                    .lineLimit(1)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color(hex: "#DF2800"), Color(hex: "#FF6633")]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(8)
                            }
                            .disabled(viewModel.reviewText.isEmpty)
                            .opacity(viewModel.reviewText.isEmpty ? 0.5 : 1.0)
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.dark)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .onTapGesture {
                        UIApplication.shared.endEditing()
                    }
                }
                .padding(.horizontal, 24)
                .frame(maxHeight: .infinity, alignment: .center)
                .background(.black.opacity(0.5))
                .onTapGesture {
                    showAddReviewPopup = false
                }
            }
            
        }
        .onAppear {
            viewModel.fetchMovieDetails(id: idRandMovie)
        }
    }
    
    private func formattedDate(from dateString: String) -> String {
        let iso8601DateString = dateString + "Z"
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = dateFormatter.date(from: iso8601DateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "d MMMM yyyy"
            outputFormatter.locale = Locale(identifier: "ru_RU")
            return outputFormatter.string(from: date)
        } else {
            return "Invalid Date"
        }
    }
    
    private func interpolateColor(rating: Int) -> Color {
        let redStart: Double = 1.0
        let greenStart: Double = 0.0
        let redEnd: Double = 0.0
        let greenEnd: Double = 1.0
        
        let normalizedRating = Double(rating) / 10.0
        
        let red = redStart + (redEnd - redStart) * normalizedRating
        let green = greenStart + (greenEnd - greenStart) * normalizedRating
        
        return Color(red: red, green: green, blue: 0.0)
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}






extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


extension String {
    func withGroupingSeparator() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = " "
        
        if let number = Int(self), let formattedString = numberFormatter.string(from: NSNumber(value: number)) {
            return formattedString
        } else {
            return self
        }
    }
}
