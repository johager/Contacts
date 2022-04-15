//
//  ContactController.swift
//  Contacts
//
//  Created by James Hager on 4/15/22.
//

import Foundation
import CloudKit

class ContactController {
    
    static let shared = ContactController()
    
    var contacts = [Contact]()
    
    private let privateDB = CKContainer.default().privateCloudDatabase
    
    // MARK: - CRUD
    
    func createContact(firstName: String, lastName: String, phone: String, email: String, completion: @escaping (Result<Bool, ContactError>) -> Void) {
        let transactionType = TransactionType.save
        let contactRecord = CKRecord(contact: Contact(firstName: firstName, lastName: lastName, phone: phone, email: email))
        
        privateDB.save(contactRecord) { record, error in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription)\n---\n\(error)")
                return completion(.failure(.ckError(transactionType, error)))
            }
            
            guard let record = record,
                  let contact = Contact(ckRecord: record)
            else { return completion(.failure(.classFromRecord))}
            
            print("\(#function) - saved contact successfully")
            self.contacts.append(contact)
            self.sortContacts()
            completion(.success(true))
        }
    }
    
    func fetchContacts(completion: @escaping (Result<Bool, ContactError>) -> Void) {
        let transactionType = TransactionType.fetch
        
        var fetchedRecords = [CKRecord]()
        
        let query = CKQuery(recordType: Contact.recordType, predicate: NSPredicate(value: true))
        
        var operation = CKQueryOperation(query: query)
        
        operation.recordMatchedBlock = { _, result in
            switch result {
            case .success(let record):
                fetchedRecords.append(record)
            case .failure:
                return
            }
        }
        
        operation.queryResultBlock = { result in
            switch result {
            case .success(let cursor):
                guard let cursor = cursor
                else {
                    self.contacts = fetchedRecords.compactMap { Contact(ckRecord: $0) }
                    self.sortContacts()
                    return completion(.success(true))
                }
                let nextOperation = CKQueryOperation(cursor: cursor)
                nextOperation.queryResultBlock = operation.queryResultBlock
                nextOperation.resultsLimit = operation.resultsLimit
                nextOperation.recordMatchedBlock = operation.recordMatchedBlock
                operation = nextOperation
                self.privateDB.add(nextOperation)
            case .failure(let error):
                completion(.failure(.ckError(transactionType, error)))
            }
        }
        
        privateDB.add(operation)
    }
    
    func update(_ contact: Contact, firstName: String, lastName: String, phone: String, email: String, completion: @escaping (Result<Bool, ContactError>) -> Void) {
        
        let contactRecord = CKRecord(contact: Contact(firstName: firstName, lastName: lastName, phone: phone, email: email, recordID: contact.recordID))
        
        ckModify(recordsToSave: [contactRecord], recordIDsToDelete: nil) { result in
            switch result {
            case .success:
                guard let index = self.contacts.firstIndex(where: { $0.recordID == contactRecord.recordID })
                else { return completion(.failure(.updateContact))}
                
                self.contacts[index].set(firstName: firstName, lastName: lastName, phone: phone, email: email)
                self.sortContacts()
                completion(.success(true))
                
            case .failure(let ckModifyError):
                completion(.failure(.ckModifyError(ckModifyError)))
            }
        }
    }
    
    func delete(atIndex index: Int, completion: @escaping (Result<Bool, ContactError>) -> Void) {
        
        let recordID = contacts[index].recordID
        
        ckModify(recordsToSave: nil, recordIDsToDelete: [recordID]) { result in
            switch result {
            case .success:
                guard let index = self.contacts.firstIndex(where: { $0.recordID == recordID })
                else { return completion(.failure(.updateContact))}
                
                self.contacts.remove(at: index)
                completion(.success(true))
                
            case .failure(let ckModifyError):
                completion(.failure(.ckModifyError(ckModifyError)))
            }
        }
    }
    
    // MARK: - Helper Methods
    
    func ckModify(recordsToSave: [CKRecord]?, recordIDsToDelete: [CKRecord.ID]?, completion: @escaping (Result<Void, CKModifyError>) -> Void) {
        var transactionType: TransactionType!
        if recordsToSave != nil {
            transactionType = .update
        } else if recordIDsToDelete != nil {
            transactionType = .delete
        }
        
        if transactionType == nil {
            return completion(.failure(.ckModifySetUp(transactionType)))
        }
        
        let operation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: recordIDsToDelete)
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        
        operation.modifyRecordsResultBlock = { result in
            switch result {
            case .success():
                print("\(#function) - success \(transactionType!) record")
                return completion(.success(()))
            case .failure(let error):
                return completion(.failure(.ckModifyError(transactionType, error)))
            }
        }
        
        privateDB.add(operation)
    }
    
    func sortContacts() {
        contacts.sort { $0.nameForSort < $1.nameForSort }
    }
}
