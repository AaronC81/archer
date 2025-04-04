import React, { useCallback, useEffect, useReducer } from "react";
import TargetDetails from "../data/TargetDetails";
import { defaultFilters, Filters } from "../data/Filters";
import { KeyOfType } from "../utils/typing";

export default function FilterControls(
    { targetDetails, onChangeFilters }: { targetDetails: TargetDetails, onChangeFilters: (_: Filters) => void }
) {
    // Capture some internal state which doesn't need to be made available to our `onChangeFilters`
    // subscriber. (It's still bundled into the same object for convenience of reducing.)
    type InternalFilterState = {
        internalMnemonicString: string,
        internalMnemonicError: string | null,
    }
    type InternalFilters = Filters & InternalFilterState;

    const defaultInternalFilters = useCallback(() => {
        return {
            ...defaultFilters(targetDetails),
            internalMnemonicString: "",
            internalMnemonicError: null,
        }
    }, [targetDetails]);

    type Action
        = { action: "reset" }
        | { action: "set", targets: Partial<Filters> }
        | { action: "setMnemonic", value: string }
        | { action: "invert", target: KeyOfType<Filters, boolean> }
        | { action: "toggle", target: KeyOfType<Filters, Set<string>>, value: string }
        | { action: "selectNoPredicates" }
        | { action: "selectAllPredicates" }

    const [filters, updateFilters] = useReducer<InternalFilters, [Action]>(
        (filters, reduce) => {
            let newFilters: InternalFilters;

            switch (reduce.action) {

            case "reset":
                newFilters = defaultInternalFilters();
                break;

            case "set":
                newFilters = { ...filters, ...reduce.targets }
                break;

            case "setMnemonic":
                newFilters = { ...filters, internalMnemonicString: reduce.value };

                newFilters.internalMnemonicError = null;
                if (reduce.value.charAt(0) == "/") {
                    // It's a regex - try to parse it
                    try {
                        newFilters.mnemonic = new RegExp(newFilters.internalMnemonicString.substring(1));
                    } catch (e) {
                        // The `mnemonic` field remains unchanged, so the filters aren't interrupted
                        newFilters.internalMnemonicError = (e as SyntaxError).message;
                    }
                } else {
                    newFilters.mnemonic = newFilters.internalMnemonicString;
                }

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
        defaultInternalFilters(),
    );

    // Sync state out - can't do that in `useReducer` because that runs during render.
    // If the callback sets state (which ours does!) React isn't happy.
    // `useEffect` runs afterwards instead.
    useEffect(() => {
        onChangeFilters(filters);
    }, [filters, onChangeFilters]);
    
    return <>
        <div id="top-filter-panel">
            <h2>Search</h2>
            <button onClick={() => confirm("Do you really want to reset all of your search filters?") && updateFilters({ action: "reset" })}>Reset</button>
        </div>
        <form method="GET">
            <div>
                <label>
                    <b>Mnemonic:</b>
                    <br />
                    <input name="mnemonic"
                        id="input-mnemonic-filter"
                        placeholder="Start with / to use regex"
                        value={filters.internalMnemonicString}
                        onChange={e => updateFilters({ action: "setMnemonic", value: e.target.value })}
                        className={filters.internalMnemonicError ? "validation-error" : ""} />
                    {filters.internalMnemonicError &&
                        <span className="validation-error">{filters.internalMnemonicError}</span>
                    }
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
