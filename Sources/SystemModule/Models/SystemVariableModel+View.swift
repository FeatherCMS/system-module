//
//  SystemVariableModel+View.swift
//  SystemModule
//
//  Created by Tibor Bodecs on 2020. 06. 10..
//

import FeatherCore

extension SystemVariableModel: TemplateDataRepresentable {

    var templateData: TemplateData {
        .dictionary([
            "id": id,
            "key": key,
            "name": name,
            "value": value,
            "notes": notes,
        ])
    }
}
