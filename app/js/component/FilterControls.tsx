import React, { useEffect, useReducer, useRef, useState } from "react";
import TargetDetails from "../data/TargetDetails";
import { defaultFilters, Filters } from "../data/Filters";
import { KeyOfType } from "../utils/typing";

export default function FilterControls(
    { targetDetails, onChangeFilters }: { targetDetails: TargetDetails, onChangeFilters: (_: Filters) => void }
) {
    type Action
        = { action: "set", targets: Partial<Filters> }
        | { action: "invert", target: KeyOfType<Filters, boolean> }
        | { action: "toggle", target: KeyOfType<Filters, Set<string>>, value: string }
        | { action: "selectNoPredicates" }
        | { action: "selectAllPredicates" }

    const [filters, updateFilters] = useReducer<Filters, [Action]>(
        (filters, reduce) => {
            let newFilters: Filters;

            switch (reduce.action) {

            case "set":
                newFilters = { ...filters, ...reduce.targets }
                break;

            case "invert":
                newFilters = { ...filters };
                newFilters[reduce.target] = !filters[reduce.target];
                break;

            case "toggle":
                const set = new Set([...filters[reduce.target]]);
                newFilters = { ...filters };

                // If the item was present, remove it, else add it
                if (set.has(reduce.value)) {
                    set.delete(reduce.value);
                } else {
                    set.add(reduce.value);
                }

                newFilters[reduce.target] = set;
                break;

            case "selectNoPredicates":
                newFilters = {
                    ...filters,
                    predicateNone: true,
                    predicates: new Set(),
                }
                break;

            case "selectAllPredicates":
                newFilters = {
                    ...filters,
                    predicateNone: true,
                    predicates: new Set(targetDetails.predicates.map(pred => pred.friendlyName)),
                }
                break;

            default:
                throw new Error(`unknown reduce action: ${reduce}`);

            }

            return newFilters;
        },
        defaultFilters(targetDetails),
    );

    // Sync state out - can't do that in `useReducer` because that runs during render.
    // If the callback sets state (which ours does!) React isn't happy.
    // `useEffect` runs afterwards instead.
    useEffect(() => {
        onChangeFilters(filters);
    }, [filters, onChangeFilters]);
    
    return <>
        <h2>Search</h2>
        <form method="GET">
            <div>
                <label>
                    <b>Mnemonic:</b>
                    <br />
                    <input name="mnemonic" id="input-mnemonic-filter" value={filters.mnemonic} onChange={e => updateFilters({ action: "set", targets: { mnemonic: e.target.value } })} />
                </label>
            </div>
            <br />

            <div>
                <b>Memory:</b>
                <label>
                    <input name="store" id="input-store-filter" type="checkbox" checked={filters.memoryStore} onChange={() => updateFilters({ action: "invert", target: "memoryStore" })} />
                    Store
                </label>
                <label>
                    <input name="load" id="input-load-filter" type="checkbox" checked={filters.memoryLoad} onChange={() => updateFilters({ action: "invert", target: "memoryLoad" })} />
                    Load
                </label>
            </div>

            <div>
                <br />
                <b>Operands:</b>
                <table id="operand-filter-table" className="filter-table">
                    <tbody>
                        <tr>
                            <td></td>
                            <td className="checkbox-cell"><b>Input</b></td>
                            <td className="checkbox-cell"><b>Output</b></td>
                        </tr>

                        <tr>
                            <td className="label-cell align-end">
                                <i>
                                    <abbr title="Filter to instructions which do not have any input/output operands">None</abbr>
                                </i>
                            </td>
                            <td className="checkbox-cell">
                                <input id="input-operand-input-none-filter" type="checkbox" checked={filters.inputNone} onChange={() => updateFilters({ action: "invert", target: "inputNone" })} />
                            </td>
                            <td className="checkbox-cell">
                                <input id="input-operand-output-none-filter" type="checkbox" checked={filters.outputNone} onChange={() => updateFilters({ action: "invert", target: "outputNone" })} />
                            </td>
                        </tr>

                        {
                            targetDetails.operandTypeFamilies.map(ty =>
                                <tr key={ty.name}>
                                    <td className="label-cell align-end">
                                        {/* @ts-ignore */}
                                        <mark STYLE={ty.style}>
                                            {ty.name}
                                        </mark>
                                    </td>
                                    <td className="checkbox-cell">
                                        <input className="input-operand-input-filter" type="checkbox" checked={filters.inputFamilies.has(ty.name)} onChange={() => updateFilters({ action: "toggle", target: "inputFamilies", value: ty.name })} />
                                    </td>
                                    <td className="checkbox-cell">
                                        <input className="input-operand-output-filter" type="checkbox" checked={filters.outputFamilies.has(ty.name)} onChange={() => updateFilters({ action: "toggle", target: "outputFamilies", value: ty.name })} />
                                    </td>
                                </tr>
                            )
                        }
                    </tbody>
                </table>
            </div>

            {
                targetDetails.predicates.length > 0 &&
                    <div>
                        <br/>
                        <b>Capabilities:</b> {/* LLVM calls them "Predicates", but that's a weird name for a user-facing filter */}

                        <button type="button" onClick={() => updateFilters({ action: "selectNoPredicates" })}>None</button>
                        <button type="button" onClick={() => updateFilters({ action: "selectAllPredicates" })}>All</button>

                        <table id="predicate-filter-table" className="filter-table">
                            <tbody>
                                <tr>
                                    <td className="checkbox-cell">
                                        <input id="input-predicate-none-filter" type="checkbox" checked={filters.predicateNone} onChange={() => updateFilters({ action: "invert", target: "predicateNone" })} />
                                    </td>
                                    <td className="label-cell">
                                        <b><abbr title="Include instructions which require no additional processor capabilities">None</abbr></b>
                                    </td>
                                </tr>

                                {
                                    targetDetails.predicates.map(pred =>
                                        <tr key={pred.friendlyName}>
                                            <td className="checkbox-cell">
                                                <input className="input-predicate-filter" type="checkbox" checked={filters.predicates.has(pred.friendlyName)} onChange={() => updateFilters({ action: "toggle", target: "predicates", value: pred.friendlyName })} />
                                            </td>
                                            <td className="label-cell">
                                                {
                                                    pred.important
                                                    ? <b>{pred.friendlyName}</b>
                                                    : <span>{pred.friendlyName}</span>
                                                }
                                            </td>
                                        </tr>
                                    )
                                }
                            </tbody>
                        </table>
                    </div>
            }
        </form>
    </>;
}
