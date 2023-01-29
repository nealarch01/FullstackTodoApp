/*
CREATE TABLE todo_list (
	id BIGSERIAL PRIMARY KEY,
	creator_id BIGINT NOT NULL REFERENCES account(id),
	name VARCHAR(255) NOT NULL,
	created_at TIMESTAMP NOT NULL DEFAULT NOW(),
);
*/

import { Connection, NumberQueryResult, QueryResult, BooleanQueryResult } from "../database/connection";

namespace TodoListModel {
    export interface Schema {
        id: number;
        creator_id: number;
        name: string;
		color: string;
        created_at: Date;
    }

    export interface TodoListQueryResult extends QueryResult {
        data: TodoListModel.Schema | null;
        err: string | null;
    }

    export interface TodoListsQueryResult extends QueryResult {
        data: TodoListModel.Schema[] | null;
        err: string | null;
    }

	const todoListFields = `id::integer AS id, creator_id::integer AS creator_id, name, created_at, color`;

    export async function getUserTodoLists(userId: number): Promise<TodoListsQueryResult> {
        const queryStmt = `
            SELECt ${todoListFields}
            FROM todo_list
            WHERE creator_id = $1
        `;
        const queryResult = await Connection.query(queryStmt, [userId]);
        if (queryResult.err !== null) {
            console.log("Error in getUserTodoLists");
        }
        return queryResult as TodoListsQueryResult;
    }

    export async function createTodoList(userId: number, name: string, color: string | null = null): Promise<TodoListQueryResult> {
		let queryStmt: string = ""
        queryStmt = `
            INSERT INTO todo_list (creator_id, name)
            VALUES ($1, $2)
            RETURNING ${todoListFields}
        `;
		let fields = [userId, name];
		if (color !== null) {
			queryStmt = `
				INSERT INTO todo_list (creator_id, name, color)
				VALUES ($1, $2, $3)
				RETURNING ${todoListFields}
			`;
			fields.push(color);
		}
        const queryResult = await Connection.query(queryStmt, fields);
        if (queryResult.err !== null) {
            console.log("Error in createTodoList");
			return {
				data: null,
				err: queryResult.err
			}
        }
		return {
			data: queryResult.data[0],
			err: null
		}	
    }

	export async function deleteTodoList(listId: number): Promise<NumberQueryResult> {
		const queryStmt = `
			DELETE FROM todo_list
			WHERE id = $1
			RETURNING id::integer as id
		`;
		const queryResult = await Connection.query(queryStmt, [listId]);
		if (queryResult.err !== null) {
			console.log("Error in deleteTodoList");
		}
		return {
			data: listId,
			err: null
		}
	}

	export async function update(listId: number, name: string, color: string): Promise<TodoListQueryResult> {
		const queryStmt = `
			UPDATE todo_list
			SET name = $1, color = $2
			WHERE id = $3
			RETURNING ${todoListFields}
		`;
		const queryResult = await Connection.query(queryStmt, [name, color, listId]);
		if (queryResult.err !== null || queryResult.data.length === 0) {
			return {
				data: null,
				err: "Error in update"
			}
		}
		return {
			data: queryResult.data[0],
			err: null
		}
	}

	export async function updateName(listId: number, name: string): Promise<TodoListModel.TodoListQueryResult> {
		const queryStmt = `
			UPDATE todo_list
			SET name = $1
			WHERE id = $2
			RETURNING ${todoListFields}
		`;
		const queryResult = await Connection.query(queryStmt, [name, listId]);
		if (queryResult.err !== null || queryResult.data.length === 0) {
			console.log("Error in updateName");
			return {
				data: null,
				err: "Error in updateName"
			}
		}
		return {
			data: queryResult.data[0],
			err: null
		}
	}

	export async function updateColor(listId: number, color: string): Promise<TodoListModel.TodoListQueryResult> {
		const queryStmt = `
			UPDATE todo_list
			SET color = $1
			WHERE id = $2
			RETURNING ${todoListFields}
		`;
		const queryResult = await Connection.query(queryStmt, [color, listId]);
		if (queryResult.err !== null || queryResult.data.length === 0) {
			return {
				data: null,
				err: "Error in updateColor"
			}
		}
		return {
			data: queryResult.data[0],
			err: null
		}
	}

	export async function userOwnsList(userId: number, listId: number): Promise<BooleanQueryResult> {
		const queryStmt = `
			SELECT COUNT(*)::integer AS count
			FROM todo_list
			WHERE id = $1 AND creator_id = $2
		`;
		const queryResult = await Connection.query(queryStmt, [listId, userId]);
		if (queryResult.err !== null) {
			console.log("Error in userOwnsList");
			return {
				data: false,
				err: queryResult.err
			};
		}
		let count = queryResult.data[0].count;
		if (count === 0) {
			return {
				data: false,
				err: null
			};
		}
		return {
			data: true,
			err: null
		}
	}

}

export {
    TodoListModel
}
