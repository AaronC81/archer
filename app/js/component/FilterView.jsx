import React, { memo, useEffect, useMemo, useState } from "react";
import FilterControls, { defaultFilters } from "./FilterControls.jsx";
import ResultCard from "./ResultCard.jsx";
import useAnchor from "../hook/useAnchor.ts";
import useTargetData from "../hook/useTargetData.js";

export default function FilterView({ targetName, targetTitle }) {
    // TODO: error handling
    const { instructions, details } = useTargetData(targetName);

    const [assemblyVariant, setAssemblyVariant] = useState(0);

    // Initialise filters to initial values once we have target details to do so
    const [filters, setFilters] = useState(null);
    useEffect(() => {
        if (details) {
            setFilters(defaultFilters(details));
        }
    }, [details]);

    // Anchor can be used to show one specific LLVM instruction
    // If not specified, this is just the empty string
    const [anchor, setAnchor] = useAnchor();

    const resultLimit = 100;
    const isReady = instructions && details && filters;

    const filteredInstructions = useMemo(
        () => {
            if (isReady) {
                let ins = [];
                for (var i = 0; i < instructions.length; i++) {
                    const instruction = instructions[i];
        
                    if (!instruction.matchesFilters(filters, anchor, assemblyVariant))
                        continue;
        
                    ins.push(instruction);
                    if (ins.length >= resultLimit) {
                        break;
                    }
                }

                return ins;
            } else {
                return [];
            }
        },
        [instructions, filters, isReady],
    );
    
    return <>
        <div id="filter-view">
            <div id="static-panel">
                <div id="title-bar" className="already-in-padded-container">
                    <a href="/" id="home-link">
                        <img src="/logo.svg" alt="Archer logo" />
                    </a>

                    <div>
                        <h1>{targetTitle}</h1>
                        <small>
                            <a href="info">Architecture Info</a>
                        </small>
                    </div>

                    {details &&
                        <select id="assembly-variant-selector" value={assemblyVariant} onChange={e => setAssemblyVariant(parseInt(e.target.value))}>
                            {
                                details.assemblyVariants.map((name, i) =>
                                    <option key={i} value={i}>{name}</option>
                                )
                            }
                        </select>
                    }
                </div>
                
                <div id="filter-panel">
                    <div id="inner-filter-panel">
                        {details &&
                            <FilterControls targetDetails={details} onChangeFilters={setFilters} />
                        }
                    </div>
                </div>
            </div>

            <div id="filter-view-divider"></div>

            <div id="filter-results">
                <hr id="filter-results-divider" />
                <div id="instruction-results">
                    {
                        isReady
                        ?
                            <>
                                {filteredInstructions.length == resultLimit &&
                                    <div className="result-card notice">
                                        <b>Truncated to {resultLimit} results</b> - apply some filters.
                                    </div>
                                }
                                {filteredInstructions.length == 0 &&
                                    <div className="result-card notice">
                                        <b>No results</b> - double-check your filters.
                                    </div>
                                }
                                {anchor &&
                                    <div className="result-card notice">
                                        <b>Currently showing one specific instruction.</b><br />
                                        <button onClick={() => setAnchor("")}>Show all instructions</button>
                                    </div>
                                }

                                {
                                    filteredInstructions.map(ins =>
                                        <ResultCard key={ins.name} instruction={ins} assemblyVariant={assemblyVariant} />
                                    )
                                }
                            </>
                        :
                            <div className="result-card" id="instruction-data-loading-indicator">
                                <b>Loading data...</b>
                            </div>
                    }
                </div>
            </div>
        </div>
    </>;
}
