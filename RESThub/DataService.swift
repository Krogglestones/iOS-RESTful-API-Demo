//
//  DataService.swift
//  RESThub
//
//  Created by Craig Larson on 1/15/20.
//  Copyright © 2020. All rights reserved.
//

import Foundation

class DataService {
    static let shared = DataService()
    
    fileprivate let baseURLString = "https://api.github.com"
    
    func fetchGists(completion: @escaping (Result<[Gist], Error>) -> Void) {

        var componentURL = URLComponents()
        componentURL.scheme = "https"
        componentURL.host = "api.github.com"
        componentURL.path = "/gists/public"

        
        guard let validURL = componentURL.url else {
            print("URL Failed")
            return
        }
        
        URLSession.shared.dataTask(with: validURL) { (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("API status code: \(httpResponse.statusCode)")
            }
            
            guard let validData = data, error == nil else {
                completion(.failure(error!))
                return
            }
            
            do {
                
                let gists = try JSONDecoder().decode([Gist].self, from: validData)
                
                completion(.success(gists))
                
            } catch let serializationError {
                completion(.failure(serializationError))
            }
            
        }.resume()
    }
    
    func createNewGist(completion: @escaping (Result<Any, Error>) -> Void) {
        
        let postComponents = createURLComponents(path: "/gists")
        guard let composedURL = postComponents.url else {
            print("URL Creation Failed")
            return
        }
        var postRequest = URLRequest(url: composedURL)
        postRequest.httpMethod = "POST"
        
        
        postRequest.setValue("Basic \(createAuthCredentials())", forHTTPHeaderField: "Authorization")
        postRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        postRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let newGist = Gist(id: nil, isPublic: true, description: "A new gist", files: ["test_file.txt": File(content: "Hello World")])
        
        do {
            let gistData = try JSONEncoder().encode(newGist)
            postRequest.httpBody = gistData
        } catch {
            print("Gist encoding failed.")
        }
        
        URLSession.shared.dataTask(with: postRequest) { (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Code: \(httpResponse.statusCode)")
            }
            
            guard let validData = data, error == nil else {
                completion(.failure(error!))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: validData, options: [])
                completion(.success(json))
            } catch let serializationError {
                completion(.failure(serializationError))
            }
            
        }.resume()
        
    }
    
    func createURLComponents(path: String) -> URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.github.com"
        components.path = path
        return components
    }
    
    func createAuthCredentials() -> String {
        
//        TODO: Change authString from XXXX:XXXX to "githubUserName:githubPassword"
        let authString = "XXXX:XXXX"
               
               var authStringBase64 = ""
               
               if let authData = authString.data(using: .utf8) {
                   authStringBase64 = authData.base64EncodedString()
               }
        return authStringBase64
    }
    
    
    func starUnstarGist(id: String, star: Bool, completion: @escaping (Bool) -> Void) {
        
        let starComponents = createURLComponents(path: "/gists/\(id)/star")
        guard let composedURL = starComponents.url else {
            print("Component composition failed...")
            return
        }
        
        var starRequest = URLRequest(url: composedURL)
        starRequest.httpMethod = star == true ? "PUT" : "DELETE"
        
        starRequest.setValue("0", forHTTPHeaderField: "Content-Length")
        starRequest.setValue("Basic \(createAuthCredentials())", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: starRequest) { (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 204 {
                    completion(true)
                } else {
                    completion(false)
                }
            }
            
        }.resume()
    }
    
}
