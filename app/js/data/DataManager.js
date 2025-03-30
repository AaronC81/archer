import React, { useEffect, useState } from "react";
import TargetDetails from "./TargetDetails.js";
import FilterControls from "../component/FilterControls.jsx";
import Instruction from "./Instruction.js";

// TODO: should be completely refactored later to:
//  - not depend on `globalThis`
//  - not maintain static state
export default class DataManager {
    static hasLoadedInstructions = false;
    static async loadInstructions() {
        // Set by page
        const resp = await fetch(`/target/${globalThis.targetName}/data/instructions.json`);
        if (!resp.ok) {
            throw new Error(`unsuccessful response code: ${resp.status}`)
        }

        const instructionData = await resp.json();
        this.instructions = instructionData
            .map(ins => new Instruction(ins));
        this.hasLoadedInstructions = true;
    }

    static hasLoadedDetails = false;
    static async loadDetails() {
        // Set by page
        const resp = await fetch(`/target/${globalThis.targetName}/data/details.json`);
        if (!resp.ok) {
            throw new Error(`unsuccessful response code: ${resp.status}`)
        }

        const detailsData = await resp.json();
        this.details = new TargetDetails(detailsData);
        this.hasLoadedDetails = true;
    }

    static use() {
        const [instructions, setInstructions] = useState(null);
        useEffect(() => {
            DataManager.loadInstructions().then(() => setInstructions(DataManager.instructions));
        }, []);

        const [details, setDetails] = useState(null);
        useEffect(() => {
            DataManager.loadDetails().then(() => setDetails(DataManager.details));
        }, []);

        return { instructions, details };
    }
}
