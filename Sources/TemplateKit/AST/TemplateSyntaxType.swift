/// This enum represents all supported AST types.
///
/// Refer to each type for more information.
public indirect enum TemplateSyntaxType {
    /// See `TemplateRaw`.
    case raw(TemplateRaw)

    /// See `TemplateTag`.
    case tag(TemplateTag)

    /// See `TemplateEmbed`.
    case embed(TemplateEmbed)
    
    /// See `TemplateImport`.
    case `import`(TemplateImport)
    
    /// See `TemplateExtend`.
    case extend(TemplateExtend)

    /// See `TemplateConditional`.
    case conditional(TemplateConditional)

    /// See `TemplateIdentifier`.
    case identifier(TemplateIdentifier)

    /// See `TemplateConstant`.
    case constant(TemplateConstant)

    /// See `TemplateIterator`.
    case iterator(TemplateIterator)

    /// See `TemplateExpression`.
    case expression(TemplateExpression)

    /// See `TemplateCustom`.
    case custom(TemplateCustom)

    /// A unique `String` name for this type.
    public var name: String {
        switch self {
        case .constant: return "constant"
        case .expression: return "expression"
        case .identifier: return "identifier"
        case .raw: return "raw"
        case .tag: return "tag"
        case .embed: return "embed"
        case .import: return "import"
        case .extend: return "extend"
        case .conditional: return "conditional"
        case .iterator: return "iterator"
        case .custom: return "custom"
        }
    }
}
