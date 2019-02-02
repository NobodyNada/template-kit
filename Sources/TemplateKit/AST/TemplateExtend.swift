/// Statically embeds another template.
public struct TemplateExtend: CustomStringConvertible {
    /// The path of the template to extend.
    public var path: String
    
    /// The values to substitute for the extended template's import tags.
    public var exports: [String:[TemplateSyntax]]
    
    /// Creates a new `TemplateExtend`.
    /// - parameters:
    ///     - path: The path of the template to extend.
    public init(path: String, exports: [String:[TemplateSyntax]]) {
        self.path = path
        self.exports = exports
    }
    
    /// See `CustomStringConvertible`
    public var description: String {
        let exports = self.exports.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
        return "extend(\(path), [\(exports)])"
    }
}
