//
//  SystemBuilder.swift
//  SystemModule
//
//  Created by Tibor Bodecs on 2020. 08. 23..
//

import FeatherCore

@_cdecl("createSystemModule")
public func createSystemModule() -> UnsafeMutableRawPointer {
    return Unmanaged.passRetained(SystemBuilder()).toOpaque()
}

public final class SystemBuilder: ViperBuilder {

    public override func build() -> ViperModule {
        SystemModule()
    }
}
