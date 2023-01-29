import { Request } from "express";

namespace FormVerifier {
    // Returns an array of missing keys
    export function findMissingKeys(req: Request, keys: string[]): string[] {
        let form = req.body;
        let missingKeys: string[] = [];
        for (let key of keys) {
            if (form[key] === undefined) {
                missingKeys.push(key);
            }
        }
        return missingKeys;
    }
}

export {
    FormVerifier
}
