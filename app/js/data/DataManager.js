import React from "react";
import TargetDetails from "./TargetDetails.js";
import FilterControls from "../component/FilterControls.jsx";
import ReactHydrator from "../util/ReactHydrator.js";
import Instruction from "./Instruction.js";

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

        // TODO: bad encapsulation, should not be here.
        // But soon it'll all be React so it doesn't matter
        const hydrator = new ReactHydrator();
        hydrator.add("inner-filter-panel", <FilterControls targetDetails={this.details} onChangeFilters={refreshFilters} />);
        hydrator.done();
    }
}
