@attached(extension, conformances: Resource)
@attached(member, names: named(init), named(fields))
public macro Resource() = #externalMacro(module: "AlchemyXPlugin", type: "ResourceMacro")
