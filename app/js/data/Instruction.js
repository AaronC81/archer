/**
 * A machine instruction.
 * 
 * Properties are defined by the JSON returned from the server. This provides some helper methods
 * for that data.
 */
export default class Instruction {
    constructor(obj) {
        Object.assign(this, obj)
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
