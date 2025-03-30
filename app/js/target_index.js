import ResultCard from "./component/ResultCard.jsx";
import DataManager from "./data/DataManager.js";
import ReactHydrator from "./util/ReactHydrator.js";

// Ask to load instructions and details
// These functions is async, but we don't await it - it'll just happen in the background
Promise.all([DataManager.loadDetails(), DataManager.loadInstructions()])
    .then(() => {} /* refreshFilters() */) // TODO: initial refresh as soon as we have data
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

const resultLimit = 500;

function clearAnchor() {
    window.location.hash = "";
    refreshFilters();
}

export function refreshFilters(filters) {
    // If data hasn't loaded, don't show anything for now
    if (!DataManager.hasLoadedInstructions && !DataManager.hasLoadedDetails)
        return;

    // TODO: race between React rendering the filters, and these elements existing
    // (This will be solved when everything's React-y)

    const {
        mnemonic,
        memoryStore, memoryLoad,
        inputNone, inputFamilies,
        outputNone, outputFamilies,
        predicateNone, predicates,
    } = filters;

    const instructionResults = document.getElementById("instruction-results");
    const assemblyVariantSelector = document.getElementById("assembly-variant-selector");

    // Anchor can be used to show one specific LLVM instruction
    // If not specified, this is just the empty string
    const anchor = window.location.hash.substring(1);

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
        if (memoryStore && !instruction.mayStore)
            continue;
        if (memoryLoad && !instruction.mayLoad)
            continue;

        // Textual filter
        if (mnemonic && !instruction.assemblyVariants[assemblyVariant].mnemonic.includes(mnemonic))
            continue;

        // Operand filters
        if (inputFamilies.size > 0) {
            if (![...inputFamilies].every(o => instruction.inputs.map(i => i.operandTypeFamily).includes(o)))
                continue;
        }
        if (outputFamilies.size > 0) {
            if (![...outputFamilies].every(o => instruction.outputs.map(i => i.operandTypeFamily).includes(o)))
                continue;
        }
        if (inputNone && instruction.inputs.length > 0)
            continue;
        if (outputNone && instruction.outputs.length > 0)
            continue;

        // Predicate filters
        // Either one of the following must be true for the instruction to show up:
        //   (1) This instruction has no predicates, and the user has ticked "None", and 
        //   (2) This instruction has some predicates, and the user has ticked all of them
        if (instruction.predicates.length == 0) {
            // (1)
            if (!predicateNone)
                continue;
        } else {
            // (2)
            if (!instruction.predicates.every(p => predicates.has(p.friendly_name)))
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

// So elements can call these
window.refreshFilters = refreshFilters;
