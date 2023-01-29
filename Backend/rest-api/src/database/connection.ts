import { PoolClient, Pool } from 'pg';
import Config from "../configs/config.json"

class Connection {
	private static pool: Pool | null = null;

	public static async acquire(): Promise<PoolClient | null> {
		if (this.pool === null) {
			console.log("Pool is not initialized. Cannot acquire client");
			return null;
		}
		return await this.pool!.connect();
	}

	public static async query(queryStmt: string, params?: any[]): Promise<QueryResult> {
		try {
			const queryResult = await this.pool!.query(queryStmt, params);
			return {
				data: queryResult.rows,
				err: null
			}
		} catch (err) {
			console.log(err);
			console.log("Query error in connection");
			console.log("An error occured while executing the query");
			return {
				data: null,
				err: "An error occured executing the query"
			}
		}
	}

	// Initializes the pool
	public static async init(): Promise<boolean> {
		if (this.pool !== null) {
			return false;
		}
		this.pool = new Pool(Config.database);
		if (!this.pool) {
			console.log("Failed to connect to database");
			return false;
		}
		// Test the connection
		try {
			await this.pool.query("SELECT NOW()");
			return true;
		} catch (err) {
			console.log("An error occured while testing the connection");
			console.log(err);
			return false;
		}
	}
}

interface QueryResult {
	data: any;
	err: string | null;
}


// QueryResult with primitive return types
interface NumberQueryResult extends QueryResult {
	data: number | null;
	err: string | null;
}

interface StringQueryResult extends QueryResult {
	data: string | null;
	err: string | null;
}

interface BooleanQueryResult extends QueryResult {
	data: boolean | null;
	err: string | null;
}

interface DateQueryResult extends QueryResult {
	data: Date | null;
	err: string | null;
}

export {
	Connection,
	QueryResult,
	NumberQueryResult,
	StringQueryResult,
	BooleanQueryResult,
	DateQueryResult
}
