//
//  SystemVariableModel+Api.swift
//  SystemModule
//
//  Created by Tibor Bodecs on 2020. 12. 20..
//

import FeatherCore
import SystemModuleApi


extension SystemVariableListObject: Content {}
extension SystemVariableGetObject: Content {}
extension SystemVariableCreateObject: ValidatableContent {

    public static func validations(_ validations: inout Validations) {
        validations.add("key", as: String.self, is: !.empty && .count(...250))
        validations.add("name", as: String.self, is: !.empty && .count(...250))
    }
}

extension SystemVariableUpdateObject: ValidatableContent {

    public static func validations(_ validations: inout Validations) {
        validations.add("key", as: String.self, is: !.empty && .count(...250))
        validations.add("name", as: String.self, is: !.empty && .count(...250))
    }
}

extension SystemVariablePatchObject: ValidatableContent {

    public static func validations(_ validations: inout Validations) {
        validations.add("key", as: String.self, is: !.empty && .count(...250), required: false)
        validations.add("name", as: String.self, is: !.empty && .count(...250), required: false)
    }
}


extension SystemVariableModel: ApiContentRepresentable {

    var listContent: SystemVariableListObject {
        .init(id: id!, key: key, value: value)
    }

    var getContent: SystemVariableGetObject {
        .init(id: id!, key: key, name: name, value: value, hidden: hidden, notes: notes)
    }

    func create(_ input: SystemVariableCreateObject) throws {
        key = input.key
        name = input.name
        value = input.value
        hidden = input.hidden ?? false
        notes = input.notes
    }

    func update(_ input: SystemVariableUpdateObject) throws {
        key = input.key
        name = input.name
        value = input.value ?? value
        hidden = input.hidden ?? hidden
        notes = input.notes ?? notes
    }

    func patch(_ input: SystemVariablePatchObject) throws {
        key = input.key ?? key
        name = input.name ?? name
        value = input.value ?? value
        hidden = input.hidden ?? hidden
        notes = input.notes ?? notes
    }
}
