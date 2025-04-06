import TargetDetails from "./TargetDetails";

/**
 * The set of filters that can be used to filter instructions.
 */
export type Filters = {
  mnemonic: string | RegExp,

  memoryStore: boolean,
  memoryLoad: boolean,

  inputNone: boolean,
  inputFamilies: Set<string>,

  outputNone: boolean,
  outputFamilies: Set<string>,

  predicateNone: boolean,
  predicates: Set<string>,
};

/**
 * An subtype of `Filters` including some additional state that `FilterControls` requires to work.
 * Ideally, this shouldn't be necessary (and should be part of component state), but here we are.
 */
export type InternalFilters = Filters & {
  internalMnemonicString: string,
  internalMnemonicError: string | null,
};


/**
 * A default set of filters to show all instructions.
 */
export function defaultFilters(targetDetails: TargetDetails): InternalFilters {
  return {
    mnemonic: "",

    memoryStore: false,
    memoryLoad: false,

    inputNone: false,
    inputFamilies: new Set(),

    outputNone: false,
    outputFamilies: new Set(),

    predicateNone: true,
    predicates: defaultPredicates(targetDetails),

    // Internals
    internalMnemonicString: "",
    internalMnemonicError: null,
  };
}


/**
 * A default set of predicates.
 */
export function defaultPredicates(targetDetails: TargetDetails): Set<string> {
  return new Set(
    targetDetails.predicateFamilies.flatMap(preds => preds.predicates.map(pred => pred.friendlyName))
  )
}
