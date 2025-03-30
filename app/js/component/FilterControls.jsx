import React from "react";

export default function FilterControls({ targetDetails }) {
    // TODO: could use `useReducer` to atomically apply changes to filters

    return <>
        <h2>Search</h2>
        <form method="GET">
            <div>
                <label>
                    <b>Mnemonic:</b>
                    <br />
                    <input name="mnemonic" id="input-mnemonic-filter" onInput={window.refreshFilters} onChange={window.refreshFilters} />
                </label>
            </div>
            <br />

            <div>
                <b>Memory:</b>
                <label>
                    <input name="store" id="input-store-filter" type="checkbox" onChange={window.refreshFilters} />
                    Store
                </label>
                <label>
                    <input name="load" id="input-load-filter" type="checkbox" onChange={window.refreshFilters} />
                    Load
                </label>
            </div>

            <div>
                <br />
                <b>Operands:</b>
                <table className="filter-table">
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
                            <input id="input-operand-input-none-filter" type="checkbox" onChange={window.refreshFilters} />
                        </td>
                        <td className="checkbox-cell">
                            <input id="input-operand-output-none-filter" type="checkbox" onChange={window.refreshFilters} />
                        </td>
                    </tr>

                    {
                        targetDetails.operandTypeFamilies.map(ty =>
                            <tr>
                                <td className="label-cell align-end">
                                    <mark STYLE={ty.style}>
                                        {ty.name}
                                    </mark>
                                </td>
                                <td className="checkbox-cell">
                                    <input className="input-operand-input-filter" data-operand-name={ty.name} type="checkbox" onChange={window.refreshFilters} />
                                </td>
                                <td className="checkbox-cell">
                                    <input className="input-operand-output-filter" data-operand-name={ty.name} type="checkbox" onChange={window.refreshFilters} />
                                </td>
                            </tr>
                        )
                    }
                </table>
            </div>

            {
                targetDetails.predicates.length > 0
                ?
                    <div>
                        <br/>
                        <b>Capabilities:</b> {/* LLVM calls them "Predicates", but that's a weird name for a user-facing filter */}

                        <button type="button" onClick={window.selectNoPredicates}>None</button>
                        <button type="button" onClick={window.selectAllPredicates}>All</button>

                        <table className="filter-table">
                            <tr>
                                <td className="checkbox-cell">
                                    <input id="input-predicate-none-filter" type="checkbox" onChange={window.refreshFilters} defaultChecked />
                                </td>
                                <td className="label-cell">
                                    <b><abbr title="Include instructions which require no additional processor capabilities">None</abbr></b>
                                </td>
                            </tr>

                            {
                                targetDetails.predicates.map(pred =>
                                    <tr>
                                        <td className="checkbox-cell">
                                            <input className="input-predicate-filter" data-predicate-name={pred.friendlyName} type="checkbox" onChange={window.refreshFilters} defaultChecked />
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
                        </table>
                    </div>
                :
                    /* JS expects to find this element */
                    <input STYLE="display: none;" id="input-predicate-none-filter" type="checkbox" onChange={window.refreshFilters} defaultChecked />
            }
        </form>
    </>;
}
