import { Request, Response, NextFunction } from "express";

import { JWTManager } from "../auth/jwt";


namespace AuthMiddleware {
    export async function authenticate(req: Request, res: Response, next: NextFunction) {
        const token = req.get("Authorization");
        if (token === undefined) {
            res.status(401).send({
                message: "Error 401: Unauthorized"
            });
            return;
        }
        const isValid = await JWTManager.verifyToken(token);
        if (!isValid) {
            res.status(401).send({
                message: "Error 401: Unauthorized. Invalid token provided"
            });
            return;
        }
        next();
    }
}

export {
    AuthMiddleware
}
