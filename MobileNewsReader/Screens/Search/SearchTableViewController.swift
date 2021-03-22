//
//  SearchTableViewController.swift
//  MobileNewsReader
//
//  Created by Vladimir on 16/03/2021.
//  Copyright © 2021 Embler. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    //MARK: - Private Properties
    private let searchController = UISearchController(searchResultsController: nil)
    private var articles = Articles(status: "", totalResults: 0, articles: [])
    
    //MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(with: NewsTableViewCell.self)
        tableView.tableFooterView = UIView()
        setupSearchController()
        setArticles()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        configureNavigationBar()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        articles.articles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: NewsTableViewCell.self)
        cell.activityIndicator.startAnimating()
        cell.newsTitleLabel.text = articles.articles[indexPath.row].title
        cell.newsDescriptionLabel.text = articles.articles[indexPath.row].description
        cell.newsImageView.image = nil

        if let imageData = articles.articles[indexPath.row].imageData {
            cell.newsImageView.image = UIImage(data: imageData)
            cell.activityIndicator.stopAnimating()
        } else if NetworkMonitor.shared.isConnected {
            DispatchQueue.global().async {
                if let imageData = ImageManager.shared.fetchImage(from: self.articles.articles[indexPath.row].urlToImage) {
                    DispatchQueue.main.async {
                        cell.newsImageView.image = UIImage(data: imageData)
                        cell.activityIndicator.stopAnimating()
                        self.articles.articles[indexPath.row].imageData = imageData
                        if let articleTitle = self.articles.articles[indexPath.row].title, !StorageManager.shared.isArticleExistInBase(articleTitle: articleTitle) {
                            var article = self.articles.articles[indexPath.row]
                            article.fromSearch = true
                            StorageManager.shared.saveArticle(article: article)
                        }
                    }
                }  else {
                    DispatchQueue.main.async {
                        cell.newsImageView.image = UIImage(named: "no-image")
                        cell.activityIndicator.stopAnimating()
                        if let articleTitle = self.articles.articles[indexPath.row].title, !StorageManager.shared.isArticleExistInBase(articleTitle: articleTitle) {
                            var article = self.articles.articles[indexPath.row]
                            article.fromSearch = true
                            StorageManager.shared.saveArticle(article: article)
                        }
                    }
                }
            }
        } else {
            cell.newsImageView.image = UIImage(named: "no-image")
            cell.activityIndicator.stopAnimating()
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "newsSeque", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let viewController = navigationController.topViewController as! NewsViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            let selectedRow = indexPath.row
            viewController.article = articles.articles[selectedRow]
        }
    }
    //MARK: - Public Methods
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchController.searchBar.text else { return }
        if NetworkMonitor.shared.isConnected {
            do {
                try StorageManager.shared.deleteAllArticlesFromSearch()
            } catch let error {
                alertCoreDataError(error: error)
            }
            articles.articles = []
            getArticles(searchText: searchText)
            tableView.reloadData()
        } else {
            alertConnectionLost()
        }
    }
    
    //MARK: - Private Methods
    private func configureNavigationBar() {
        self.parent?.title = "Search"
        self.parent?.navigationItem.searchController = searchController
    }
    
    private func setArticles() {
        var articlesStorage = [ArticlesStorage]()
        do {
            articlesStorage = try StorageManager.shared.getArticlesFromSearch()
        } catch let error {
            alertCoreDataError(error: error)
        }
        for articleStorage in articlesStorage {
            let articleSource = ArticleSource(id: articleStorage.sourceId,
                                              name: articleStorage.sourceName)
            let article = Article(source: articleSource,
                                  author: articleStorage.author,
                                  title: articleStorage.title,
                                  description: articleStorage.articleDescription,
                                  url: articleStorage.url,
                                  urlToImage: articleStorage.urlToImage,
                                  publishedAt: articleStorage.publishedAt,
                                  content: articleStorage.content,
                                  fromSearch: articleStorage.fromSearch,
                                  imageData: articleStorage.imageData)
            articles.articles.append(article)
        }
    }
    
    private func getArticles(searchText: String) {
        DispatchQueue.global().async {
            NetworkManager.shared.getSearchedArticles(searchText: searchText) { articles, responseCode, error in
                if let articles = articles {
                    self.articles = articles
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else if let responseCode = responseCode {
                    DispatchQueue.main.async {
                        self.alertWrongResponse(responseCode: responseCode)
                    }
                } else if let error = error {
                    DispatchQueue.main.async {
                        self.failedAlert(error: error)
                    }
                }
            }
        }
    }
    
    private func setupSearchController() {
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        self.parent?.navigationItem.hidesSearchBarWhenScrolling = false
    }
}
