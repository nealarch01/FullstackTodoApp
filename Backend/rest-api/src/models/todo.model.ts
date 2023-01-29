/*
CREATE TABLE todo (
	id BIGSERIAL PRIMARY KEY,
	title VARCHAR(255) NOT NULL,
	creator_id BIGINT NOT NULL REFERENCES account(id),
	description TEXT NOT NULL,
	created_at TIMESTAMP NOT NULL DEFAULT NOW(),
	due_at TIMESTAMP DEFAULT NULL,
	completed BOOLEAN NOT NULL DEFAULT FALSE,
	list_id BIGINT NOT NULL REFERENCES todo_list(id),
	priority INTEGER NOT NULL DEFAULT 0
);
*/

import { BooleanQueryResult, Connection, NumberQueryResult, QueryResult } from "../database/connection";

namespace TodoModel {
    export interface Schema {
        id: number;
        title: string;
        creator_id: number;
        description: string;
        created_at: Date;
        due_at: Date | null;
        completed: boolean;
        list_id: number;
        priority: number;
    }

    export interface TodoQueryResult extends QueryResult {
        data: TodoModel.Schema | null;
        err: string | null;
    }

    export interface TodosQueryResult extends QueryResult {
        data: TodoModel.Schema[] | null;
        err: string | null;
    }


	const todoColumns = `id::integer AS id, title, creator_id::integer AS creator_id, description, created_at, due_at, completed, list_id::integer AS list_id, priority::integer AS priority`;


    export async function getTodosInList(listId: number): Promise<TodosQueryResult> {
        const queryStmt = `
		SELECT ${todoColumns}
            FROM todo
            WHERE list_id = $1
        `;
        const queryResult = await Connection.query(queryStmt, [listId]);
        if (queryResult.err !== null) {
            console.log("Error in getTodoInList");
        }
        return queryResult as TodosQueryResult;
    }

	export async function createTodo(title: string, creatorId: number, description: string | null, dueAt: Date | null, listId: number | null, priority: number): Promise<TodoQueryResult> {
		const queryStmt = `
			INSERT INTO todo (title, creator_id, description, due_at, list_id, priority)
			VALUES ($1, $2, $3, $4, $5, $6)
			RETURNING ${todoColumns}
		`;
		const queryResult = await Connection.query(queryStmt, [title, creatorId, description, dueAt, listId, priority]);
		if (queryResult.err !== null || queryResult.data.length === 0) {
			console.log("Error in createTodo");
			return {
				data: null,
				err: "Failed to get todos in list"
			}
		}
		return {
			data: queryResult.data[0],
			err: null
		}
	}

	export async function getTodoById(todoId: number): Promise<TodoQueryResult> {
		const queryStmt = `
			SELECT ${todoColumns}
			FROM todo
			WHERE id = $1
		`;
		const queryResult = await Connection.query(queryStmt, [todoId])
		if (queryResult.err !== null) {
			console.log("Error in getTodoById");
			return {
				data: null,
				err: "Failed to get todo by id"
			}
		}
		if (queryResult.data.length === 0) { // No error occured, it just does not exist
			return {
				data: null,
				err: null
			}
		}
		return {
			data: queryResult.data[0],
			err: null
		}
	}

	export async function getUserTodos(userId: number): Promise<TodosQueryResult> {
		const queryStmt = `
			SELECT ${todoColumns}
			FROM todo
			WHERE creator_id = $1
		`;
		const queryResult = await Connection.query(queryStmt, [userId]);
		if (queryResult.err !== null) {
			console.log("Error in getUserTodos");
			return {
				data: null,
				err: "Failed to fetch user todos"
			}
		}
		return {
			data: queryResult.data,
			err: null
		}
	}

	export async function deleteTodo(todoId: number): Promise<NumberQueryResult> {
		const queryStmt = `
			DELETE FROM todo
			WHERE id = $1
		`;
		const queryResult = await Connection.query(queryStmt, [todoId]);
		if (queryResult.err !== null) {
			console.log("Error in deleteTodo");
		}
		return {
			data: todoId,
			err: null
		}
	}

	export async function userOwnsItem(userId: number, todoId: number): Promise<BooleanQueryResult> {
		const queryStmt = `
			SELECT COUNT(*)::integer AS count
			FROM todo
			WHERE id = $1 AND creator_id = $2
		`;
		const queryResult = await Connection.query(queryStmt, [todoId, userId]);
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

	export async function update(title: string, description: string, dueAt: Date | null, completed: boolean, listId: number | null, priority: number, todoId: number): Promise<TodoQueryResult> {
		const queryStmt = `
			UPDATE todo
			SET title = $1, description = $2, due_at = $3, completed = $4, list_id = $5, priority = $6
			WHERE id = $7
			RETURNING ${todoColumns}
		`;
		const queryResult = await Connection.query(queryStmt, [title, description, dueAt, completed, listId, priority, todoId]);
		if (queryResult.err !== null) {
			console.log("Error in update");
			return {
				data: null,
				err: "Failed to update todo"
			}
		}
		queryResult.data = queryResult.data[0];	
		return queryResult as TodoQueryResult; // Return the updated todo so the client can update the state
	}

	export async function updateTitle(title: string, todoId: number): Promise<TodoQueryResult> {
		const queryStmt = `
			UPDATE todo
			SET title = $1
			WHERE id = $3
			RETURNING ${todoColumns}
		`;
		const queryResult = await Connection.query(queryStmt, [title, todoId]);
		if (queryResult.err !== null) {
			console.log("Error in updateTitle");
			return {
				data: null,
				err: "Failed to update title"
			}
		}
		return {
			data: queryResult.data[0],
			err: null
		}
	}

	export async function updateDescription(description: string, todoId: number): Promise<TodoQueryResult> {
		const queryStmt = `
			UPDATE todo
			SET description = $1
			WHERE id = $2
			RETURNING ${todoColumns}
		`;
		const queryResult = await Connection.query(queryStmt, [description, todoId]);
		if (queryResult.err !== null) {
			console.log("Error in updateDescription");
			return {
				data: null,
				err: "Failed to update description"
			}
		}
		return {
			data: queryResult.data[0],
			err: null
		}
	}

	export async function updateListID(todoID: number, listId: number | null): Promise<TodoQueryResult> {
		const queryStmt = `
			UPDATE todo
			SET list_id = $1
			WHERE id = $2
			RETURNING ${todoColumns}
		`;
		const queryResult = await Connection.query(queryStmt, [listId, todoID]);
		if (queryResult.err !== null) {
			console.log("Error in updateListID");
			return {
				data: null,
				err: "Failed to update list id"
			}
		}
		return {
			data: queryResult.data[0],
			err: null
		}
	}

	export async function updateCompleted(completed: boolean, todoId: number): Promise<TodoQueryResult> {
		const queryStmt = `
			UPDATE todo
			SET completed = $1
			WHERE id = $2
			RETURNING ${todoColumns}
		`;
		const queryResult = await Connection.query(queryStmt, [completed, todoId]);
		if (queryResult.err !== null) {
			console.log("Error in updateCompleted");
			return {
				data: null,
				err: "Failed to update completed"
			}
		}
		return {
			data: queryResult.data[0],
			err: null
		}
	}

	export async function updateDueDate(dueAt: Date | null, todoId: number): Promise<TodoQueryResult> {
		const queryStmt = `
			UPDATE todo
			SET due_at = $1
			WHERE id = $2
			RETURNING ${todoColumns}
		`;
		const queryResult = await Connection.query(queryStmt, [dueAt, todoId]);
		if (queryResult.err !== null) {
			console.log("Error in updateDueDate");
			return {
				data: null,
				err: "Failed to update due date"
			}
		}
		return {
			data: queryResult.data[0],
			err: null
		}
	}

	export async function updatePriority(priority: number, todoId: number): Promise<TodoQueryResult> {
		const queryStmt = `
			UPDATE todo
			SET priority = $1
			WHERE id = $2
			RETURNING ${todoColumns}
		`;
		const queryResult: any = await Connection.query(queryStmt, [priority, todoId]);
		if (queryResult.err !== null) {
			console.log("Error in updatePriority");
			return {
				data: null,
				err: "Failed to update priority"
			}
		}
		return {
			data: queryResult.data[0],
			err: null
		}
	}
	
}

export {
    TodoModel
}
