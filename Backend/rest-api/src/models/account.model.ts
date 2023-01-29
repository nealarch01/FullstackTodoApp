/*
CREATE TABLE account (
	id BIGSERIAL PRIMARY KEY,
	username VARCHAR(32) NOT NULL,
	password VARCHAR(65) NOT NULL,
	email VARCHAR(255) NOT NULL,
	created_at TIMESTAMP NOT NULL DEFAULT NOW()
);
*/

import { Connection, QueryResult, NumberQueryResult, BooleanQueryResult } from '../database/connection';

namespace AccountModel {
	export interface Schema {
		id: number;
		username: string;
		email: string;
		created_at: Date;
	}

	const accountColumns: string = "id::integer AS id, username, email, created_at";

	export interface AccountsQueryResult extends QueryResult {
		data: AccountModel.Schema[] | null;
		err: string | null;
	}

	export interface AccountQueryResult extends QueryResult {
		data: AccountModel.Schema | null;
		err: string | null;
	}

	export async function getAllAccounts(): Promise<AccountsQueryResult> { 
		const queryResult = await Connection.query(`SELECT ${accountColumns} FROM account`);
		if (queryResult.err !== null) {
			console.log("Error in getAllAccounts");
		}
		return queryResult as AccountsQueryResult;
	}

	export async function getAccountById(id: number): Promise<AccountQueryResult> {
		const queryStmt = `SELECT ${accountColumns} FROM ACCOUNT WHERE id = $1`;
		const queryResult = await Connection.query(queryStmt, [id]);
		return queryResult as AccountQueryResult;
	}

	export async function login(userIdentifier: string, password: string): Promise<NumberQueryResult> {
		let queryStmt: string = ""
		if (userIdentifier.includes("@")) {
			queryStmt = `SELECT id FROM ACCOUNT WHERE email = $1 AND password = $2`;
		} else {
			queryStmt = `SELECT id FROM ACCOUNT WHERE username = $1 AND password = $2`;
		}
		const queryResult = await Connection.query(queryStmt, [userIdentifier, password]);
		if (queryResult.err !== null) {
			return {
				data: null,
				err: "Internal error"
			}
		}
		if (queryResult.data.length === 0) {
			return {
				data: null,
				err: null
			}
		}
		const accountID = parseInt(queryResult.data[0].id);
		if (isNaN(accountID)) {
			return {
				data: null,
				err: "Internal error"
			}
		}
		return {
			data: accountID,
			err: null
		}
	}

	export async function register(username: string, email: string, password: string): Promise<NumberQueryResult> {
		const queryStmt = "INSERT INTO account (username, email, password) VALUES ($1, $2, $3) RETURNING id::integer AS id";
		const queryResult = await Connection.query(queryStmt, [username, email, password]);
		if (queryResult.err !== null) {
			console.log("Failed to register. Likely an internal error");
			return {
				data: null,
				err: "Failed to register"
			}
		}
		if (queryResult.data.length === 0) {
			console.log("Could not obtain new account ID. Query returned no data");
			return {
				data: queryResult.data[0].id,
				err: "Failed to register"
			}
		}
		return {
			data: queryResult.data[0].id,
			err: null
		}
	}

	export async function usernameExists(username: string): Promise<BooleanQueryResult> {
		const queryStmt = "SELECT id FROM account WHERE username = $1";
		const queryResult = await Connection.query(queryStmt, [username]);
		if (queryResult.err !== null) {
			console.log("Failed to check if username exists");
			return {
				data: null,
				err: "Failed to check if email exists"
			}
		}
		if (queryResult.data.length === 0) {
			return {
				data: false,
				err: null
			}
		}
		return {
			data: true,
			err: null
		}
	}

	export async function emailExists(email: string): Promise<BooleanQueryResult> {
		const queryStmt = "SELECT id FROM account WHERE email = $1";
		const queryResult = await Connection.query(queryStmt, [email]);
		console.log(queryResult);
		if (queryResult.err !== null) {
			console.log("Failed to check if email exists");
			return {
				data: null,
				err: "Failed to check if email exists"
			}
		}
		if (queryResult.data.length === 0) {
			return {
				data: false,
				err: null
			}
		}
		return {
			data: true,
			err: null
		}
	}

	export async function emailOrUsernameExists(username: string, email: string): Promise<BooleanQueryResult> {
		const queryStmt = "SELECT id FROM account WHERE username = $1 OR email = $2";
		const queryResult = await Connection.query(queryStmt, [username, email]);
		if (queryResult.err !== null) {
			console.log("Failed to check if email or username exists");
			return {
				data: null,
				err: "Failed to check if email or username exists"
			}
		}
		if (queryResult.data.length === 0) {
			return {
				data: false,
				err: null
			}
		}
		return {
			data: true,
			err: null
		}
	}

	export async function deleteAccountById(id: number): Promise<QueryResult> {
		const queryStmt = "DELETE FROM account WHERE id = $1";
		const queryResult = await Connection.query(queryStmt, [id]);
		return queryResult;
	}

	export async function updateAccount(username: string, email: string, password: string, id: number): Promise<QueryResult> {
		const queryStmt = "UPDATE account SET username = $1, email = $2, password = $3 WHERE id = $4";
		const queryResult = await Connection.query(queryStmt, [username, email, password]);
		if (queryResult.err !== null) {
			console.log("Failed to update account");
			return {
				data: null,
				err: "Failed to update account"
			}
		}
		return queryResult;
	}

	export async function updateUsername(username: string, id: number): Promise<QueryResult> {
		const queryStmt = "UPDATE account SET username = $1 WHERE id = $2";
		const queryResult = await Connection.query(queryStmt, [username, id]);
		if (queryResult.err !== null) {
			console.log("Failed to update username");
			return {
				data: null,
				err: "Failed to update username"
			}
		}
		return queryResult;
	}

	export async function updateEmail(email: string, id: number): Promise<QueryResult> {
		const queryStmt = "UPDATE account SET email = $1 WHERE id = $2";
		const queryResult = await Connection.query(queryStmt, [email, id]);
		if (queryResult.err !== null) {
			console.log("Failed to update email");
			return {
				data: null,
				err: "Failed to update email"
			}
		}
		return queryResult;
	}

	export async function updatePassword(password: string, id: number): Promise<QueryResult> {
		const queryStmt = "UPDATE account SET password = $1 WHERE id = $2";
		const queryResult = await Connection.query(queryStmt, [password, id]);
		if (queryResult.err !== null) {
			console.log("Failed to update password.");
			return {
				data: null,
				err: "Failed to update password"
			}
		}
		return queryResult;
	}

}

export { 
	AccountModel
}

