import TemplateKit
import XCTest

class ExtensionTests: XCTestCase {
    class TestRenderer: TemplateRenderer {
        var tags: [String : TagRenderer] = defaultTags
        
        var asts: [String:[TemplateSyntax]] = [:]
        
        // Returns a hardcoded AST, using the filename as a selector.
        struct TestParser: TemplateParser {
            weak var renderer: TestRenderer!
            init(renderer: TestRenderer) { self.renderer = renderer }
            
            func parse(scanner: TemplateByteScanner) throws -> [TemplateSyntax] {
                return renderer.asts[URL(fileURLWithPath: scanner.file).lastPathComponent]!
            }
        }
        lazy var parser: TemplateParser = TestParser(renderer: self)
        
        var astCache: ASTCache? = nil
        
        var templateFileEnding: String = ""
        var relativeDirectory: String = URL(fileURLWithPath: #file).deletingLastPathComponent().path + "/"
        
        var container: Container
        init(container: Container) {
            self.container = container
        }
    }
    
    let renderer = TestRenderer(
        container: BasicContainer(config: .init(), environment: .testing, services: .init(), on: EmbeddedEventLoop())
    )
    
    func testSimpleExtensionResolution() throws {
        renderer.asts = [
            "extension": [
                .raw("Before"),
                .extend("extended"),
                .raw("After")
            ],
            "extended": [.raw("Extension") ]
        ]
        print(try renderer.resolveExtensions(renderer.asts["extension"]!))
        XCTAssertEqual(try renderer.testRender("extension"), "BeforeExtensionAfter")
    }
    
    func testImports() throws {
        renderer.asts = [
            "extension": [
                .raw("Before"),
                .extend("extended", exports: [
                    "export1": [.raw("Export1")],
                    "export2": [.raw("Export2")],
                    "export3": [.integer(5)],
                    ]),
                .raw("After")
            ],
            "extended": [
                .raw("Extension"),
                .import("export1"),
                .init(
                    type: .conditional(.init(
                        condition: TemplateSyntax(
                            type: .expression(.infix(op: .lessThan, left: .integer(1), right: .import("export3"))),
                            source: TemplateSyntax.testSource
                        ),
                        body: [.import("export2")])),
                    source: TemplateSyntax.testSource
                )
            ]
        ]
        
        print(try renderer.resolveExtensions(renderer.asts["extension"]!))
        XCTAssertEqual(try renderer.testRender("extension"), "BeforeExtensionExport1Export2After")
    }
    
    func testNestedExtensions() throws {
        //tanner0101's nested extension example from https://forums.swift.org/t/pitch-leaf-view-extensions/18194
        renderer.asts = [
            "extended": [
                .raw("<html><head><title>"),
                .import("title"),
                .raw("</title></head><body>"),
                .import("body"),
                .raw("</body></html>")
            ],
            "alert": [
                .raw("<alert style="),
                .import("class"),
                .raw("><p>"),
                .import("message"),
                .raw("</p></alert>")
            ],
            "extension": [
                .extend("extended", exports: [
                    "title": [.raw("Welcome")],
                    "body": [
                        .extend("alert", exports: [
                            "class": [.raw("warning")],
                            "message": [.identifier("alert", "message")],
                            ]),
                        .raw("Hello, "), .tag(name: "", parameters: [.identifier("name")]), .raw("!")
                    ]
                    ])
            ],
        ]
        
        print(try renderer.resolveExtensions(renderer.asts["extension"]!))
        let context = TemplateData.dictionary(["name": .string("Vapor"), "alert": .dictionary(["message": .string("Test")])])
        XCTAssertEqual(
            try renderer.testRender("extension", context),
            "<html><head><title>Welcome</title></head><body><alert style=warning>" +
            "<p>Test</p></alert>Hello, Vapor!</body></html>"
        )
    }
}

extension TemplateSyntax {
    static let testSource = TemplateSource(file: "", line: 0, column: 0, range: 0..<0)
    
    static func integer(_ value: Int) -> TemplateSyntax {
        return .init(type: .constant(.int(value)), source: testSource)
    }
    
    static func identifier(_ names: String...) -> TemplateSyntax {
        return .init(type: .identifier(.init(path: names.map(BasicKey.init))), source: testSource)
    }
    
    static func tag(name: String, parameters: [TemplateSyntax], body: [TemplateSyntax]? = nil) -> TemplateSyntax {
        return .init(type: .tag(.init(name: name, parameters: parameters, body: body)), source: testSource)
    }
    
    static func raw(_ text: String) -> TemplateSyntax {
        return .init(type: .raw(.init(data: text.data(using: .utf8)!)), source: testSource)
    }
    
    static func extend(_ path: String, exports: [String:[TemplateSyntax]] = [:]) -> TemplateSyntax {
        return .init(type: .extend(.init(path: path, exports: exports)), source: testSource)
    }
    
    static func `import`(_ identifier: String) -> TemplateSyntax {
        return .init(type: .import(.init(identifier: identifier)), source: testSource)
    }
}

extension TemplateRenderer {
    func testRender(_ path: String, _ context: TemplateData = .null) throws -> String {
        let view = try self.render(path, context).wait()
        return String(data: view.data, encoding: .utf8)!
    }
}
