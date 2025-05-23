/// The declaration of a given.
public enum Given: Hashable {

  /// A user-defined given.
  case user(DeclarationIdentity)

  /// The built-in given of a coercion.
  case coercion(EqualityProperty)

  /// A given implied by a constraint defined in a trait.
  case abstract(AnyTypeIdentity)

  /// A given that is assumed during implicit resolution.
  case assumed(Int, AnyTypeIdentity)

  /// A given nested in a trait.
  indirect case nested(TraitDeclaration.ID, Given)

  /// Returns `true` iff `self` is `.abstract`.
  public var isAbstract: Bool {
    if case .abstract = self { true } else { false }
  }

}
