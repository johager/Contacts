//
//  CKModifyError.swift
//  Contacts
//
//  Created by James Hager on 4/15/22.
//

import Foundation

enum CKModifyError: LocalizedError {
    
    case ckModifySetUp(TransactionType)
    case ckModifyError(TransactionType, Error)
    
    var errorDescription: String? {
        switch self {
        case .ckModifySetUp(let transactionType):
            return "Error setting up \(transactionType)."
            
        case .ckModifyError(let transactionType, let error):
            var errorString = "Error \(transactionType.gerund) contact.\n•    •    •\n\(error.localizedDescription)"
            if !errorString.hasSuffix(".") {
                errorString += "."
            }
            return errorString
        }
    }
}
