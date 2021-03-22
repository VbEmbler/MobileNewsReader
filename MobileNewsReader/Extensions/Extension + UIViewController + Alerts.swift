//
//  Extension + UIViewController + Alerts.swift
//  MobileNewsReader
//
//  Created by Vladimir on 21/03/2021.
//  Copyright © 2021 Embler. All rights reserved.
//

import UIKit

extension  UIViewController {

    func alertConnectionLost() {
        let alert = UIAlertController(title: "No Internet Connection",
                                      message: "You will see last uploaded news",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok",
                                     style: .default,
                                     handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    func alertConnectionResumed() {
        let alert = UIAlertController(title: "Internet Connection resumed",
                                      message: "You will see last news",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok",
                                     style: .default,
                                     handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    func alertWrongResponse(responseCode: Int) {
        let alert = UIAlertController(title: "Bad response from Server. Error Code: \(responseCode)",
                                      message: "Please contact the developer and iform the error code",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok",
                                     style: .default,
                                     handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    func failedAlert(error: Error) {
        let alert = UIAlertController(title: "Failed",
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok",
                                     style: .default,
                                     handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    func alertCoreDataError(error: Error) {
        let alert = UIAlertController(title: "Failed",
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok",
                                     style: .default,
                                     handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}
