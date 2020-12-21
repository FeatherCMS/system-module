//
//  SystemVariableCreateObject.swift
//  SystemModuleApi
//
//  Created by Tibor Bodecs on 2020. 12. 20..
//

import Foundation

public struct SystemVariableCreateObject: Codable {
    
    public var key: String
    public var name: String
    public var value: String?
    public var hidden: Bool?
    public var notes: String?
    
    public init(key: String,
                name: String,
                value: String? = nil,
                hidden: Bool? = nil,
                notes: String? = nil)
    {
        self.key = key
        self.name = name
        self.value = value
        self.hidden = hidden ?? false
        self.notes = notes
    }
}
