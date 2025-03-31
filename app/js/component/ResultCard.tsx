import React, { memo } from "react";
import Instruction, { InstructionParameters } from "../data/Instruction";

// TODO: uses `STYLE` to get around React's object-based styling. This is rubbish

/**
 * A card describing a specific instruction.
 */
const ResultCard = memo(function ResultCard(
    { instruction, assemblyVariant }: { instruction: Instruction, assemblyVariant: number }
) {
    return (
        <div className="result-card instruction-card">
            <div className="header">
                <code className="assembly-format" dangerouslySetInnerHTML={{__html: instruction.assemblyVariants[assemblyVariant].html}}></code>
                <a href={"#" + instruction.name}>{instruction.name}</a>
            </div>
            <table className="result-operand-table">
                <tbody>
                    <OperandTableRows
                        parameters={instruction.input}
                        categoryName="Inputs"
                        memoryName="Loads" />
                    <OperandTableRows
                        parameters={instruction.output}
                        categoryName="Outputs"
                        memoryName="Stores" />
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

const OperandTableRows = memo(function OperandTableRows(
    { parameters, categoryName, memoryName } : { parameters: InstructionParameters, categoryName: string, memoryName: string }
) {
    if (Instruction.hasAnyParameters(parameters)) {
        return (
            <>
                <tr>
                    <th colSpan={2}>{categoryName}</th>
                </tr>
                {
                    parameters.operands
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
                    parameters.implicit
                        .map(i =>
                            <tr key={i}>
                                <td className="label-cell">Implicit</td><td><code>{i}</code></td>
                            </tr>
                        )
                }
                { parameters.memory &&
                    <tr><td></td><td>{memoryName} memory</td></tr> 
                }
            </>
        );
    } else {
        return (
            <tr className="quiet">
                <th className="quiet" colSpan={2}>No {categoryName}</th>
            </tr>
        );
    }
})

export default ResultCard;
