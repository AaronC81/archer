import React from "react";
import FilterView from "./component/FilterView.jsx";
import ResultCard from "./component/ResultCard.jsx";
import DataManager from "./data/DataManager.js";
import ReactHydrator from "./util/ReactHydrator.js";

const resultLimit = 500;

function clearAnchor() {
    window.location.hash = "";
    refreshFilters();
}

export function refreshFilters(filters) {
    // If data hasn't loaded, don't show anything for now
    if (!DataManager.hasLoadedInstructions && !DataManager.hasLoadedDetails)
        return;

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

        if (!instruction.matchesFilters(filters, anchor, assemblyVariant))
            continue;

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

const topLevelHydrator = new ReactHydrator();
topLevelHydrator.add("content", <FilterView targetName={globalThis.targetName} targetTitle={globalThis.targetTitle} />);
topLevelHydrator.done();
