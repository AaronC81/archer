import React from "react";

function ResultCard({ instruction }) {
    return <div>Instruction: {instruction.name}</div>;
}

export default ResultCard;

/*
<div class="result-card">
    <div class="header">
        <code class="assembly-format">${instruction.assemblyVariants[assemblyVariant].html}</code>
        <a href="#${instruction.name}">${instruction.name}</a>
    </div>
    <table class="result-operand-table">

        ${
            instruction.hasAnyInputs()
            ? `
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
            `
            : `
                <tr class="quiet">
                    <th class="quiet" colspan="2">No Inputs</th>
                </tr>
            `
        }
        
        ${
            instruction.hasAnyOutputs()
            ? `
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
            `
            : `
                <tr class="quiet">
                    <th class="quiet" colspan="2">No Outputs</th>
                </tr>
            `
        }
        
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
*/