//
//  EntryController.swift
//  JournalCK
//
//  Created by Cameron Milliken on 2/26/19.
//  Copyright © 2019 Cameron Milliken. All rights reserved.
//

import Foundation
import CloudKit

class EntryController {
    
    var entries: [Entry] = []
    
    // CRUD Functions
    
    //Save
    func save(entry: Entry, completion: @escaping (Bool) -> Void) {
        let record = CKRecord(entry: entry)
        CKContainer.default().privateCloudDatabase.save(record) { (record, error) in
            if let error = error{
                print("\(error.localizedDescription) \(error) in function: \(#function)")
                completion(false)
                return
            }
            guard let record = record, let entry = Entry(ckRecord: record) else { completion(false) ; return }
            self.entries.append(entry)
            completion(true)
        }
    }
    
    // Create
    func addEntryWith(title: String, body: String, completion: @escaping (Bool) -> Void){
        let newEntry = Entry(title: title, body: body)
        self.save(entry: newEntry) { (success) in
            if success {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    // Update
    func updateEntry(entry: Entry, title: String, body: String, completion: @escaping (Bool) -> Void){
        // update locally
        entry.title = title
        entry.body = body
        
        // Updates CloudKit
        CKContainer.default().privateCloudDatabase.fetch(withRecordID: entry.ckRecordID) { (record, error) in
            if let error = error {
                print("\(error.localizedDescription) \(error) in function: \(#function)")
                completion(false)
                return
            }
            guard let record = record else { completion(false) ; return }
            record[Constants.TitleKey] = title
            record[Constants.BodyKey] = body
            
            let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            operation.savePolicy = .changedKeys
            operation.queuePriority = .high
            operation.qualityOfService = .userInitiated
            operation.modifyRecordsCompletionBlock = { (records, recordIDs, error) in
                completion(true)
            }
            CKContainer.default().privateCloudDatabase.add(operation)
        }
    }
    
    // Delete
    func remove(entry: Entry, completion: @escaping (Bool) -> Void) {
        
        // Deletes the entry on CloudKit
        CKContainer.default().privateCloudDatabase.delete(withRecordID: entry.ckRecordID) { (_, error) in
            if let error = error {
                print("\(error.localizedDescription) \(error) in function: \(#function)")
                completion(false)
                return
            } else {
                print("Successful removed item")
                completion(true)
            }
        }
        
        // Deletes the entry locally
        guard let index = entries.index(of: entry) else { completion(false) ; return }
        entries.remove(at: index)
    }
    
    // Fetch Entry
    func fetchEntries(completion: @escaping (Bool)-> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: Constants.recordKey, predicate: predicate)
        CKContainer.default().privateCloudDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error{
                print("\(error.localizedDescription) \(error) in function: \(#function)")
                completion(false)
                return
            }
            guard let records = records else { completion(false) ; return }
            let entries = records.compactMap { Entry(ckRecord: $0) }
            self.entries = entries
            completion(true)
        }
    }
} // End of Class
