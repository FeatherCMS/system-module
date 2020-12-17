//
//  SystemModule.swift
//  SystemModule
//
//  Created by Tibor Bödecs on 2020. 06. 10..
//

import FeatherCore

final class SystemModule: ViperModule {

    static var name: String = "system"
    var priority: Int { 9000 }

    var router: ViperRouter? { SystemRouter() }

    var migrations: [Migration] {
        [
            SystemMigration_v1_0_0(),
        ]
    }
    
    var middlewares: [Middleware] {
        [
            SystemInstallGuardMiddleware(),
        ]
    }
    
    static var bundleUrl: URL? {
        Bundle.module.resourceURL?.appendingPathComponent("Bundle")
    }
    
    func leafDataGenerator(for req: Request) -> [String: LeafDataGenerator]? {
        let variables = req.cache["system.variables"] as? [String: String?] ?? [:]
        return [
            "variables": .lazy(LeafData.dictionary(variables))
        ]
    }

    func boot(_ app: Application) throws {
        /// install
        app.hooks.register("model-install", use: modelInstallHook)
        app.hooks.register("user-permission-install", use: userPermissionInstallHook)

        /// admin
        app.hooks.register("admin", use: (router as! SystemRouter).adminRoutesHook)
        app.hooks.register("leaf-admin-menu", use: leafAdminMenuHook)
        
        /// cache
        app.hooks.register("prepare-request-cache", use: prepareRequestCacheHook)
        
        /// variables
        app.hooks.register("variable-get", use: variableGetHook)
        app.hooks.register("variable-set", use: variableSetHook)

        /// frontend
        app.hooks.register("frontend-page", use: frontendPageHook)
    }
    
    // MARK: - hooks

    func leafAdminMenuHook(args: HookArguments) -> LeafDataRepresentable {
        let app = args["app"] as! Application
        var items = [
            [
                "url": "/admin/system/variables/",
                "label": "Variables",
                "permission": "system.variables.list",
            ],
        ]
        /// if the frontend module is enabled (hacky, but it's fine.)
        if app.viper.modules.first(where: { $0.name == "frontend" }) != nil {
            items.append([
                "url": "/admin/frontend/metadatas/",
                "label": "Metadatas",
                "permission": "frontend.metadatas.list",
            ])
        }
        return [
            "name": "System",
            "icon": "settings",
            "permission": "system.module.access",
            "items": LeafData.array(items)
        ]
    }

    func prepareRequestCacheHook(args: HookArguments) -> EventLoopFuture<[String: Any?]> {
        let req = args["req"] as! Request
        return SystemVariableModel.query(on: req.db).all().map { variables in
            var items: [String: String] = [:]
            for variable in variables {
                items[variable.key] = variable.value
            }
            return items
        }
        .map { items in
             ["system.variables": items as Any?]
        }
    }

    func variableGetHook(args: HookArguments) -> EventLoopFuture<String?> {
        let req = args["req"] as! Request
        let key = args["key"] as! String
        return SystemVariableModel.find(key: key, db: req.db).map { $0?.value }
    }

    func variableSetHook(args: HookArguments) -> EventLoopFuture<Void> {
        let req = args["req"] as! Request
        let key = args["key"] as! String
        let value = args["value"] as? String
        return SystemVariableModel.query(on: req.db)
            .filter(\.$key == key)
            .set(\.$value, to: value?.emptyToNil)
            .update()
    }

    func frontendPageHook(args: HookArguments) -> EventLoopFuture<Response?> {
        let req = args["req"] as! Request

        /// check if system is already installed, if yes we don't do anything
        return SystemVariableModel.isInstalled(db: req.db).flatMap { [unowned self] installed -> EventLoopFuture<Response?> in
            if installed {
                return req.eventLoop.future(nil)
            }
            return systemInstallStep(req: req).encodeOptionalResponse(for: req)
        }
    }
    
    // MARK: - perform install steps
    
    /// @TODO: we should add a steppable hook system for adding custom install steps...
    func systemInstallStep(req: Request) -> EventLoopFuture<View> {
        /// if the system path equals install, we render the start install screen
        guard req.url.path == "/system/install/" else {
            return req.leaf.render("System/Install/Start")
        }
    
        /// create assets path under the public directory
        let assetsPath = Application.Paths.assets

        do {
            /// @TODO: this should be done by FeatherCore...
            try FileManager.default.createDirectory(atPath: Application.Paths.assets,
                                                    withIntermediateDirectories: true,
                                                    attributes: [.posixPermissions: 0o744])
        }
        catch {
            fatalError(error.localizedDescription)
        }

        /// copy module assets if necessary
        for module in req.application.viper.modules {
            let name = module.name.lowercased()
            guard let moduleBundle = module.bundleUrl else {
                continue
            }
            /// @TODO: we should use the file storage and upload these files to the appropreate storage
            let sourcePath = moduleBundle.appendingPathComponent("Install").path
            let destinationPath = assetsPath + name + "/"

            do {
                var isDir : ObjCBool = false
                if FileManager.default.fileExists(atPath: sourcePath, isDirectory: &isDir), isDir.boolValue {
                    try FileManager.default.copyItem(atPath: sourcePath, toPath: destinationPath)
                }
            }
            catch {
                fatalError(error.localizedDescription)
            }
        }

        /// we request the install futures for the database model creation
        let modelInstallFutures: [EventLoopFuture<Void>] = req.invokeAll("model-install")
        return req.eventLoop.flatten(modelInstallFutures)
            .flatMap { SystemVariableModel.setInstalled(db: req.db) }
            .flatMap { req.leaf.render("System/Install/Finish") }
            .flatMapError { err in
                /// @TODO: we should present a proper failure page...
                print(err.localizedDescription)
                return req.eventLoop.future(error: err)
            }
            
    }
}
