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
    
}
