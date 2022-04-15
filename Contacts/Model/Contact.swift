//
//  Contact.swift
//  Contacts
//
//  Created by James Hager on 4/15/22.
//

import Foundation
import CloudKit

class Contact {
    
    // MARK: - Class Constants
    
    static let recordType = "Contact"
    static let firstNameKey = "firstName"
    static let lastNameKey = "lastName"
    static let phoneKey = "phone"
    static let emailKey = "email"
    
    // MARK: - Properties
    
    var firstName: String
    var lastName: String
    var phone: String
    var email: String
    var recordID: CKRecord.ID
    
    var nameForList: String {
        var name = lastName        
        if firstName.count > 0 {
            if name.count > 0 && firstName.count > 0 {
                name += ", "
            }
            name += firstName
        }
            
        return name
    }
    
    var nameForSort: String { "\(lastName)\(firstName)" }
    
    // MARK: - Init
    
    init(firstName: String, lastName: String, phone: String, email: String, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.firstName = firstName
        self.lastName = lastName
        self.phone = phone
        self.email = email
        self.recordID = recordID
    }
    
    convenience init?(ckRecord: CKRecord) {
        guard let firstName = ckRecord[Contact.firstNameKey] as? String,
              let lastName = ckRecord[Contact.lastNameKey] as? String,
              let phone = ckRecord[Contact.phoneKey] as? String,
              let email = ckRecord[Contact.emailKey] as? String
        else { return nil }
        
        self.init(firstName: firstName, lastName: lastName, phone: phone, email: email, recordID: ckRecord.recordID)
    }
    
    func set(firstName: String, lastName: String, phone: String, email: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.phone = phone
        self.email = email
    }
}

extension CKRecord {
    
    convenience init(contact: Contact) {
        self.init(recordType: Contact.recordType, recordID: contact.recordID)
        self.setValuesForKeys([
            Contact.firstNameKey: contact.firstName,
            Contact.lastNameKey: contact.lastName,
            Contact.phoneKey: contact.phone,
            Contact.emailKey: contact.email
        ])
    }
}
