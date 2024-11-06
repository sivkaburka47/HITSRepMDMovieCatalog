//
//  ProfileViewModel.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 27.10.2024.
//

import Foundation

class ProfileViewModel {
    
    var profile: ProfileModel?
    
    var updateUI: (() -> Void)?
    
    private var appRouter: AppRouter
    
    init(appRouter: AppRouter) {
        self.appRouter = appRouter
    }
    
    func fetchProfile() {

        let token = UserDefaults.standard.string(forKey: "authToken") ?? ""
        guard let url = URL(string: "https://react-midterm.kreosoft.space/api/account/profile") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }
            
            let statusCode = httpResponse.statusCode
            print("Status Code: \(statusCode)")
            
            if statusCode == 401 {
                DispatchQueue.main.async {
                    self?.appRouter.logout()
                }
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                var profile = try JSONDecoder().decode(ProfileModel.self, from: data)
                profile.birthDate = self?.formatISO8601ToCustomDate(profile.birthDate) ?? "Invalid date"
                self?.profile = profile
                
                DispatchQueue.main.async {
                    self?.updateUI?()
                    print("id: \(profile.id), nickName: \(profile.nickName), email: \(profile.email), avatar: \(profile.avatarLink), name: \(profile.name), birthDate: \(profile.birthDate), gender: \(profile.gender)")
                }
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
            }
        }
        
        task.resume()
        
    }
    
    
    private func formatISO8601ToCustomDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        guard let date = dateFormatter.date(from: dateString) else {
            return "Invalid date"
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd MMMM yyyy"
        outputFormatter.locale = Locale(identifier: "ru_RU")
        
        return outputFormatter.string(from: date)
    }
    
    func changeProfileAvatar(_ avatarURL: String) {
        guard let profile = profile else {
            print("Profile data is not available")
            return
        }
        
        let token = UserDefaults.standard.string(forKey: "authToken") ?? ""
        guard let url = URL(string: "https://react-midterm.kreosoft.space/api/account/profile") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let profileData: [String: Any] = [
            "id": profile.id,
            "nickName": profile.nickName,
            "email": profile.email,
            "avatarLink": avatarURL,
            "name": profile.name,
            "birthDate": formatDateToISO8601(profile.birthDate) ?? "",
            "gender": profile.gender
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: profileData, options: [])
            request.httpBody = jsonData
        } catch {
            print("Failed to serialize JSON: \(error.localizedDescription)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }
            
            let statusCode = httpResponse.statusCode
            print("Status Code: \(statusCode)")
            
            if statusCode == 200 {
                DispatchQueue.main.async {
                    self?.profile?.avatarLink = avatarURL
                    self?.updateUI?()
                    print("Avatar updated successfully")
                }
            } else {
                print("Failed to update avatar")
            }
        }
        
        task.resume()
    }

    private func formatDateToISO8601(_ dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        guard let date = dateFormatter.date(from: dateString) else {
            return nil
        }
        
        let iso8601Formatter = ISO8601DateFormatter()
        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        return iso8601Formatter.string(from: date)
    }
    
    func logOut() {
        appRouter.logout(forced: true)
    }
    
    func openFriends() {
        appRouter.navigateToFriends()
    }
}
