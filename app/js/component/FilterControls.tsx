import React, { DetailedHTMLProps, Fragment, InputHTMLAttributes, useCallback, useEffect, useReducer, useRef } from "react";
import TargetDetails, { TargetPredicateFamily } from "../data/TargetDetails";
import { defaultFilters, defaultPredicates, Filters, InternalFilters } from "../data/Filters";
import { KeyOfType } from "../utils/typing";


type Action
  = { action: "reset" }
  | { action: "set", targets: Partial<Filters> }
  | { action: "setMnemonic", value: string }
  | { action: "invert", target: KeyOfType<Filters, boolean> }
  | { action: "addOrRemove", target: KeyOfType<Filters, Set<string>>, values: Iterable<string>, include: boolean }
  | { action: "selectNoPredicates" }
  | { action: "selectAllPredicates" }

function updateFiltersReducer(filters: InternalFilters | null, reduce: Action, targetDetails: TargetDetails | null): InternalFilters | null {
  if (targetDetails == null) {
    console.warn("Invoked reducer without targetDetails loaded yet - ignoring", reduce);
    return filters;
  }

  let newFilters: InternalFilters;

  switch (reduce.action) {

  case "reset":
    newFilters = defaultFilters(targetDetails);
    break;

  case "set":
    newFilters = { ...filters!, ...reduce.targets }
    break;

  case "setMnemonic":
    newFilters = { ...filters!, internalMnemonicString: reduce.value };

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
    newFilters = { ...filters! };
    newFilters[reduce.target] = !filters![reduce.target];
    break;

  case "addOrRemove":
    newFilters = { ...filters! };
    
    let set: Set<string>;
    if (reduce.include) {
      set = new Set([...filters![reduce.target], ...reduce.values]);
    } else {
      set = new Set([...filters![reduce.target]]);
      for (let value of reduce.values) {
        set.delete(value);
      }
    }

    newFilters[reduce.target] = set;
    break;

  case "selectNoPredicates":
    newFilters = {
      ...filters!,
      predicateNone: true,
      predicates: new Set(),
    }
    break;

  case "selectAllPredicates":
    newFilters = {
      ...filters!,
      predicateNone: true,
      predicates: defaultPredicates(targetDetails),
    }
    break;

  default:
    throw new Error(`unknown reduce action: ${reduce}`);

  }

  return newFilters;
}


export function useFilters(targetDetails: TargetDetails | null): [InternalFilters | null, (_: Action) => void] {
  const [filters, updateFilters] = useReducer<InternalFilters | null, [Action]>(
    (f, a) => updateFiltersReducer(f, a, targetDetails),
    null,
  );

  // Reset filters if the target details change (or are loaded for the first time)
  useEffect(() => {
    if (targetDetails != null) {
      updateFilters({ action: "reset" });
    }
  }, [targetDetails]);

  return [filters, updateFilters];
}


export default function FilterControls(
  { filters, updateFilters, targetDetails }: { filters: InternalFilters | null, updateFilters: (_: Action) => void, targetDetails: TargetDetails }
) {
  if (filters == null) {
    return (
      <div id="top-filter-panel">
        <span>Loading...</span>
      </div>
    )
  }
  
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
          {filters.internalMnemonicError
            ? <span className="validation-error">{filters.internalMnemonicError}</span>
            : <span>&nbsp;</span>
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
                    <input className="input-operand-input-filter" type="checkbox" checked={filters.inputFamilies.has(ty.name)} onChange={e => updateFilters({ action: "addOrRemove", target: "inputFamilies", values: [ty.name], include: e.target.checked })} />
                  </td>
                  <td className="checkbox-cell">
                    <input className="input-operand-output-filter" type="checkbox" checked={filters.outputFamilies.has(ty.name)} onChange={e => updateFilters({ action: "addOrRemove", target: "outputFamilies", values: [ty.name], include: e.target.checked })} />
                  </td>
                </tr>
              )
            }
          </tbody>
        </table>
      </div>

      {
        targetDetails.predicateFamilies.map(family => family.predicates.length).reduce((a, b) => a + b, 0) > 0 &&
          <div>
            <br/>
            <b>Capabilities:</b> {/* LLVM calls them "Predicates", but that's a weird name for a user-facing filter */}

            <button type="button" onClick={() => updateFilters({ action: "selectNoPredicates" })}>None</button>
            <button type="button" onClick={() => updateFilters({ action: "selectAllPredicates" })}>All</button>

            <div id="predicate-filter-table">
              <table className="filter-table full-width">
                <tbody>
                  <tr>
                    <td className="checkbox-cell">
                      <input id="input-predicate-none-filter" type="checkbox" checked={filters.predicateNone} onChange={() => updateFilters({ action: "invert", target: "predicateNone" })} />
                    </td>
                    <td className="label-cell">
                      <b><abbr title="Include instructions which require no additional processor capabilities">None</abbr></b>
                    </td>
                  </tr>
                </tbody>
              </table>

              {
                targetDetails.predicateFamilies.map(family =>
                  <PredicateFamilyFilters
                    key={family.family}
                    family={family}
                    filters={filters}
                    updateFilters={updateFilters} />
                )
              }
            </div>
          </div>
      }
    </form>
  </>;
}


function PredicateFamilyFilters(
  { family, filters, updateFilters }: { family: TargetPredicateFamily, filters: InternalFilters, updateFilters: (a: Action) => void }
) {
  const table =
    <table className="filter-table full-width">
      <tbody>
        {
          family.predicates.map(pred =>
            <tr key={pred.friendlyName}>
              <td className="checkbox-cell">
                <input className="input-predicate-filter" type="checkbox" checked={filters.predicates.has(pred.friendlyName)} onChange={e => updateFilters({ action: "addOrRemove", target: "predicates", values: [pred.friendlyName], include: e.target.checked })} />
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
    </table>;

  // Boolean of inclusions:
  //  - If all "true", all selected
  //  - If all "false", all not selected
  //  - If neither, indeterminate
  const inclusionList = family.predicates.map(pred => filters.predicates.has(pred.friendlyName));
  const allSelected = inclusionList.every(x => x);
  const anySelected = inclusionList.some(x => x);

  return (
    <>
      {family.family
        ?
          <details>
            <summary>
              <CheckboxWithIndeterminate
                checked={allSelected}
                indeterminate={!allSelected && anySelected}
                onChange={e => updateFilters({ action: "addOrRemove", target: "predicates", values: family.predicates.map(pred => pred.friendlyName), include: e.target.checked })}
                />
              <b>{family.family}</b>
            </summary>
            {table}
          </details>
        :
          table
      }
    </>
  )
}


function CheckboxWithIndeterminate(
  props: { indeterminate: boolean } & DetailedHTMLProps<InputHTMLAttributes<HTMLInputElement>, HTMLInputElement>
) {
  const inputRef = useRef<HTMLInputElement>(null);
  const { indeterminate, ...propsWithoutIndeterminate } = props;

  useEffect(() => {
    if (inputRef.current) {
      inputRef.current.indeterminate = indeterminate;
    }
  }, [inputRef, indeterminate]);

  return <input ref={inputRef} type="checkbox" {...propsWithoutIndeterminate} />
}
