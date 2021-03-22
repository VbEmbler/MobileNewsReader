//
//  AllChannelsTableViewController.swift
//  MobileNewsReader
//
//  Created by Vladimir on 16/03/2021.
//  Copyright © 2021 Embler. All rights reserved.
//

import UIKit
import Network
class AllChannelsTableViewController: UITableViewController {
    
    //MARK: - Private Properties
    private var allChannels = Sources(status: "", sources: [])
    private let spinnerView = UIView()
    private let spinner = UIActivityIndicatorView()
    private let spinnerLabel = UILabel()
    
    private var isLoaded = true
    
    //MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(with: ChannelTableViewCell.self)
        tableView.tableFooterView = UIView()
        startNetworkMonitor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        configureNavigationBar()
        setSpinner()
        setSources()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        allChannels.sources.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: ChannelTableViewCell.self)
        cell.channelNameLabel.text = allChannels.sources[indexPath.row].name
        cell.channelDescriptionLabel.text = allChannels.sources[indexPath.row].description
        let sourceId = allChannels.sources[indexPath.row].id ?? ""
        if let isFavourite = StorageManager.shared.isSourceFavourite(sourceId: sourceId), isFavourite {
            cell.favouriteImageView.image = UIImage(named: "highlightedStar")
        } else {
            cell.favouriteImageView.image = UIImage(named: "emptyStar")
            if !StorageManager.shared.isSourceExistInBase(sourceId: sourceId) {
                var source = allChannels.sources[indexPath.row]
                source.favourite = false
                StorageManager.shared.saveSource(source: source)
            }
        }
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
                viewController.sourceId = allChannels.sources[selectedRow].id ?? ""
                viewController.sourceName = allChannels.sources[selectedRow].name ?? ""
            }
        }
    }
    
    //MARK: - Private Methods
    private func configureNavigationBar() {
        self.parent?.title = "All Channels"
        self.parent?.navigationItem.searchController = nil
    }
    
    private func setSources() {
        if NetworkMonitor.shared.isConnected {
            do {
                try StorageManager.shared.deleteNotFavouriteSources()
            } catch let error {
                alertCoreDataError(error: error)
            }
            getSources()
        } else {
            var sourcesStorage = [SourcesStorage]()
            do {
                sourcesStorage = try StorageManager.shared.getSources()
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
                
                allChannels.sources.append(source)
            }
            tableView.reloadData()
            removeSpinner()
        }
    }
    
    private func startNetworkMonitor() {
        DispatchQueue.global().async {
            NetworkMonitor.shared.monitor.pathUpdateHandler = { path in
                NetworkMonitor.shared.isConnected = path.status != .unsatisfied
                if path.status != .unsatisfied {
                    if self.isLoaded {
                        DispatchQueue.main.async {
                            self.isLoaded = false
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.alertConnectionResumed()
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.alertConnectionLost()
                    }
                }
            }
        }
        NetworkMonitor.shared.monitor.start(queue: NetworkMonitor.shared.queue)
    }
    
    private func getSources() {
        DispatchQueue.global().async {
            NetworkManager.shared.getSources { sources,  responseCode, error  in
                if let sources = sources {
                    self.allChannels = sources
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.removeSpinner()
                    }
                } else if let responseCode = responseCode {
                    DispatchQueue.main.async {
                        self.removeSpinner()
                        self.alertWrongResponse(responseCode: responseCode)
                    }
                } else if let error = error {
                    DispatchQueue.main.async {
                        self.removeSpinner()
                        self.failedAlert(error: error)
                    }
                }
            }
        }
    }
    
    @objc private func imageTapped(gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: tableView)
        let indexPathForRow = tableView.indexPathForRow(at: tapLocation)
        guard let row = indexPathForRow?.row else { return }
        if let image = gesture.view as? UIImageView {
            guard let sourceId = allChannels.sources[row].id else { return }
            if image.image == UIImage(named: "emptyStar") {
                image.image = UIImage(named: "highlightedStar")
                do {
                    try StorageManager.shared.editSourceFavouriteProperty(sourceId: sourceId, isFavourite: true)
                } catch let error {
                    alertCoreDataError(error: error)
                }
            } else {
                image.image = UIImage(named: "emptyStar")
                do {
                    try StorageManager.shared.editSourceFavouriteProperty(sourceId: sourceId, isFavourite: false)
                } catch let error {
                    alertCoreDataError(error: error)
                }
            }
        }
    }
    
    private func setSpinner() {
        let width: CGFloat = 160
        let height: CGFloat = 30
        let navigationBarHeight: CGFloat = parent?.navigationController?.navigationBar.frame.height ?? 0
        let x =  view.frame.width / 2 - width / 2
        let y =  view.frame.height / 2 - height / 2 - navigationBarHeight
        
        spinnerLabel.textColor = UIColor.gray
        spinnerLabel.textAlignment = .center
        spinnerLabel.text = "Loading...."
        spinnerLabel.frame = CGRect(x: 0, y: 0, width: 160, height: 30)
        
        spinner.style = .whiteLarge
        spinner.color = UIColor.gray
        spinner.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        
        spinnerView.frame = CGRect(x: x, y: y, width: width, height: height)
        spinnerView.addSubview(spinner)
        spinnerView.addSubview(spinnerLabel)
        
        tableView.addSubview(spinnerView)
    }
    
    private func removeSpinner() {
        spinner.stopAnimating()
        spinner.isHidden = true
        spinnerLabel.isHidden = true
        spinnerView.isHidden = true
        spinner.removeFromSuperview()
    }
}
