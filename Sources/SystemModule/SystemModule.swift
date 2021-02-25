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
        app.hooks.register("leaf-admin-menu", use: leafAdminMenuHook)
        /// routes
        app.hooks.register("frontend-route", use: frontendRouteHook)
        app.hooks.register("admin-routes", use: (router as! SystemRouter).adminRoutesHook)
        app.hooks.register("public-api-routes", use: (router as! SystemRouter).publicApiRoutesHook)
        app.hooks.register("api-routes", use: (router as! SystemRouter).apiRoutesHook)
        /// cache
        app.hooks.register("prepare-request-cache", use: prepareRequestCacheHook)
        /// variables
        app.hooks.register("variable-get", use: variableGetHook)
        app.hooks.register("variable-set", use: variableSetHook)
    }
    
    // MARK: - hooks

    func leafAdminMenuHook(args: HookArguments) -> LeafDataRepresentable {
        [
            "name": "System",
            "icon": "settings",
            "permission": "system.module.access",
            "items": LeafData.array([
                [
                    "url": "/admin/system/variables/",
                    "label": "Variables",
                    "permission": "system.variables.list",
                ],
            ])
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

    func frontendRouteHook(args: HookArguments) -> EventLoopFuture<Response?> {
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
    
        /// upload bundled images using the file storage if there are some files under the Install folder inside the module bundle
        var fileUploadFutures: [EventLoopFuture<Void>] = []
        for module in req.application.viper.modules {
            guard let moduleBundle = module.bundleUrl else {
                continue
            }
            let name = module.name.lowercased()
            let sourcePath = moduleBundle.appendingPathComponent("Install").path
            let sourceUrl = URL(fileURLWithPath: sourcePath)
            let keys: [URLResourceKey] = [.isDirectoryKey]
            
            let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]
 
            let urls = FileManager.default.enumerator(at: sourceUrl, includingPropertiesForKeys: keys, options: options)!
            for case let fileUrl as URL in urls {
                let resourceValues = try? fileUrl.resourceValues(forKeys: Set(keys))
                if resourceValues?.isDirectory ?? true {
                    continue
                }
                let relativePath = String(fileUrl.path.dropFirst(sourceUrl.path.count + 1))
                let relativeUrl = URL(fileURLWithPath: relativePath, relativeTo: sourceUrl)
                let future = req.fileio.collectFile(at: relativeUrl.path).flatMap { byteBuffer -> EventLoopFuture<Void> in
                    guard let data = byteBuffer.getData(at: 0, length: byteBuffer.readableBytes) else {
                        return req.eventLoop.future()
                    }
                    return req.fs.upload(key: name + "/" + relativeUrl.relativePath, data: data).map { _ in }
                }
                fileUploadFutures.append(future)
            }
        }

        /// we request the install futures for the database models & execute them together with the file upload futures in parallel
        let modelInstallFutures: [EventLoopFuture<Void>] = req.invokeAll("model-install")
        return req.eventLoop.flatten(modelInstallFutures + fileUploadFutures)
            .flatMap { SystemVariableModel.setInstalled(db: req.db) }
            .flatMap { req.leaf.render(template: "System/Install/Finish") }
            .flatMapError { err in
                req.leaf.render(template: "System/Install/Error", context: [
                    "error": .string(err.localizedDescription),
                ])
            }
            
    }
}
