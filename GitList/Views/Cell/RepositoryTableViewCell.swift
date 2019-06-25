//
//  RepositoryTableViewCell.swift
//  GitList
//
//  Created by Сергей Спицин on 25.06.2019.
//  Copyright © 2019 Сергей Спицин. All rights reserved.
//

import UIKit
import MarkdownKit
import Nuke

class RepositoryTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var idLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configure()
    }
    
    private func configure() {
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.height / 2
    }
    
    public func setRepository(_ repository: Repository) {
        
        idLabel.text = "id\(repository.id)"
        titleLabel.text = "\(repository.owner.login) / \(repository.name)"
        
        if let urlString = repository.owner.avatarUrl, let url = URL(string: urlString) {
            Nuke.loadImage(with: url, into: avatarImageView)
        } else {
            avatarImageView.image = nil
        }
        
        if let attributtedDescription = repository.attributtedDescription {
            descriptionLabel.isHidden = false
            descriptionLabel.attributedText = attributtedDescription
        } else if let description = repository.description {
            descriptionLabel.isHidden = false
            descriptionLabel.text = description
        } else {
            descriptionLabel.isHidden = true
            descriptionLabel.text = nil
        }
    }
}
