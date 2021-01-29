//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 01. 29..
//

import FeatherCore
import LiquidLocalDriver

extension Feather {

    func useLocalFileStorage() {
        use(fileStorage: .local(publicUrl: Application.baseUrl,
                                publicPath: Application.Paths.public,
                                workDirectory: "assets"),
            fileStorageId: .local)
    }
}

