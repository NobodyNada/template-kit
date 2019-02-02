/// Statically imports a value from an extension.
public struct TemplateImport: CustomStringConvertible {
    /// The identifier of the extension's associated export.
    public var identifier: String
    
    /// Creates a new `TemplateImport`.
    /// - parameters:
    ///     - identifier: The identifier of the extension's associated export.
    public init(identifier: String) {
        self.identifier = identifier
    }
    
    /// See `CustomStringConvertible`
    public var description: String {
        return "import(\(identifier))"
    }
}
