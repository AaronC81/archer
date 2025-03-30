import React, { useState } from "react";
import { refreshFilters } from "../target_index";
import FilterControls from "./FilterControls.jsx";
import DataManager from "../data/DataManager.js";

export default function FilterView({ targetName, targetTitle }) {
    // TODO: error handling
    const { instructions, details } = DataManager.use();

    // TODO: doesn't trigger redraw yet due to out-of-component instruction updating mayhem
    const [assemblyVariant, setAssemblyVariant] = useState(0);

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
                                    <option value={i}>{name}</option>
                                )
                            }
                        </select>
                    }
                </div>
                
                <div id="filter-panel">
                    <div id="inner-filter-panel">
                        {details &&
                            <FilterControls targetDetails={details} onChangeFilters={window.refreshFilters} />
                        }
                    </div>
                </div>
            </div>

            <div id="filter-view-divider"></div>

            <div id="filter-results">
                <hr id="filter-results-divider" />
                <div id="instruction-results">
                    {/*
                        Magical loading indicator.
                        This will disappear the first time the results are able to refresh.
                        This also has an ID so it can be turned into an error if something goes wrong
                    */}
                    <div className="result-card" id="instruction-data-loading-indicator">
                        <b>Loading data...</b>
                    </div>
                </div>
            </div>
        </div>
    </>;
}
