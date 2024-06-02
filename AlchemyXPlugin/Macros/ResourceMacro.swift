import SwiftSyntax
import SwiftSyntaxMacros

public enum ResourceMacro: MemberMacro, ExtensionMacro {
    
    // MARK: MemberMacro

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let resource = try Resource.parse(syntax: declaration)
        return [
            declaration.hasInit ? nil : resource.generateInitializer(),
            resource.generateFieldLookup(),
        ]
        .compactMap { $0 }
        .map { $0.declSyntax() }
    }

    // MARK: ExtensionMacro

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let resource = try Resource.parse(syntax: declaration)
        return try [
            Declaration("extension \(resource.name): Resource") {}
                .extensionDeclSyntax()
        ]
    }
}

extension Resource {
    fileprivate func generateInitializer() -> Declaration {
        let parameters = storedProperties.map {
            if let defaultValue = $0.defaultValue {
                "\($0.name): \($0.type) = \(defaultValue)"
            } else if $0.isOptional && $0.keyword == "var" {
                "\($0.name): \($0.type) = nil"
            } else {
                "\($0.name): \($0.type)"
            }
        }
        .joined(separator: ", ")
        return Declaration("init(\(parameters))") {
            for property in storedProperties {
                "self.\(property.name) = \(property.name)"
            }
        }
        .access(accessLevel)
    }

    fileprivate func generateFieldLookup() -> Declaration {
        let fieldsString = storedProperties
            .map { property in
                let key = "\\\(name).\(property.name)"
                let defaultValue = property.defaultValue
                let defaultArgument = defaultValue.map { ", default: \($0)" } ?? ""
                let value = ".init(\(property.name.inQuotes), type: \(property.type).self\(defaultArgument))"
                return "\(key): \(value)"
            }
            .joined(separator: ",\n")
        return Declaration("""
            public static let fields: [PartialKeyPath<\(name)>: ResourceField] = [
                \(fieldsString)
            ]
            """)
    }
}
