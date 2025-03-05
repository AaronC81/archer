class DataManager {
    static hasLoadedInstructions = false;

    static async loadInstructions() {
        // Set by page
        const resp = await fetch(`/target/${globalThis.targetName}/data/instructions.json`);
        if (!resp.ok) {
            throw new Error(`unsuccessful response code: ${resp.status}`)
        }

        this.instructions = await resp.json();
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
            <div class="result-card">
                <div class="header">
                    <code class="assembly-format">${instruction.assemblyVariants[assemblyVariant].html}</code>
                    <a href="#${instruction.name}">${instruction.name}</a>
                </div>
                <table class="result-operand-table">
                    <tr>
                        <th colspan="2">Inputs</th>
                    <tr>
                    ${
                        instruction.inputs
                            .map(i => `
                                <tr>
                                    <td class="label-cell"><mark style="${i.operandTypeFamilyStyle}"><code>${i.name}</code></mark></td>
                                    <td>${i.operandType}</td>
                                </tr>`
                            )
                            .join("")
                    }
                    ${
                        instruction.implicitInputs
                            .map(i => `<tr><td class="label-cell">Implicit</td><td><code>${i}</code></td></tr>`)
                            .join("")
                    }
                    ${ instruction.mayLoad ? "<tr><td></td><td>Loads memory</td></tr>" : "" }

                    <tr>
                        <th colspan="2">Outputs</th>
                    <tr>
                    ${
                        instruction.outputs
                            .map(i => `
                                <tr>
                                    <td class="label-cell"><mark style="${i.operandTypeFamilyStyle}"><code>${i.name}</code></mark></td>
                                    <td>${i.operandType}</td>
                                </tr>`
                            )
                            .join("")
                    }
                    ${
                        instruction.implicitOutputs
                            .map(i => `<tr><td class="label-cell">Implicit</td><td><code>${i}</code></td></tr>`)
                            .join("")
                    }
                    ${ instruction.mayStore ? "<tr><td></td><td>Stores memory</td></tr>" : "" }
                </table>
                <div class="predicate-labels">
                    ${
                        instruction.predicates
                            .map(pred => 
                                pred.important
                                ? `<span><b>${pred.friendly_name}</b></span>`
                                : `<span>${pred.friendly_name}</span>`
                            )
                            .join("")
                    }
                </div>
                ${
                    instruction.documentation
                        ? `<a href="${instruction.documentation.url}" target="_blank" style="display: inline-block; margin-top: 15px;">${ instruction.documentation.text }</a>`
                        : ''
                }
            </div>
        `;

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
}

refreshFilters();

// So instruction name links immediately update the page
window.onhashchange = refreshFilters;
