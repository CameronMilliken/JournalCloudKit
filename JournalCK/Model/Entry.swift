//
//  Entry.swift
//  JournalCK
//
//  Created by Cameron Milliken on 2/26/19.
//  Copyright © 2019 Cameron Milliken. All rights reserved.
//

import Foundation
import CloudKit

class Entry {
    var title: String
    var body: String
    let ckRecordID: CKRecord.ID
    
    init(title: String, body: String, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.title = title
        self.body = body
        self.ckRecordID = ckRecordID
    }
    
    convenience init?(ckRecord: CKRecord){
        guard let title = ckRecord[Constants.TitleKey] as? String,
            let body = ckRecord[Constants.BodyKey] as? String else { return nil }
        self.init(title: title, body: body, ckRecordID: ckRecord.recordID)
    }
}

// Constants
struct Constants {
    static let TitleKey = "title"
    static let BodyKey = "body"
    static let recordKey = "Entry"
}

// CKRecord
extension CKRecord {
    convenience init(entry: Entry) {
        self.init(recordType: Constants.recordKey, recordID: entry.ckRecordID)
        self.setValue(entry.title, forKey: Constants.TitleKey)
        self.setValue(entry.body, forKey: Constants.BodyKey)
    }
}

// Equatable
extension Entry: Equatable {
    static func == (lhs: Entry, rhs: Entry) -> Bool {
        return lhs.body == rhs.body && lhs.title == rhs.title
    }
}

