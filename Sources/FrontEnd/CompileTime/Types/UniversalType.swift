import Utilities

/// The type of a type lambda.
public struct UniversalType: TypeTree {

  /// The variables introduced by the quantifier.
  public let parameters: [GenericParameter.ID]

  /// The type under the quantifier.
  public let body: AnyTypeIdentity

  /// Properties about `self`.
  public var properties: ValueProperties {
    parameters.reduce(body.properties, { (a, i) in a.union(i.properties) })
  }

  /// Returns `self`, which is in `store`, with its parts transformed by `transform(_:_:)`.
  public func modified(
    in store: inout TypeStore,
    by transform: (inout TypeStore, AnyTypeIdentity) -> TypeTransformAction
  ) -> UniversalType {
    .init(parameters: parameters, body: store.map(body, transform))
  }

}

extension UniversalType: Showable {

  /// Returns a textual representation of `self` using `printer`.
  public func show(using printer: inout TreePrinter) -> String {
    let ps = parameters.map { (p) in
      switch printer.program.types[p].kind {
      case .proper:
        return printer.show(p)
      case let k:
        return "\(printer.show(p)) :: \(k)"
      }
    }
    return "<\(list: ps)> \(printer.show(body))"
  }

}
