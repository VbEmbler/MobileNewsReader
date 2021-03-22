//
//  ChannelNewsListTableViewController.swift
//  MobileNewsReader
//
//  Created by Vladimir on 16/03/2021.
//  Copyright © 2021 Embler. All rights reserved.
//

import UIKit

class ChannelNewsListTableViewController: UITableViewController {
    
    
    //MARK: - Public Properties
    public var sourceId = ""
    public var sourceName = ""
    
    //MARK: - Private Properties
    private var articles = Articles(status: "", totalResults: 0, articles: [])
    
    //MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(with: NewsTableViewCell.self)
        tableView.tableFooterView = UIView()
        configureNavigationBar()
        setArticles()
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
                            article.fromSearch = false
                            StorageManager.shared.saveArticle(article: article)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        cell.newsImageView.image = UIImage(named: "no-image")
                        cell.activityIndicator.stopAnimating()
                        if let articleTitle = self.articles.articles[indexPath.row].title, !StorageManager.shared.isArticleExistInBase(articleTitle: articleTitle) {
                            var article = self.articles.articles[indexPath.row]
                            article.fromSearch = false
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
        if segue.identifier == "newsSeque" {
            let navigationController = segue.destination as! UINavigationController
            let viewController = navigationController.topViewController as! NewsViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                let selectedRow = indexPath.row
                viewController.article = articles.articles[selectedRow]
            }
        }
    }
    
    //MARK: - Private Methods
    @objc private func closeView() {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Private Methods
    private func configureNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(closeView))
        navigationItem.title = sourceName
    }
    
    private func setArticles() {
        if NetworkMonitor.shared.isConnected {
            do {
                try StorageManager.shared.deleteAllArticlesWithotFromSearchWith(sourceId: sourceId)
            } catch let error {
                alertCoreDataError(error: error)
            }
            getArticles()
        } else {
            var artilesStorage = [ArticlesStorage]()
            do {
                artilesStorage = try StorageManager.shared.getArticles(sourceId: sourceId)
            } catch let error {
                alertCoreDataError(error: error)
            }
            for articleStorage in artilesStorage {
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
    }
    
    private func getArticles() {
        DispatchQueue.global().async {
            NetworkManager.shared.getArticles(sourceId: self.sourceId) { articles, responseCode, error in
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
}
