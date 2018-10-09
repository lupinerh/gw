//
//  Optional-String+nilIfEmpty.swift
//  project
//
//  Created by Stanislav Korolev on 28.02.18.
//  Copyright © 2018 Stanislav Korolev. All rights reserved.
//

extension Optional where Wrapped == String {
    var nilIfEmpty: String? {
        guard let strongSelf = self else {
            return nil
        }
        return strongSelf.isEmpty ? nil : strongSelf
    }
}
