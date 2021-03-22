//
//  NetwrokManager.swift
//  MobileNewsReader
//
//  Created by Vladimir on 17/03/2021.
//  Copyright © 2021 Embler. All rights reserved.
//

import Foundation

class NetworkManager {
    
    //MARK: - Public Properties
    public static let shared = NetworkManager()
    
    //MARK: - Initializers
    private init() {}
    
    //MARK: - Public Methods
    public func getSources(completionHandler: @escaping (Sources?, Int?, Error?) -> Void) {
        let url = URL(string: "https://newsapi.org/v2/sources")
        guard let requestUrl = url else { return }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        request.setValue("8721e39f13e6422e836473755d0f7971", forHTTPHeaderField: "X-Api-Key")
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completionHandler(nil, nil, error)
            }
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200 {
                    completionHandler(nil, response.statusCode, nil)
                }
            }
            if let data = data {
                let jsonDecoder = JSONDecoder()
                do {
                    let sources = try jsonDecoder.decode(Sources.self, from: data)
                    completionHandler(sources, nil, nil)
                } catch let error {
                    completionHandler(nil, nil, error)
                }
                
            }
        }.resume()
    }
    
    public func getArticles(sourceId: String, completionHandler: @escaping (Articles?, Int?, Error?) -> Void) {
        let url = URL(string: "https://newsapi.org/v2/top-headlines?sources=\(sourceId)")
        guard let requestUrl = url else { return }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        request.setValue("8721e39f13e6422e836473755d0f7971", forHTTPHeaderField: "X-Api-Key")
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completionHandler(nil, nil, error)
            }
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200 {
                    completionHandler(nil, response.statusCode, nil)
                }
            }
            if let data = data {
                let jsonDecoder = JSONDecoder()
                do {
                    let articles = try jsonDecoder.decode(Articles.self, from: data)
                    completionHandler(articles, nil, nil)
                } catch let error {
                    completionHandler(nil, nil, error)
                }
            }
        }.resume()
    }
    
    public func getSearchedArticles(searchText: String, completionHandler: @escaping (Articles?, Int?, Error?) -> Void) {
        let url = URL(string: "https://newsapi.org/v2/everything?q=\(searchText)")
        guard let requestUrl = url else { return }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        request.setValue("8721e39f13e6422e836473755d0f7971", forHTTPHeaderField: "X-Api-Key")
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completionHandler(nil, nil, error)
            }
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200 {
                    completionHandler(nil, response.statusCode, nil)
                }
            }
            if let data = data {
                let jsonDecoder = JSONDecoder()
                do {
                    let articles = try jsonDecoder.decode(Articles.self, from: data)
                    completionHandler(articles, nil, nil)
                } catch let error {
                    completionHandler(nil, nil, error)
                }
            }
        }.resume()
    }
}
