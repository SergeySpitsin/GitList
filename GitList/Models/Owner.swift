//
//  Owner.swift
//  GitList
//
//  Created by Сергей Спицин on 25.06.2019.
//  Copyright © 2019 Сергей Спицин. All rights reserved.
//

import Foundation

struct Owner {
    
    let login: String
    var avatarUrl: String?
    
    init?(json: [String : Any]) {
        if let login = json["login"] as? String {
            self.login = login
            
            self.avatarUrl = json["avatar_url"] as? String
        } else {
            return nil
        }
    }
}

extension Owner: Codable {
    
    enum CodingKeys: CodingKey {
        
        case login
        
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        login = try container.decode(String.self, forKey: .login)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(login, forKey: .login)
    }
}
