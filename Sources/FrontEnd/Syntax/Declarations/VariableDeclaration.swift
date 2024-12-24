import Archivist

/// The declaration of a variable in a pattern binding.
///
/// A variable declaration always appear nested inside some pattern. For instance, the following
/// source-level declaration involves two variable declarations nested in a binding pattern.
///
///     let (x, y) = f()
public struct VariableDeclaration: Declaration, Pattern {

  /// The identifier of the declared variable.
  public let identifier: Parsed<String>

  /// The site from which `self` was parsed.
  public var site: SourceSpan { identifier.site }

  /// Returns a parsable representation of `self`, which is a node of `program`.
  public func show(readingChildrenFrom program: Program) -> String {
    identifier.description
  }

}

extension VariableDeclaration: Archivable {

  public init<T>(from archive: inout ReadableArchive<T>, in context: inout Any) throws {
    self.identifier = try archive.read(Parsed<String>.self, in: &context)
  }

  public func write<T>(to archive: inout WriteableArchive<T>, in context: inout Any) throws {
    try archive.write(identifier, in: &context)
  }

}
