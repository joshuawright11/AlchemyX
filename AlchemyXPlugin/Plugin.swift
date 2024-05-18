#if canImport(SwiftCompilerPlugin)
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct AlchemyXPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ResourceMacro.self,
    ]
}
#endif
