//
//  NewsViewController.swift
//  MobileNewsReader
//
//  Created by Vladimir on 17/03/2021.
//  Copyright © 2021 Embler. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController {

    //MARK: - IB outlets
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var newsTitleLabel: UILabel!
    @IBOutlet weak var newsContentLabel: UILabel!
    
    //MARK: - Public Properties
    public var article = Article(source: nil,
                          author: nil,
                          title: nil,
                          description: nil,
                          url: nil,
                          urlToImage: nil,
                          publishedAt: nil,
                          content: nil,
                          imageData: nil)
    
    //MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(closeView))
        navigationItem.title = article.source?.name ?? ""
        if let imageData = article.imageData {
            newsImageView.image = UIImage(data: imageData)
        } else {
            newsImageView.image = UIImage(named: "no-image")
        }
        newsTitleLabel.text = article.title
        newsContentLabel.text = article.content
    }
    
    //MARK: - Private Methods
     @objc private func closeView() {
        dismiss(animated: true, completion: nil)
    }
}
