//
//  Repository.swift
//  GitList
//
//  Created by Сергей Спицин on 25.06.2019.
//  Copyright © 2019 Сергей Спицин. All rights reserved.
//

import Foundation
import MarkdownKit

struct Repository {
    
    let id: Int
    let name: String
    let owner: Owner
    let url: String
    var description: String?
    var attributtedDescription: NSAttributedString?
    
    init?(json: [String : Any]) {
        if let id = json["id"] as? Int,
            let name = json["name"] as? String,
            let url = json["html_url"] as? String,
            let ownerJson = json["owner"] as? [String : Any], let owner = Owner(json: ownerJson) {
            
            self.id = id
            self.name = name
            self.url = url
            self.owner = owner
            
            if let description = json["description"] as? String {
                self.description = description
                
                let parser = MarkdownParser(font: .preferredFont(forTextStyle: .body))
                self.attributtedDescription = parser.parse(description)
            }
        } else {
            return nil
        }
    }
}

extension Repository: Codable {

    enum CodingKeys: CodingKey {

        case id
        case name
        case url
        case owner
        case description

    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        url = try container.decode(String.self, forKey: .url)
        owner = try container.decode(Owner.self, forKey: .owner)

        if let description = try? container.decode(String.self, forKey: .description) {
            self.description = description
            
            let parser = MarkdownParser(font: .preferredFont(forTextStyle: .body))
            self.attributtedDescription = parser.parse(description)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(url, forKey: .url)
        try container.encode(owner, forKey: .owner)

        if let description = description {
            try container.encode(description, forKey: .description)
        }
    }
}
