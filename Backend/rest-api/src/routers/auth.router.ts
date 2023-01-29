import { Router } from 'express';

import { AuthController } from '../controllers/auth.controller';
import { AuthMiddleware } from '../middlewares/auth.middleware';

const AuthRouter = Router();

AuthRouter.post('/login', AuthController.login);
AuthRouter.post("/register", AuthController.register);
AuthRouter.post('/refresh', AuthMiddleware.authenticate, AuthController.refresh);
AuthRouter.post("/token/verify", AuthMiddleware.authenticate, AuthController.verifyToken);

export {
    AuthRouter
}
