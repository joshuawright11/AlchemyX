import SwiftSyntax
import SwiftSyntaxMacros

// macro to generate field reading
// macro to generate public init

// macro to generate view? (no - protocol)

public enum ResourceMacro: MemberMacro, ExtensionMacro {
    // MARK: MemberMacro

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.initializers.isEmpty else {
            return []
        }

        let storedProperties = declaration.storedProperties
        return [
            generateInitializer(storedProperties: storedProperties),
            generateFieldLookup(storedProperties: storedProperties),
        ]
    }

    // MARK: ExtensionMacro

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let type = declaration.as(StructDeclSyntax.self) else {
            return []
        }

        return [
            try .init("""
                extension \(type.name): Resource {}
                """)
        ]
    }

    private static func generateInitializer(storedProperties: [Variable]) -> DeclSyntax {
        let parameters = storedProperties.map(\.initializerParameterString).joined(separator: ",\n")
        let assignments = storedProperties.map(\.initializerAssignmentString).joined(separator: "\n")
        return """
            public init(
                \(raw: parameters)
            ) {
                \(raw: assignments)
            }
            """
    }

    private static func generateFieldLookup(storedProperties: [Variable]) -> DeclSyntax {
        let fieldsString = storedProperties.map(\.resourceFieldString).joined(separator: ",\n")
        return """
            public static let fields: [ResourceField] = [
                \(raw: fieldsString)
            ]
            """
    }
}

extension DeclGroupSyntax {
    var initializers: [InitializerDeclSyntax] {
        memberBlock
            .members
            .compactMap { $0.decl.as(InitializerDeclSyntax.self) }
    }

    var storedProperties: [Variable] {
        properties.filter(\.isStored)
    }

    var properties: [Variable] {
        memberBlock
            .members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .map { variable in
                let patterns = variable.bindings.compactMap { PatternBindingSyntax.init($0) }
                let keyword = variable.bindingSpecifier.text
                let name = "\(patterns.first!.pattern.as(IdentifierPatternSyntax.self)!.identifier.text)"
                let type = "\(patterns.first!.typeAnnotation!.type.trimmed)"
                let defaultValue = patterns.first!.initializer.map { "\($0.value.trimmed)" }
                let isStored = patterns.first?.accessorBlock == nil

                return Variable(
                    keyword: keyword,
                    name: name,
                    type: type,
                    defaultValue: defaultValue,
                    isStored: isStored
                )
            }
    }
}

struct Variable {
    let keyword: String
    let name: String
    let type: String
    let defaultValue: String?
    let isStored: Bool

    private var isOptional: Bool {
        type.last == "?"
    }

    var initializerParameterString: String {
        var parameter = "\(name): \(type)"
        if let defaultValue {
            parameter += " = \(defaultValue)"
        } else if isOptional && keyword == "var" {
            parameter += " = nil"
        }

        return parameter
    }

    var initializerAssignmentString: String {
        "self.\(name) = \(name)"
    }

    var resourceFieldString: String {
        """
        .init("\(name)", type: "\(type)")
        """
    }
}
