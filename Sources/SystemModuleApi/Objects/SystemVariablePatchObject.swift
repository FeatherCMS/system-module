//
//  SystemVariablePatchObject.swift
//  SystemModuleApi
//
//  Created by Tibor Bodecs on 2020. 12. 20..
//

import Foundation

public struct SystemVariablePatchObject: Codable {

    public var key: String?
    public var name: String?
    public var value: String?
    public var hidden: Bool?
    public var notes: String?
    
    public init(key: String? = nil,
                name: String? = nil,
                value: String? = nil,
                hidden: Bool? = nil,
                notes: String? = nil)
    {
        self.key = key
        self.name = name
        self.value = value
        self.hidden = hidden
        self.notes = notes
    }
}
