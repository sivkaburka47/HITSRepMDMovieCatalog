//
//  FriendsViewModel.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 07.11.2024.
//

import Foundation

class FriendsViewModel {
    weak var delegate: FriendsViewModelDelegate?
    
    var friends: [Friend] = [] {
        didSet {
            delegate?.friendsDidUpdate()
        }
    }
    
    init() {
        loadFriends()
    }
    
    private func loadFriends() {
        if let savedFriendsData = UserDefaults.standard.data(forKey: "Friends"),
           let savedFriends = try? JSONDecoder().decode([Friend].self, from: savedFriendsData) {
            
            var uniqueNickNames = Set<String>()
            var uniqueFriends: [Friend] = []
            
            for friend in savedFriends {
                if !uniqueNickNames.contains(friend.nickName) {
                    uniqueNickNames.insert(friend.nickName)
                    uniqueFriends.append(friend)
                }
            }
            
            friends = uniqueFriends
        }
    }
    
    func addFriend(friend: Friend) {
        let existingFriend = friends.first { $0.userId == friend.userId && $0.moviesID == friend.moviesID }
        if existingFriend == nil {
            friends.append(friend)
            saveFriends()
        }
    }
    
    func removeFriend(friend: Friend) {
        friends.removeAll { $0.nickName == friend.nickName }
        saveFriends()
    }
    
    private func saveFriends() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(friends) {
            UserDefaults.standard.set(encoded, forKey: "Friends")
        }
    }
    
    func getFriendCount(forMovieId movieId: String, withRatingGreaterThan rating: Int = 5) -> Int {
        return friends.filter { $0.moviesID == movieId && $0.rating > rating }.count
    }
}





protocol FriendsViewModelDelegate: AnyObject {
    func friendsDidUpdate()
}
