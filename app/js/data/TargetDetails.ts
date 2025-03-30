// Matches `Adapter#adapt_details` -----------------------------------------------------------------
interface TargetDetails {
    name: string,
    title: string,
    assemblyVariants: string[],
    operandTypeFamilies: TargetOperandTypeFamily[],
    predicates: TargetPredicate[],
}
interface TargetOperandTypeFamily {
    name: string,
    style: string,
}
interface TargetPredicate {
    friendlyName: string,
    important: boolean,
}
// -------------------------------------------------------------------------------------------------

/**
 * Details about the properties of a target.
 * 
 * Properties are defined by the JSON returned from the server. This provides some helper methods
 * for that data.
 */
class TargetDetails {
    constructor(obj: any) {
        Object.assign(this, obj)
    }
}

export default TargetDetails;
