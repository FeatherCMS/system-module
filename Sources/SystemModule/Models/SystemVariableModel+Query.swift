//
//  File.swift
//  SystemModule
//
//  Created by Tibor Bodecs on 2020. 12. 07..
//

import FeatherCore

extension SystemVariableModel {
    
    static func find(key: String, db: Database) -> EventLoopFuture<SystemVariableModel?> {
        SystemVariableModel.query(on: db).filter(\.$key == key).first()
    }

    static func isInstalled(db: Database) -> EventLoopFuture<Bool> {
        SystemVariableModel.find(key: "system.installed", db: db)
            .map { $0 != nil && $0!.value == "true" }
    }
    
    static func setInstalled(db: Database) -> EventLoopFuture<Void> {
        SystemVariableModel(key: "system.installed",
                            name: "System installed",
                            value: "true",
                            hidden: true,
                            notes: "\(Date())")
            .create(on: db)
    }
}
