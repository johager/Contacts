//
//  TransactionType.swift
//  Contacts
//
//  Created by James Hager on 4/15/22.
//

import Foundation

enum TransactionType: String, CustomStringConvertible {
    
    case fetch
    case update
    case save
    case delete
    
    var description: String { rawValue }
    
    var gerund: String {
        switch self {
        case .fetch: return "fetching"
        case .update: return "updating"
        case .save: return "saving"
        case .delete: return "deleting"
        }
    }
}
