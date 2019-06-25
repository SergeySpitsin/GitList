//
//  PublicRepositoriesListViewController.swift
//  GitList
//
//  Created by Сергей Спицин on 25.06.2019.
//  Copyright © 2019 Сергей Спицин. All rights reserved.
//

import UIKit
import Alamofire
import SafariServices

class PublicRepositoriesListViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var footerView: GLFooterView!
    
    private let refreshControl = UIRefreshControl()
    
    private var dataSource: [Repository] = []
    private var request: DataRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
    
    private func configure() {
        tableView.refreshControl = refreshControl
        
        loadData()
    }
    
    private func loadMoreData(since: Int?, completionHandler: @escaping () -> Void = {}) {
        guard request == nil else { return }
        
        footerView.errorLabel.isHidden = true
        footerView.activityIndicator.isHidden = false
        footerView.activityIndicator.startAnimating()
        
        request = NetworkManager.shared.getListAllPublicRepositories(since: since) { [weak self] (status, repositories) in
            guard let strongSelf = self else { return }

            switch status {
            case .success:
                if since == nil {
                    strongSelf.dataSource = repositories ?? []
                } else {
                    strongSelf.dataSource += repositories ?? []
                }
 
                strongSelf.tableView.reloadData()
            case .failure, .canceled, .unknown:
                strongSelf.footerView.errorLabel.isHidden = false
            }
            
            strongSelf.footerView.activityIndicator.stopAnimating()
            strongSelf.footerView.activityIndicator.isHidden = true
            
            strongSelf.request = nil
            completionHandler()
        }
    }
    
    private func loadData(completionHandler: @escaping () -> Void = {}) {
        loadMoreData(since: nil) {
            completionHandler()
        }
    }
    
    private func refreshData(completionHandler: @escaping () -> Void = {}) {
        loadData { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.refreshControl.endRefreshing()
            completionHandler()
        }
    }
}

extension PublicRepositoriesListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshControl.isRefreshing {
            refreshData()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryTableViewCell", for: indexPath) as! RepositoryTableViewCell
        
        cell.setRepository(dataSource[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == dataSource.count - 1 {
            loadMoreData(since: dataSource.last?.id)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = dataSource[indexPath.row]
        
        if let url = URL(string: data.url) {
            tableView.deselectRow(at: indexPath, animated: true)
            
            let svc = SFSafariViewController(url: url)
            present(svc, animated: true)
        }
    }
}
