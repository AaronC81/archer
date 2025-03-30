import { useEffect, useState } from "react";
import TargetDetails from "../data/TargetDetails";
import Instruction from "../data/Instruction";

/**
 * Hook to fetch information about a target from the server:
 *   - List of instructions
 *   - Details about the target
 * 
 * Both start as `null` and will be populated when data is received (not necessarily at the same time).
 */
export default function useTargetData(targetName: string) {
    const [instructions, setInstructions] = useState<Instruction[] | null>(null);
    useEffect(() => {
        fetchJson(targetName, "instructions")
            .then(instructions => setInstructions(instructions.map((ins: any) => new Instruction(ins))))
    }, [targetName]);

    const [details, setDetails] = useState<TargetDetails | null>(null);
    useEffect(() => {
        fetchJson(targetName, "details")
            .then(details => setDetails(new TargetDetails(details)))
    }, [targetName]);

    return { instructions, details };
}

async function fetchJson(targetName: string, file: string): Promise<any> {
    const resp = await fetch(`/target/${targetName}/data/${file}.json`);
    if (!resp.ok) {
        throw new Error(`unsuccessful response code: ${resp.status}`)
    }

    return resp.json();
}
