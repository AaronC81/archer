import TargetDetails from "./TargetDetails";

/**
 * The set of filters that can be used to filter instructions.
 */
export type Filters = {
    mnemonic: string,

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
 * A default set of filters to show all instructions.
 */
export function defaultFilters(targetDetails: TargetDetails): Filters {
    return {
        mnemonic: "",

        memoryStore: false,
        memoryLoad: false,

        inputNone: false,
        inputFamilies: new Set(),

        outputNone: false,
        outputFamilies: new Set(),

        predicateNone: true,
        predicates: new Set(targetDetails.predicates.map(pred => pred.friendlyName)),
    };
}
