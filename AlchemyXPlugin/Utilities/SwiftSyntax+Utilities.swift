import SwiftSyntax

extension DeclGroupSyntax {
    var hasInit: Bool {
        !initializers.isEmpty
    }
    
    var initializers: [InitializerDeclSyntax] {
        memberBlock
            .members
            .compactMap { $0.decl.as(InitializerDeclSyntax.self) }
    }

    var accessLevel: String? {
        modifiers.first?.trimmedDescription
    }

    var members: [VariableDeclSyntax] {
        memberBlock
            .members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
    }
}

extension StructDeclSyntax {
    var structName: String {
        name.text
    }
}
