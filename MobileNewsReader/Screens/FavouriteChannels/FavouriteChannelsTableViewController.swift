//
//  FavouriteChannelsTableViewController.swift
//  MobileNewsReader
//
//  Created by Vladimir on 16/03/2021.
//  Copyright © 2021 Embler. All rights reserved.
//

import UIKit

class FavouriteChannelsTableViewController: UITableViewController {
    
    //MARK: - Private Properties
    private var favouriteSources = Sources(status: "", sources: [])
    
    //MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(with: ChannelTableViewCell.self)
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.parent?.title = "Favourite channels"
        self.parent?.navigationItem.searchController = nil
        getFavouriteSources()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        favouriteSources.sources.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: ChannelTableViewCell.self)
        cell.channelNameLabel.text = favouriteSources.sources[indexPath.row].name
        cell.channelDescriptionLabel.text = favouriteSources.sources[indexPath.row].description
        cell.favouriteImageView.image = UIImage(named: "highlightedStar")
        
        if cell.favouriteImageView.gestureRecognizers?.count == nil {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(gesture:)))
            cell.favouriteImageView.addGestureRecognizer(tapGesture)
            cell.favouriteImageView.isUserInteractionEnabled = true
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "channelNewsList", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "channelNewsList" {
            let navigationController = segue.destination as! UINavigationController
            let viewController = navigationController.topViewController as! ChannelNewsListTableViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                let selectedRow = indexPath.row
                viewController.sourceId = favouriteSources.sources[selectedRow].id ?? ""
                viewController.sourceName = favouriteSources.sources[selectedRow].name ?? ""
            }
        }
    }
    
    
    //MARK: - Private Methods
    private func getFavouriteSources() {
        favouriteSources.sources = []
        var sourcesStorage = [SourcesStorage]()
        do {
            sourcesStorage = try StorageManager.shared.getFavouriteSources()
        } catch let error {
            alertCoreDataError(error: error)
        }
        for sourceStorage in sourcesStorage {
            let source = Source(id: sourceStorage.id,
                                name: sourceStorage.name,
                                description: sourceStorage.sourceDescription,
                                url: sourceStorage.url,
                                category: sourceStorage.category,
                                language: sourceStorage.language,
                                country: sourceStorage.country,
                                favourite: sourceStorage.favourite)
            favouriteSources.sources.append(source)
        }
    }
    
    @objc private func imageTapped(gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: tableView)
        let indexPathForRow = tableView.indexPathForRow(at: tapLocation)
        guard let row = indexPathForRow?.row else { return }
        if let _ = gesture.view as? UIImageView {
            guard let sourceId = favouriteSources.sources[row].id else { return }
            do {
                try StorageManager.shared.editSourceFavouriteProperty(sourceId: sourceId, isFavourite: false)
            } catch let error {
                alertCoreDataError(error: error)
            }
            getFavouriteSources()
            tableView.reloadData()
        }
    }
}
