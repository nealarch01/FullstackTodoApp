import jwt from "jsonwebtoken";

import { Connection } from "../database/connection";

import Config from "../configs/config.json";

namespace JWTManager {
    export interface Payload {
        id: number;
    }
    
    export function createToken(payload: Payload): string {
        return jwt.sign(payload, Config.signingKey, { expiresIn: "12d" });
    }
    
    export async function verifyToken(tokenString: string): Promise<boolean> {
        try {
            jwt.verify(tokenString, Config.signingKey); // Throws an error if the token is invalid
            // The token is valid, but we need to check if it is in the blacklist
            const queryResult = await Connection.query("SELECT id FROM token_blacklist WHERE token = $1", [tokenString]);
            if (queryResult.err !== null) {
                console.log("Failed to lookup JWT");
                return false;
            }
            if (queryResult.data.length > 0) {
                return false;
            }
            return true;
        } catch (err) {
            return false;
        }
    }

	export function decodeToken(tokenString: string): Payload | null {
		try {
			const decoded = jwt.decode(tokenString) as Payload;
			return decoded;
		} catch (err) {
			return null;
		}
	}

    export async function blacklistToken(tokenString: string): Promise<boolean> {
        const queryResult = await Connection.query("INSERT INTO token_blacklist (token) VALUES ($1)", [tokenString]);
        if (queryResult.err !== null) {
            console.log("Failed to blacklist token")
            return false;
        }
        return true;
    }

}

export {
    JWTManager
}
