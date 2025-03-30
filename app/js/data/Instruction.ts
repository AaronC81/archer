import { Filters } from "./Filters";

// Matches `Adapter#adapt_instructions` ------------------------------------------------------------
interface InstructionAssemblyVariant {
    mnemonic: string,
    format: string,
    html: string,
}
interface InstructionPredicate {
    friendly_name: string,
    important: boolean,
}
interface InstructionDocumentation {
    text: string,
    url: string,
}
interface InstructionOperand {
    name: string,
    operandType: string,
    operandTypeFamily: string,
    operandTypeFamilyStyle: string,
}
interface Instruction {
    name: string;
    assemblyVariants: InstructionAssemblyVariant[];

    mayStore: boolean;
    mayLoad: boolean;

    inputs: InstructionOperand[],
    outputs: InstructionOperand[],

    implicitInputs: string[];
    implicitOutputs: string[];

    predicates: InstructionPredicate[];

    documentation: InstructionDocumentation | null;
}
// -------------------------------------------------------------------------------------------------

/**
 * A machine instruction.
 * 
 * Properties are defined by the JSON returned from the server. This provides some helper methods
 * for that data.
 */
class Instruction {
    constructor(obj: any) {
        Object.assign(this, obj)
    }

    matchesFilters(filters: Filters, anchor: string | null, assemblyVariant: number) {
        const {
            mnemonic,
            memoryStore, memoryLoad,
            inputNone, inputFamilies,
            outputNone, outputFamilies,
            predicateNone, predicates,
        } = filters;

        // Specific instruction filter
        if (anchor && this.name != anchor)
            return false;

        // Memory characteristic filters
        if (memoryStore && !this.mayStore)
            return false;
        if (memoryLoad && !this.mayLoad)
            return false;

        // Textual filter
        if (mnemonic && !this.assemblyVariants[assemblyVariant].mnemonic.includes(mnemonic))
            return false;

        // Operand filters
        if (inputFamilies.size > 0) {
            if (![...inputFamilies].every(o => this.inputs.map(i => i.operandTypeFamily).includes(o)))
                return false;
        }
        if (outputFamilies.size > 0) {
            if (![...outputFamilies].every(o => this.outputs.map(i => i.operandTypeFamily).includes(o)))
                return false;
        }
        if (inputNone && this.inputs.length > 0)
            return false;
        if (outputNone && this.outputs.length > 0)
            return false;

        // Predicate filters
        // Either one of the following must be true for the instruction to show up:
        //   (1) This instruction has no predicates, and the user has ticked "None", and 
        //   (2) This instruction has some predicates, and the user has ticked all of them
        if (this.predicates.length == 0) {
            // (1)
            if (!predicateNone)
                return false;
        } else {
            // (2)
            if (!this.predicates.every(p => predicates.has(p.friendly_name)))
                return false;
        }

        return true;
    }
    
    hasAnyInputs() {
        return this.inputs.length > 0 ||
               this.implicitInputs.length > 0 ||
               this.mayLoad;
    }

    hasAnyOutputs() {
        return this.outputs.length > 0 ||
               this.implicitOutputs.length > 0 ||
               this.mayStore;
    }
}

export default Instruction;
