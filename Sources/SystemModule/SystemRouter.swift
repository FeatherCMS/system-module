//
//  SystemRouter.swift
//  SystemModule
//
//  Created by Tibor Bödecs on 2020. 06. 10..
//

import FeatherCore

final class SystemRouter: ViperRouter {

    let adminController = SystemVariableAdminController()
    
    func adminRoutesHook(args: HookArguments) {
        let routes = args["routes"] as! RoutesBuilder

        let modulePath = routes.grouped(SystemModule.pathComponent)
        adminController.setupRoutes(on: modulePath, as: SystemVariableModel.pathComponent)
    }
}
