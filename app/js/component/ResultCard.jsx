import React from "react";

// TODO: uses `STYLE` to get around React's object-based styling. This is rubbish
// TODO: need `key` in some places - see console warnings

/**
 * A card describing a specific instruction.
 */
function ResultCard({ instruction, assemblyVariant }) {
    return (
        <div className="result-card">
            <div className="header">
                <code className="assembly-format" dangerouslySetInnerHTML={{__html: instruction.assemblyVariants[assemblyVariant].html}}></code>
                <a href={"#" + instruction.name}>{instruction.name}</a>
            </div>
            <table className="result-operand-table">
                <tbody>
                    {
                        instruction.hasAnyInputs()
                        ? 
                            <>
                                <tr>
                                    <th colSpan="2">Inputs</th>
                                </tr>
                                {
                                    instruction.inputs
                                        .map(i =>
                                            <tr>
                                                <td className="label-cell"><mark STYLE={i.operandTypeFamilyStyle}><code>{i.name}</code></mark></td>
                                                <td>{i.operandType}</td>
                                            </tr>
                                        )
                                }
                                {
                                    instruction.implicitInputs
                                        .map(i => <tr><td className="label-cell">Implicit</td><td><code>{i}</code></td></tr>)
                                }
                                { instruction.mayLoad &&
                                    <tr><td></td><td>Loads memory</td></tr>
                                }
                            </>
                        :
                            <tr className="quiet">
                                <th className="quiet" colSpan="2">No Inputs</th>
                            </tr>
                    }
                    
                    {
                        instruction.hasAnyOutputs()
                        ?
                            <>
                                <tr>
                                    <th colSpan="2">Outputs</th>
                                </tr>
                                {
                                    instruction.outputs
                                        .map(i =>
                                            <tr>
                                                <td className="label-cell"><mark STYLE={i.operandTypeFamilyStyle}><code>{i.name}</code></mark></td>
                                                <td>{i.operandType}</td>
                                            </tr>
                                        )
                                }
                                {
                                    instruction.implicitOutputs
                                        .map(i => <tr><td className="label-cell">Implicit</td><td><code>{i}</code></td></tr>)
                                }
                                { instruction.mayStore &&
                                    <tr><td></td><td>Stores memory</td></tr> 
                                }
                            </>
                        :
                            <tr className="quiet">
                                <th className="quiet" colSpan="2">No Outputs</th>
                            </tr>
                    }
                </tbody>
            </table>
            <div className="predicate-labels">
                {
                    instruction.predicates
                        .map(pred => 
                            pred.important
                            ? <span><b>{pred.friendly_name}</b></span>
                            : <span>{pred.friendly_name}</span>
                        )
                }
            </div>
            {
                instruction.documentation &&
                    <a href={instruction.documentation.url} target="_blank" STYLE="display: inline-block; margin-top: 15px;">{ instruction.documentation.text }</a>
            }
        </div>
    );
}

export default ResultCard;
