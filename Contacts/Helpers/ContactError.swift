//
//  ContactError.swift
//  Contacts
//
//  Created by James Hager on 4/15/22.
//

import Foundation

enum ContactError: LocalizedError {
    
    case ckError(TransactionType, Error)
    case classFromRecord
    case ckModifyError(CKModifyError)
    case updateContact
    case deleteContact
    
    var errorDescription: String? {
        switch self {
        case .ckError(let transactionType, let error):
            var errorString = "Error \(transactionType.gerund) contact.\n•    •    •\n\(error.localizedDescription)"
            if !errorString.hasSuffix(".") {
                errorString += "."
            }
            return errorString
        case .classFromRecord:
            return "Error creating a contact."
        case .ckModifyError(let ckModifyError):
            return ckModifyError.errorDescription
        case .updateContact:
            return "Error updaating contact"
        case .deleteContact:
            return "Error deleting contact"
        }
    }
}
