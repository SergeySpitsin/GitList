//
//  NetworkManager.swift
//  GitList
//
//  Created by Сергей Спицин on 25.06.2019.
//  Copyright © 2019 Сергей Спицин. All rights reserved.
//

import Foundation
import Alamofire

enum Status: Error {
    
    case success
    
    case failure
    
    case canceled
    
    case unknown
    
}

enum Path: String {
    
    case repositories = "/repositories"
    
}

class NetworkManager {
    
    static let shared = NetworkManager()
    
    private init() {}
    
    private let queue = DispatchQueue(label: "Network Manger Queue", qos: .utility)

    private let hostname = "https://api.github.com"
    
    typealias JSON = [[String : Any]]
    typealias Response = (Status, JSON?) -> Void
    
    // MARK: - Initail calls
    
    @discardableResult
    private func makeCall(path: Path, method: HTTPMethod, parameters: Parameters? = nil, response: @escaping Response) -> DataRequest {
        return makeCall(path: path.rawValue, method: method, parameters: parameters) { (statusCode, json) in
            response(statusCode, json)
        }
    }
    
    @discardableResult
    private func makeCall(path: String, method: HTTPMethod, parameters: Parameters? = nil, response: @escaping Response) -> DataRequest {
        
        return Alamofire.request(hostname + path, method: method, parameters: parameters).validate().responseJSON(queue: queue, completionHandler: { (data) in
            
            switch data.result {
            case .success:
                if let json = data.result.value as? JSON {
                    response(.success, json)
                } else {
                    response(.unknown, nil)
                }
            case .failure(let error as NSError):
                if error.domain == NSURLErrorDomain, error.code == NSURLErrorCancelled {
                    response(.canceled, nil)
                    
                } else {
                    response(.failure, nil)
                }
            }
        })
    }
    
    // MARK: Api calls
    
    @discardableResult
    public func getListAllPublicRepositories(since: Int? = nil, response: @escaping (Status, [Repository]?) -> Void) -> DataRequest {
        var parameters: [String : Any] = [:]
        
        if let since = since {
            parameters["since"] = String(since)
        }
        
        return makeCall(path: .repositories, method: .get, parameters: parameters) { (statusCode, json) in
            let repositories = json?.compactMap({ Repository(json: $0) })
            
            DispatchQueue.main.async {
                response(statusCode, repositories)
            }
        }
    }
}
