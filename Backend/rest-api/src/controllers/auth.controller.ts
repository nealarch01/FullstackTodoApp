import { Request, Response } from "express";

import { AccountModel } from '../models/account.model';
import { FormVerifier } from "../utils/form-verifier";
import { JWTManager } from "../auth/jwt";
import { RegexVerifier } from "../utils/regex-verifier";

namespace AuthController {
	export async function login(req: Request, res: Response) {
		res.type("application/json");
		const contentType = req.get("Content-Type") ?? "";
		if (contentType !== "application/x-www-form-urlencoded") {
			res.status(400).send({
				message: "Invalid content type"
			});
			return;
		}
		const userIdentifier = req.body.user_identifier;
		const password = req.body.password;
		// Check if some of the properties are undefined and return a list of missing body parameters
		const missingKeys = FormVerifier.findMissingKeys(req, ["user_identifier", "password"]);
		if (missingKeys.length > 0) {
			res.status(400).send({
				message: "Missing fields: " + missingKeys.join(", ")
			});
			return;
		}
		const queryResult = await AccountModel.login(userIdentifier.toLowerCase(), password);
		if (queryResult.err !== null) {
			console.log(queryResult.err);
			res.status(500).send({
				message: "Error 500: An internal server error occurred."
			});
			return;
		}
		if (queryResult.data === null) {
			res.status(401).send({
				message: "Error 401: Invalid credentials"
			});
			return;
		}
		let accountID = queryResult.data;
		let token = JWTManager.createToken({
			id: accountID!
		});
		res.status(200).send({
			token: token
		});
	}

	export async function register(req: Request, res: Response) {
		res.type("application/json");
		if (req.get("Content-Type") !== "application/x-www-form-urlencoded") {
			res.status(400).send({
				message: "Error 400: Invalid content type. Expected x-www-form-urlencoded"
			});
			return;
		}
		const missingKeys = FormVerifier.findMissingKeys(req, ["username", "password", "email"]);
		if (missingKeys.length > 0) {
			res.status(400).send({
				message: `Error 400: Missing body parameters: ${missingKeys.join(", ")}`
			});
			return;	
		}
		// Properties should not be missing at this point
		// Do input validation checks
		let invalidFields = verifyRegisterFields(req.body.username, req.body.password, req.body.email);
		if (invalidFields.length > 0) {
			res.status(400).send({
				message: "Error 400: Invalid fields",
				invalid_fields: JSON.parse(JSON.stringify(invalidFields))
			});
			return;
		}
		// Lastly, check if user name or email is taken
		const usernameExists = await AccountModel.usernameExists(req.body.username);
		const emailExists = await AccountModel.emailExists(req.body.email);
		if (usernameExists.data === null || emailExists === null) {
			res.status(500).send({
				message: "Error 500: AN internal server error occured."
			});
		}
		if (usernameExists.data) {
			res.status(409).send({
				message: "Error 400: Username already taken"
			});
			return;
		}
		if (emailExists.data) {
			res.status(409).send({
				message: "Error 400: Email already taken"
			});
			return;
		}
		const queryResult = await AccountModel.register(req.body.username, req.body.email, req.body.password);
		if (queryResult.err !== null || queryResult.data === null) {
			res.status(500).send({
				message: "Error 500: An internal server error occurred."
			});
			return;
		}
		// Create a token
		let token = JWTManager.createToken({
			id: queryResult.data
		});
		res.status(201).send({
			token: token,
			message: "Successfully registered"
		});
	}

	export async function refresh(req: Request, res: Response) {
		res.type("application/json");
		let token = req.get("Authorization") ?? "";
		res.status(200).send({
			token: "token"
		});
	}

	export async function verifyToken(req: Request, res: Response) { 
		// The middleware will check if the token is valid
		// So in this function, we just need to return a 200 status code
		res.type("application/json");
		res.status(200).send({
			message: "Token is valid"
		});
	}

	export async function logout(req: Request, res: Response) {
		const token = req.get("Authorization") ?? ""; // If the token is undefined, set it to an empty string
		res.type("application/json");
		res.status(200).send({
			message: "Successfully logged out"
		});
	}


	// Utility Functions

	function verifyUsername(username: string): boolean {
		if (username.length < 3) {
			return false;
		}
		return RegexVerifier.username(username);
	}

	function verifyPassword(password: string): boolean {
		if (password.length < 8) {
			return false;
		}
		return RegexVerifier.password(password);
	}

	function verifyEmail(email: string): boolean {
		return RegexVerifier.email(email);
	}

	function verifyRegisterFields(username: string, password: string, email: string): string[] {
		let invalidFields: string[] = [];
		if (!verifyUsername(username)) {
			const usernameCriteria = `Username must have at least 6 characters containing letters, numbers, underscores, periods, and dashes.` +
			 					`Underscores, periods, and dashes cannot be in succession or at the beginning or end of the username.`;
			invalidFields.push(usernameCriteria);
		}
		if (!verifyPassword(password)) {
			const passwordCriteria = `Password must have at least 8 characters. ` + 
				`Contain at least one lowercase and uppercase letter. ` +
				`Contain at least one number ` +
				`and one special character (e.g. !@#$%^&*)`;
			invalidFields.push(passwordCriteria);
		}
		if (!verifyEmail(email)) {
			const emailCriteria = `This email address is invalid to our system.`;
			invalidFields.push(emailCriteria);
		}
		return invalidFields
	}

}

export {
	AuthController
}
