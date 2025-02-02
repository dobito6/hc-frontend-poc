/// A diagnostic related to a region of Hylo source code.
public struct Diagnostic: Hashable {

  /// The severity of a diagnostic.
  public enum Level: Hashable, Comparable {

    /// A note.
    case note

    /// An error that does not prevent compilation.
    case warning

    /// An unrecoverable error that prevents compilation.
    case error

  }

  /// The level of the diagnostic.
  public let level: Level

  /// The main description of the diagnostic.
  ///
  /// The message should be general and able to stand on its own.
  public let message: String

  /// The source code or source position (if empty) identified as the cause of the error.
  public let site: SourceSpan

  /// The sub-diagnostics.
  public let notes: [Diagnostic]

  /// Creates a new diagnostic.
  ///
  /// - Requires: elements of `notes` have `self.level == .note`
  public init(
    _ level: Level, _ message: String, at site: SourceSpan, notes: [Diagnostic] = []
  ) {
    precondition(notes.allSatisfy({ $0.level == .note }))
    self.level = level
    self.message = message
    self.site = site
    self.notes = notes
  }

  /// Returns a copy of `self` with the given level.
  public func `as`(_ level: Level) -> Self {
    .init(level, message, at: site, notes: notes)
  }

}

extension Diagnostic: Comparable {

  public static func < (l: Self, r: Self) -> Bool {
    let s = l.site
    let t = r.site

    if s.source != t.source {
      return s.source.name.lexicographicallyPrecedes(t.source.name)
    } else if s.start != t.start {
      return s.start < t.start
    } else if l.level != r.level {
      return l.level > r.level
    } else if l.message != r.message {
      return l.message.lexicographicallyPrecedes(r.message)
    } else {
      return l.notes.lexicographicallyPrecedes(r.notes)
    }
  }

}

extension Diagnostic: CustomStringConvertible {

  public var description: String {
    "\(site.gnuStandardText()): \(level): \(message)"
  }

}

extension Program {

  /// Returns an error diagnosing an illegal function application.
  internal func cannotCall(
    _ f: AnyTypeIdentity, _ s: Call.Style, at site: SourceSpan
  ) -> Diagnostic {
    switch s {
    case .parenthesized:
      let m = format("cannot call value of type '%T' as a function", [f])
      return .init(.error, m, at: site)
    case .bracketed:
      let m = format("cannot call value of type '%T' as a subscript", [f])
      return .init(.error, m, at: site)
    }
  }

  /// Returns an error diagnosing an invalid argument to a call.
  internal func cannotPass(
    argument t: AnyTypeIdentity, to u: AnyTypeIdentity, at site: SourceSpan
  ) -> Diagnostic {
    let m = format("cannot pass value of type '%T' to parameter '%T'", [t, u])
    return .init(.error, m, at: site)
  }

  /// Returns an error diagnosing an invalid type expression.
  internal func doesNotDenoteType(_ e: ExpressionIdentity) -> Diagnostic {
    .init(.error, "expression does not denote a type", at: spanForDiagnostic(about: e))
  }

  /// Returns an error diagnosing incompatible labels in a function or subscript application.
  internal func incompatibleLabels<S1: Sequence<String?>, S2: Sequence<String?>>(
    found: S1, expected: S2, at site: SourceSpan, as level: Diagnostic.Level = .error
  ) -> Diagnostic {
    let m = """
      incompatible labels: found '(\(ArgumentLabels(found)))', \
      expected '(\(ArgumentLabels(expected)))'
      """
    return .init(level, m, at: site)
  }

  /// Returns an error diagnosing an invalid redeclaration.
  internal func invalidRedeclaration(
    of n: Name, at site: SourceSpan, previousDeclarations: [SourceSpan] = []
  ) -> Diagnostic {
    let notes = previousDeclarations.map { (s) in
      Diagnostic(.note, "previous declaration here", at: s)
    }
    return .init(.error, "invalid redeclaration of '\(n)'", at: site, notes: notes)
  }

  /// Returns an error diagnosing ambiguous implicit search results.
  internal func multipleGivenInstances(
    of t: AnyTypeIdentity, at site: SourceSpan
  ) -> Diagnostic {
    .init(.error, format("multiple given instance of '%T' in this scope", [t]), at: site)
  }

  /// Returns an error diagnosing an invalid coercion.
  internal func noCoercion(
    from t: AnyTypeIdentity, to u: AnyTypeIdentity, at site: SourceSpan,
    because notes: [Diagnostic] = []
  ) -> Diagnostic {
    .init(.error, format("no coercion from '%T' to '%T'", [t, u]), at: site, notes: notes)
  }

  /// Returns an error diagnosing an invalid conversion.
  internal func noConversion(
    from t: AnyTypeIdentity, to u: AnyTypeIdentity, at site: SourceSpan
  ) -> Diagnostic {
    .init(.error, format("no conversion from '%T' to '%T'", [t, u]), at: site)
  }

  /// Returns an error diagnosing a missing given instance.
  internal func noGivenInstance(
    of t: AnyTypeIdentity, at site: SourceSpan
  ) -> Diagnostic {
    .init(.error, format("no given instance of '%T' in this scope", [t]), at: site)
  }

  /// Returns an error diagnosing a failure to infer a type due to lacking context.
  internal func notEnoughContext(_ n: AnySyntaxIdentity) -> Diagnostic {
    .init(.error, "not enough context to infer a type", at: spanForDiagnostic(about: n))
  }

  /// Returns an error diagnosing an undefined symbol.
  internal func undefinedSymbol(
    _ n: Name, memberOf t: AnyTypeIdentity? = nil, at site: SourceSpan
  ) -> Diagnostic {
    let m = if let u = t {
      format("type '%T' has no member '\(n)'", [u])
    } else {
      "undefined symbol '\(n)'"
    }
    return .init(.error, m, at: site)
  }

  /// Returns an error diagnosing an undefined symbol.
  internal func undefinedSymbol(
    _ n: Parsed<Name>, memberOf t: AnyTypeIdentity? = nil
  ) -> Diagnostic {
    undefinedSymbol(n.value, memberOf: t, at: n.site)
  }

}
