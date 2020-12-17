//
//  SystemInstallGuardMiddleware.swift
//  SystemModule
//
//  Created by Tibor Bodecs on 2020. 11. 14..
//

import FeatherCore

/// if the system is not installed we only allow system related operations
struct SystemInstallGuardMiddleware: Middleware {

    /// only allow the root path or the /system/ paths if the system has benn not installed yet, otherwise redirect to the root
    func respond(to req: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        SystemVariableModel.isInstalled(db: req.db).flatMap { installed in
            if !installed && req.url.path != "/system/install/" && req.url.path != "/" {
                return req.eventLoop.future(req.redirect(to: "/"))
            }
            return next.respond(to: req)
        }
    }
    
}
