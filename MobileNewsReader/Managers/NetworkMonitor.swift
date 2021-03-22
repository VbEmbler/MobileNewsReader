//
//  NetworkMonitor.swift
//  MobileNewsReader
//
//  Created by Vladimir on 18/03/2021.
//  Copyright © 2021 Embler. All rights reserved.
//

import Foundation
import Network

class NetworkMonitor {
    
    //MARK: - Public Properties
    static let shared = NetworkMonitor()
    public let queue = DispatchQueue.global()
    public let monitor = NWPathMonitor()
    public var isConnected = false
    
    //MARK: - Initializers
    private init() {}
    
    //MARK: - Public Methods
    public func stopMonitoring() {
        monitor.cancel()
    }
}
