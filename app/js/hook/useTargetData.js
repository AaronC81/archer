import { useEffect, useState } from "react";
import TargetDetails from "../data/TargetDetails.js";
import Instruction from "../data/Instruction.js";

/**
 * Hook to fetch information about a target from the server:
 *   - List of instructions
 *   - Details about the target
 * 
 * Both start as `null` and will be populated when data is received (not necessarily at the same time).
 */
export default function useTargetData(targetName) {
    const [instructions, setInstructions] = useState(null);
    useEffect(() => {
        fetchJson(targetName, "instructions")
            .then(instructions => setInstructions(instructions.map(ins => new Instruction(ins))))
    }, [targetName]);

    const [details, setDetails] = useState(null);
    useEffect(() => {
        fetchJson(targetName, "details")
            .then(details => setDetails(new TargetDetails(details)))
    }, [targetName]);

    return { instructions, details };
}

async function fetchJson(targetName, file) {
    const resp = await fetch(`/target/${targetName}/data/${file}.json`);
    if (!resp.ok) {
        throw new Error(`unsuccessful response code: ${resp.status}`)
    }

    return resp.json();
}
