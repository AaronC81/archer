import { createRoot } from "react-dom/client";
import ResultCard from "./component/ResultCard.jsx";
import "./test.jsx"

class ReactHydrator {
    constructor() {
        this.pendingElements = {};
    }

    add(id, component) {
        this.pendingElements[id] = component;
    }

    done() {
        for (const [id, component] of Object.entries(this.pendingElements)) {
            const element = document.getElementById(id);
            createRoot(element).render(component);
        }
    }
}

/**
 * A machine instruction.
 * 
 * Properties are defined by the JSON returned from the server. This provides some helper methods
 * for that data.
 */
class Instruction {
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

class DataManager {
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
}

// Ask to load instructions
// This function is async, but we don't await it - it'll just happen in the background
DataManager.loadInstructions()
    .then(() => refreshFilters()) // Show results as soon as we have data
    .catch(e => {
        const loadingIndicator = document.getElementById("instruction-data-loading-indicator");
        loadingIndicator.innerHTML = `
            <b>An error occurred while loading data.</b><br>
            Sorry! Try refreshing the page?<br>
            <br>
            <code>${e}</code>
        `;
        loadingIndicator.classList.add("error");
    });

const mnemonicFilter = document.getElementById("input-mnemonic-filter");
const storeFilter = document.getElementById("input-store-filter");
const loadFilter = document.getElementById("input-load-filter");

const operandInputFilters = [...document.querySelectorAll(".input-operand-input-filter")];
const operandOutputFilters = [...document.querySelectorAll(".input-operand-output-filter")];

const operandNoInputsFilter = document.getElementById("input-operand-input-none-filter");
const operandNoOutputsFilter = document.getElementById("input-operand-output-none-filter");

const predicateFilters = [...document.querySelectorAll(".input-predicate-filter")];
const predicateNoneFilter = document.getElementById("input-predicate-none-filter");

const instructionResults = document.getElementById("instruction-results");

const assemblyVariantSelector = document.getElementById("assembly-variant-selector");

const resultLimit = 500;

function selectNoPredicates() {
    // Deselect all additional predicates, but keep 'None' selected
    // (This is _probably_ the behaviour you're after...)
    predicateNoneFilter.checked = true;
    predicateFilters.forEach(el => el.checked = false);

    refreshFilters();
}

function selectAllPredicates() {
    // Select everything
    predicateNoneFilter.checked = true;
    predicateFilters.forEach(el => el.checked = true);

    refreshFilters();
}

function clearAnchor() {
    window.location.hash = "";
    refreshFilters();
}

function refreshFilters() {
    // If data hasn't loaded, don't show anything for now
    if (!DataManager.hasLoadedInstructions)
        return;

    // Anchor can be used to show one specific LLVM instruction
    // If not specified, this is just the empty string
    const anchor = window.location.hash.substring(1);

    // Load filter values
    const storeFilterValue = storeFilter.checked;
    const loadFilterValue = loadFilter.checked;
    const mnemonicFilterValue = mnemonicFilter.value.trim();

    const operandInputFilterValues = operandInputFilters
        .filter(el => el.checked)
        .map(el => el.dataset.operandName);
    const operandOutputFilterValues = operandOutputFilters
        .filter(el => el.checked)
        .map(el => el.dataset.operandName);

    const operandNoInputsFilterValue = operandNoInputsFilter.checked;
    const operandNoOutputsFilterValue = operandNoOutputsFilter.checked;

    const satisfiedPredicates = predicateFilters
        .filter(el => el.checked)
        .map(el => el.dataset.predicateName);
    const predicateNoneFilterValue = predicateNoneFilter.checked;

    let assemblyVariant;
    if (assemblyVariantSelector) {
        assemblyVariant = parseInt(assemblyVariantSelector.value);
    } else {
        assemblyVariant = 0;
    }

    var includedResults = 0;
    var htmlString = "";
    const hydrator = new ReactHydrator();
    for (var i = 0; i < DataManager.instructions.length; i++) {
        const instruction = DataManager.instructions[i];

        // Specific instruction filter
        if (anchor && instruction.name != anchor)
            continue;

        // Memory characteristic filters
        if (storeFilterValue && !instruction.mayStore)
            continue;
        if (loadFilterValue && !instruction.mayLoad)
            continue;

        // Textual filter
        if (mnemonicFilterValue && !instruction.assemblyVariants[assemblyVariant].mnemonic.includes(mnemonicFilterValue))
            continue;

        // Operand filters
        if (operandInputFilterValues.length > 0) {
            if (!operandInputFilterValues.every(o => instruction.inputs.map(i => i.operandTypeFamily).includes(o)))
                continue;
        }
        if (operandOutputFilterValues.length > 0) {
            if (!operandOutputFilterValues.every(o => instruction.outputs.map(i => i.operandTypeFamily).includes(o)))
                continue;
        }
        if (operandNoInputsFilterValue && instruction.inputs.length > 0)
            continue;
        if (operandNoOutputsFilterValue && instruction.outputs.length > 0)
            continue;

        // Predicate filters
        // Either one of the following must be true for the instruction to show up:
        //   (1) This instruction has no predicates, and the user has ticked "None", and 
        //   (2) This instruction has some predicates, and the user has ticked all of them
        if (instruction.predicates.length == 0) {
            // (1)
            if (!predicateNoneFilterValue)
                continue;
        } else {
            // (2)
            if (!instruction.predicates.every(p => satisfiedPredicates.includes(p.friendly_name)))
                continue;
        }

        // This element has survived the filters!
        // Add to output HTML
        includedResults++;
        htmlString += `
            <div id="result-${instruction.name}"></div>
        `;
        hydrator.add(`result-${instruction.name}`, ResultCard({ instruction, assemblyVariant }));

        if (includedResults == resultLimit) {
            htmlString = `
                <div class="result-card notice">
                    <b>Truncated to ${resultLimit} results</b> - apply some filters.
                </div>
            ` + htmlString;
            break;
        }
    }

    if (includedResults == 0) {
        htmlString = `
            <div class="result-card notice">
                <b>No results</b> - double-check your filters.
            </div>
        ` + htmlString;
    }

    if (anchor) {
        htmlString = `
            <div class="result-card notice">
                <b>Currently showing one specific instruction.</b><br>
                <button onclick="clearAnchor()">Show all instructions</button>
            </div>
        ` + htmlString;
    }

    htmlString += "";

    instructionResults.innerHTML = htmlString;
    hydrator.done();
}

refreshFilters();

// So instruction name links immediately update the page
window.onhashchange = refreshFilters;

// So elements can call `refreshFilters`
window.refreshFilters = refreshFilters;
