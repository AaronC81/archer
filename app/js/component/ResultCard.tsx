import React, { memo } from "react";
import Instruction from "../data/Instruction";

// TODO: uses `STYLE` to get around React's object-based styling. This is rubbish

/**
 * A card describing a specific instruction.
 */
const ResultCard = memo(function ResultCard(
    { instruction, assemblyVariant }: { instruction: Instruction, assemblyVariant: number }
) {
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
                                    <th colSpan={2}>Inputs</th>
                                </tr>
                                {
                                    instruction.input.operands
                                        .map(i =>
                                            <tr key={i.name}>
                                                <td className="label-cell">
                                                    {/* @ts-ignore */}
                                                    <mark STYLE={i.operandTypeFamilyStyle}>
                                                        <code>{i.name}</code>
                                                    </mark>
                                                </td>
                                                <td>{i.operandType}</td>
                                            </tr>
                                        )
                                }
                                {
                                    instruction.input.implicit
                                        .map(i =>
                                            <tr key={i}>
                                                <td className="label-cell">Implicit</td><td><code>{i}</code></td>
                                            </tr>
                                        )
                                }
                                { instruction.input.memory &&
                                    <tr><td></td><td>Loads memory</td></tr>
                                }
                            </>
                        :
                            <tr className="quiet">
                                <th className="quiet" colSpan={2}>No Inputs</th>
                            </tr>
                    }
                    
                    {
                        instruction.hasAnyOutputs()
                        ?
                            <>
                                <tr>
                                    <th colSpan={2}>Outputs</th>
                                </tr>
                                {
                                    instruction.output.operands
                                        .map(i =>
                                            <tr key={i.name}>
                                                <td className="label-cell">
                                                    {/* @ts-ignore */}
                                                    <mark STYLE={i.operandTypeFamilyStyle}>
                                                        <code>{i.name}</code>
                                                    </mark>
                                                </td>
                                                <td>{i.operandType}</td>
                                            </tr>
                                        )
                                }
                                {
                                    instruction.output.implicit
                                        .map(i =>
                                            <tr key={i}>
                                                <td className="label-cell">Implicit</td><td><code>{i}</code></td>
                                            </tr>
                                        )
                                }
                                { instruction.output.memory &&
                                    <tr><td></td><td>Stores memory</td></tr> 
                                }
                            </>
                        :
                            <tr className="quiet">
                                <th className="quiet" colSpan={2}>No Outputs</th>
                            </tr>
                    }
                </tbody>
            </table>
            <div className="predicate-labels">
                {
                    instruction.predicates
                        .map(pred => 
                            <span key={pred.friendly_name}>
                                {
                                    pred.important
                                    ? <b>{pred.friendly_name}</b>
                                    : pred.friendly_name
                                }
                            </span>
                        )
                }
            </div>
            {
                instruction.documentation &&
                    /* @ts-ignore */
                    <a href={instruction.documentation.url} target="_blank" STYLE="display: inline-block; margin-top: 15px;">{ instruction.documentation.text }</a>
            }
        </div>
    );
});

export default ResultCard;
