import SwiftSyntax

struct Resource {
    struct Property {
        let keyword: String
        let name: String
        let type: String
        let defaultValue: String?
        let isStored: Bool

        var isOptional: Bool {
            type.last == "?"
        }
    }

    /// The type's access level - public, private, etc
    let accessLevel: String?
    /// The type name
    let name: String
    /// The type's properties
    let properties: [Property]

    /// The type's stored properties
    var storedProperties: [Property] {
        properties.filter(\.isStored)
    }
}

extension Resource {
    static func parse(syntax: DeclSyntaxProtocol) throws -> Resource {
        guard let `struct` = syntax.as(StructDeclSyntax.self) else {
            throw AlchemyXPluginError("For now, @Resource can only be applied to a struct")
        }

        return Resource(
            accessLevel: `struct`.accessLevel,
            name: `struct`.structName,
            properties: `struct`.members.map(Resource.Property.parse)
        )
    }
}

extension Resource.Property {
    static func parse(variable: VariableDeclSyntax) -> Resource.Property {
        let patterns = variable.bindings.compactMap { PatternBindingSyntax.init($0) }
        let keyword = variable.bindingSpecifier.text
        let name = "\(patterns.first!.pattern.as(IdentifierPatternSyntax.self)!.identifier.text)"
        let type = "\(patterns.first!.typeAnnotation!.type.trimmed)"
        let defaultValue = patterns.first!.initializer.map { "\($0.value.trimmed)" }
        let isStored = patterns.first?.accessorBlock == nil

        return Resource.Property(
            keyword: keyword,
            name: name,
            type: type,
            defaultValue: defaultValue,
            isStored: isStored
        )
    }
}
