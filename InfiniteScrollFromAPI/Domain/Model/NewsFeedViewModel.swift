//
//  NewsFeedModels.swift
//  InfiniteScrollFromAPI
//
//  Created by cristian on 15/09/2020.
//  Copyright © 2020 cristian. All rights reserved.
//

import Foundation

class NewsFeedViewModel: ObservableObject/*, RandomAccessCollection */{
    
    // Published object = observedObjcect
    @Published var newsListItems = [NewsListItem]()
    
    // variable that we will update after a call
    var nextPageToLoad = 1
    
    //
    var currentlyLoading = false
    let repository: NewsFeedRepository
    let urlBase = "https://newsapi.org/v2/everything?q=apple&apiKey=6ffeaceffa7949b68bf9d68b9f06fd33&language=en&page="
    
    init(repository: NewsFeedRepository = NewsFeedRepository()) {
        self.repository = repository
        loadMoreArticles()
    }
    
    func loadMoreArticles(currentItem: NewsListItem? = nil) {
        // if we shouldn't load more data don't do it
        if !shouldLoadMoreData(currentItem: currentItem) {
            return
        }
        // We're loading data
        currentlyLoading = true
        
        //Fetch data with a session
        let urlString = "\(urlBase)\(nextPageToLoad)"
        let url = URL(string: urlString)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            self.parseArticlesFromResponse(data: data, response: response, error: error)
        }
        task.resume()
    }
    
    func shouldLoadMoreData(currentItem: NewsListItem? = nil) -> Bool {
        // if we're loading we shouldn't loadMoreData
        if currentlyLoading {
            return false
        }
        //if don't receive the currentItem in parameter we should load more data
        guard let currentItem = currentItem else { return true }
        guard let lastItem = newsListItems.last else { return true }
        return currentItem.uuid == lastItem.uuid
    }
    
    func parseArticlesFromResponse(data: Data?, response: URLResponse?, error: Error?) {
        // if we get an error or data is nil we aren't currently loading
        guard error == nil else {
            print("Error: \(error!)")
            currentlyLoading = false
            return
        }
        guard let data = data else {
            currentlyLoading = false
            print("No data found")
            return
        }
        
        let newArticles = parseArticlesFromData(data: data)
        // We append the new content async
        DispatchQueue.main.async {
            self.newsListItems.append(contentsOf: newArticles)
            self.nextPageToLoad += 1
            self.currentlyLoading = false
        }
        
    }
    
    func parseArticlesFromData(data: Data) -> [NewsListItem] {
        let jsonObject = try! JSONSerialization.jsonObject(with: data)
        let topLevelMap = jsonObject as! [String: Any?]
        guard topLevelMap["status"] as? String == "ok" else {
            print("Status returned was not ok")
            return []
        }
        
        guard let jsonArticles = topLevelMap["articles"] as? [[String: Any]] else {
            print("No articles found")
            return []
        }
        
        var newArticles = [NewsListItem]()
        for jsonArticle in jsonArticles {
            guard let title = jsonArticle["title"] as? String else { continue }
            guard let author = jsonArticle["author"] as? String else { continue }
            newArticles.append(NewsListItem(title: title, author: author))
        }
        return newArticles
    }
}


class NewsFeedRepository {
    
    var output: NewsFeedViewModel?
    
    let urlBase = "https://newsapi.org/v2/everything?q=apple&apiKey=6ffeaceffa7949b68bf9d68b9f06fd33&language=en&page="
    
    init() {}
    
    func fetchArticles() {
        let urlString = "\(urlBase)\(output?.nextPageToLoad ?? 1)"
        let url = URL(string: urlString)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            self.parseArticlesFromResponse(data: data, response: response, error: error)
        }
        task.resume()
    }
    
    func parseArticlesFromResponse(data: Data?, response: URLResponse?, error: Error?) {
        guard error == nil else {
            print("Error: \(error!)")
            output?.currentlyLoading = false
            return
        }
        guard let data = data else {
            output?.currentlyLoading = false
            print("No data found")
            return
        }
        
        let newArticles = parseArticlesFromData(data: data)
        
        
            self.output?.newsListItems.append(contentsOf: newArticles)
            self.output?.nextPageToLoad += 1
            self.output?.currentlyLoading = false
        
        
    }
    
    func parseArticlesFromData(data: Data) -> [NewsListItem] {
        let jsonObject = try! JSONSerialization.jsonObject(with: data)
        let topLevelMap = jsonObject as! [String: Any?]
        guard topLevelMap["status"] as? String == "ok" else {
            print("Status returned was not ok")
            return []
        }
        
        guard let jsonArticles = topLevelMap["articles"] as? [[String: Any]] else {
            print("No articles found")
            return []
        }
        
        var newArticles = [NewsListItem]()
        for jsonArticle in jsonArticles {
            guard let title = jsonArticle["title"] as? String else { continue }
            guard let author = jsonArticle["author"] as? String else { continue }
            newArticles.append(NewsListItem(title: title, author: author))
        }
        return newArticles
    }
}
