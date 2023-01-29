import { Request, Response } from "express";

// Model imports
import { TodoModel } from "../models/todo.model";
import { TodoListModel } from "../models/todo-list.model";

// Auth imports
import { JWTManager } from "../auth/jwt";

// Util imports
import { FormVerifier } from "../utils/form-verifier";
import { RegexVerifier } from "../utils/regex-verifier";

namespace TodoController {
	// Gets all the todo items in the list
	export async function getTodosInList(req: Request, res: Response) {
		res.type("application/json");
		const token = req.headers.authorization!;
		const userId = JWTManager.decodeToken(token)!.id;
		let listId = parseInt(req.params.id as string);
		if (isNaN(listId)) {
			res.status(400).send({
				message: "Error 400: Invalid list id"
			});
			return;
		}
		const userOwnsList = await TodoListModel.userOwnsList(userId, listId)
		if (userOwnsList.err !== null) {
			res.status(500).send({
				message: "Error 500: Internal server error"
			})
			return;
		}
		if (!userOwnsList.data) {
			res.status(403).send({
				message: "Error 403: You do not have permission to access this resource"
			});
			return;
		}
		const queryResult = await TodoModel.getTodosInList(listId);
		if (queryResult.err !== null) {
			res.status(500).send({
				message: "Error 500: Internal server error"
			});
			return;
		}
		res.status(200).send({
			todo_items: queryResult.data
		});
	}

	export async function getTodoById(req: Request, res: Response) {
		res.type("application/json");
		const token = req.headers.authorization!;
		const userId = JWTManager.decodeToken(token)!.id;
		let todoId = parseInt(req.params.id as string);
		if (isNaN(todoId)) {
			res.status(400).send({
				message: "Error 400: Invalid list id"
			});
			return;		
		}
		const queryResult = await TodoModel.getTodoById(todoId);
		if (queryResult.err !== null) {
			res.status(500).send({
				message: "Error 500: Internal server error"
			});
			return;
		}
		if (queryResult.data === null) {
			res.status(404).send({
				message: "Error 404: Todo item not found"
			});
			return;
		}
		if (queryResult.data.creator_id !== userId) {
			res.status(403).send({
				message: "Error 403: You do not have permission to view this resource"
			});
			return
		}
		return res.status(200).send({
			todo_item: queryResult.data
		});
	}

	export async function getUserTodos(req: Request, res: Response) {
		res.type("application/json");
		// Check if in the query string, only include completed todos
		const token = req.headers.authorization!;
		const userId = JWTManager.decodeToken(token)!.id;
		const queryResult = await TodoModel.getUserTodos(userId);
		if (queryResult.err !== null) {
			res.status(500).send({
				message: "Error 500: Internal server error"
			});
			return;
		}
		const onlyIncludeCompleted = req.query.completed_only === "true"; // Looks like: ?completed=true
		if (onlyIncludeCompleted) {
			const filteredTodos = queryResult.data!.filter(todo => todo.completed);
			return res.status(200).send({
				todo_items: filteredTodos
			});
		}
		return res.status(200).send({
			todo_items: queryResult.data
		});
	}

	export async function createTodo(req: Request, res: Response) {
		res.type("application/json");
		const contentType = req.headers["content-type"];
		if (contentType !== "application/x-www-form-urlencoded") {
			res.status(400).send({
				message: "Error 400: Invalid content type"
			});
			return;
		}
		const token = req.headers.authorization!;
		const userId = JWTManager.decodeToken(token)!.id;
		// listID is an optional parameter
		let listId = req.body.list_id ?? "";
		if (listId === "" || listId === "null" || listId === null) {
			listId = null;
		} else {
			listId = parseInt(listId);
			if (isNaN(listId)) {
				res.status(400).send({
					message: "Error 400: Invalid list id"
				});
				return;
			}
			const userOwnsList = await TodoListModel.userOwnsList(userId, listId);
			if (userOwnsList.err !== null) {
				res.status(500).send({
					message: "Error 500: Internal server error"
				});
				return;
			}
			if (!userOwnsList.data) {
				res.status(403).send({
					message: "Error 403: You do not have permission to access this resource"
				});
				return;
			}
		}
		const title = req.body.title;
		let missingKeys = FormVerifier.findMissingKeys(req, ["title"]);
		if (missingKeys.length > 0) {
			res.status(400).send({
				message: `Error 400: Missing keys: ${missingKeys.join(", ")}`
			});
			return;
		}
		if (title === "") { // Empty title case provided (invalid)
			res.status(400).send({
				message: "Error 400: Title cannot be empty"
			});
		}
		// Null coalescing operator to null if undefined
		const description = req.body.description ?? null;
		const due_at = req.body.due_at ?? null;
		const priority = parseInt(req.body.priority ?? 0);
		if (isNaN(priority)) {
			res.status(400).send({
				message: "Error 400: Invalid priority provided"
			});
			return;
		}
		const createResult = await TodoModel.createTodo(title, userId, description, due_at, listId, priority);
		if (createResult.err !== null || createResult.data === null) {
			res.status(500).send({
				message: "Error 500: Internal server error"
			});
			return;
		}
		return res.status(201).send({
			todo_item: createResult.data
		});
	}

	export async function updateCompleted(req: Request, res: Response) {
		res.type("application/json");
		const token = req.headers.authorization!;
		const userId = JWTManager.decodeToken(token)!.id;
		let todoId = parseInt(req.params.id as string);
		if (isNaN(todoId)) {
			res.status(400).send({
				message: "Error 400: Invalid list id"
			});
			return;		
		}
		const queryResult = await TodoModel.getTodoById(todoId);
		if (queryResult.err !== null) {
			res.status(500).send({
				message: "Error 500: Internal server error"
			});
			return;
		}
		if (queryResult.data!.creator_id !== userId) {
			res.status(403).send({
				message: "Error 403: You do not have permission to view/modify this resource"
			});
			return;
		}
		let completedStatus = queryResult.data!.completed
		const updateResult = await TodoModel.updateCompleted(!completedStatus, todoId);
		if (updateResult.err !== null) {
			res.status(500).send({
				message: "Error 500: Internal server error"
			});
			return;
		}
		return res.status(200).send({
			message: "Todo item updated successfully",
			todo_item: updateResult.data
		});
	}

	export async function updateTodo(req: Request, res: Response) {
		res.type("application/json");
		const token = req.headers.authorization!;
		const userId = JWTManager.decodeToken(token)!.id;
		let todoId = parseInt(req.params.id as string);
		if (isNaN(todoId)) {
			res.status(400).send({
				message: "Error 400: Invalid list id"
			});
			return;		
		}
		const missingFields = FormVerifier.findMissingKeys(req, ["title", "description", "priority", "list_id", "completed"]);
		if (missingFields.length > 0) {
			res.status(400).send({
				message: `Error 400: Missing keys: ${missingFields.join(", ")}`
			});
			return;
		}
		let listId = req.body.list_id ?? "";
		if (listId === "" || listId === "null" || listId === null) {
			listId = null;	
		} else {
			listId = parseInt(listId);
			if (isNaN(listId)) {
				res.status(400).send({
					message: "Error 400: Invalid list id"
				});
				return;
			}
			let userOwnsList = await TodoListModel.userOwnsList(userId, listId);
			if (userOwnsList.err !== null || userOwnsList.data === null) {
				res.status(500).send({
					message: "Error 500: Internal server error"
				});
				return;
			}
			if (userOwnsList.data === false) {
				res.status(403).send({
					message: "Error 403: You do not have permission to access this resource"
				});
				return;
			}
		}
		// Return not implemented for now
		const userOwnsTodo = await TodoModel.userOwnsItem(userId, todoId);
		if (userOwnsTodo.err !== null || userOwnsTodo.data === null) {
			res.status(500).send({
				message: "Error 500: Internal server error"
			});
			return;
		}
		if (userOwnsTodo.data === false) {
			res.status(403).send({
				message: "Error 403: You do not have permission to access this resource"
			});
			return;
		}
		if (req.body.title === "") {
			res.status(400).send({
				message: "Error 400: Title cannot be empty"
			});
			return;
		}
		if (req.body.completed !== "false" && req.body.completed !== "true") {
			res.status(400).send({
				message: "Error 400: Invalid completed status"
			});
			return;
		}
		const updateResult = await TodoModel.update(
			req.body.title, 
			req.body.description, 
			null, 
			<boolean>req.body.completed,
			listId,
			req.body.priority,
			todoId
		);
		if (updateResult.err !== null || updateResult.data === null) {
			res.status(500).send({
				message: "Error 500: Internal server error"
			});
			return;
		}
		return res.status(200).send({
			message: "Todo item updated successfully",
			todo_item: updateResult.data
		});
	}

	export async function deleteTodoById(req: Request, res: Response) {
		res.type("application/json");
		const token = req.headers.authorization!;
		const userId = JWTManager.decodeToken(token)!.id;
		let todoId = parseInt(req.params.id as string);
		if (isNaN(todoId)) {
			res.status(400).send({
				message: "Error 400: Invalid list id"
			});
			return;		
		}
		const queryResult = await TodoModel.getTodoById(todoId);
		if (queryResult.err !== null) {
			res.status(500).send({
				message: "Error 500: Internal server error"
			});
			return;
		}
		if (queryResult.data!.creator_id !== userId) {
			res.status(403).send({
				message: "Error 403: You do not have permission to view/modify this resource"
			});
			return;
		}
		const deleteResult = await TodoModel.deleteTodo(todoId);
		if (deleteResult.err !== null) {
			res.status(500).send({
				message: "Error 500: Internal server error"
			});
			return;
		}
		return res.status(200).send({
			message: "Todo item deleted successfully"
		});
	}

}






namespace TodoListController {
	export async function getUserTodoLists(req: Request, res: Response) {
		res.type("application/json");
		const token = req.headers.authorization; // Token has already been verified at middleware
		const tokenData = JWTManager.decodeToken(token!);
		const userID = tokenData!.id;

		const queryResult = await TodoListModel.getUserTodoLists(userID);
		if (queryResult.err !== null) {
			res.status(500).send({
				message: "Error 500: Internal Server Error",
			});
		}
		res.status(200).send({
			todo_lists: queryResult.data
		});
	}

	export async function createTodoList(req: Request, res: Response) {
		res.type("application/json");
		// Check if application/x-www-form-urlencoded
		const contentType = req.get("Content-Type") ?? "";
		if (contentType !== "application/x-www-form-urlencoded") {
			res.status(400).send({
				message: "Invalid content type"
			});
			return;
		}
		const token = req.headers.authorization; // Token has already been verified at middleware
		const tokenData = JWTManager.decodeToken(token!);
		const userID = tokenData!.id;
		if (req.body === undefined) {
			res.status(400).send({
				message: "Error 400: Invalid request body"
			});
			return;
		}
		// Verify form data
		const missingFields = FormVerifier.findMissingKeys(req, ["name"]);
		if (missingFields.length > 0) {
			res.status(400).send({
				message: `Error 400: Missing fields: ${missingFields.join(", ")}`
			});
			return;
		}
		const color = req.body.color ?? null;
		if (color !== null) {
			const colorIsValid = RegexVerifier.hexColor(color);
			if (!colorIsValid) {
				res.status(400).send({
					message: "Error 400: Invalid color"
				});
				return;
			}
		}
		const queryResult = await TodoListModel.createTodoList(userID, req.body.name, color);
		if (queryResult.err !== null) {
			res.status(500).send({
				message: "Error 500: Internal Server Error"
			});
			return;
		}
		return res.status(201).send({
			message: "Todo list created successfully",
			todo_list: queryResult.data
		});
	}

	export async function updateTodoList(req: Request, res: Response) {
		res.type("application/json");
		// Check if application/x-www-form-urlencoded
		const contentType = req.get("Content-Type") ?? "";
		if (contentType !== "application/x-www-form-urlencoded") {
			res.status(400).send({
				message: "Invalid content type"
			});
			return;
		}
		const token = req.headers.authorization; // Token has already been verified at middleware
		const tokenData = JWTManager.decodeToken(token!);
		const userID = tokenData!.id;
		let list_id = parseInt(req.params.id as string);
		if (isNaN(list_id)) {
			res.status(400).send({
				message: "Invalid list id"
			});
			return;
		}
		if (!await TodoListModel.userOwnsList(userID, list_id)) {
			res.status(403).send({
				message: "You do not have permission to update this list"
			});
		}
		// Verify form data
		const newName = req.body.name;
		let newColor = req.body.color;
		if (newName === undefined && newColor === undefined) {
			// 304 Not Modified
			res.status(304).send({
				message: "No changes made"
			});
			return;
		}
		newColor = newColor.toLowerCase();
		if (newName !== undefined && newColor !== undefined) {
			if (!RegexVerifier.hexColor(newColor)) {
				res.status(400).send({
					message: "Invalid color"
				});
				return;
			}
			const queryResult = await TodoListModel.update(list_id, newName, newColor);
			if (queryResult.err !== null) {
				res.status(500).send({
					message: "Error 500: Internal Server Error"
				});
				return;
			}
			res.status(200).send({
				message: "Todo list name and color updated successfully",
				todo_list: queryResult.data
			});
			return;
		}
		if (newName !== undefined) {
			updateName(req, res);
			return;
		}
		if (newColor !== undefined) {
			updateColor(req, res);
			return;
		}
	}

	async function updateName(req: Request, res: Response) {
		let newName = req.body.name; // We already known this exists
		let list_id = parseInt(req.params.id as string); // We've also verified that this is a number
		let queryResult = await TodoListModel.updateName(list_id, newName);
		if (queryResult.err) {
			res.status(500).send({
				message: "Error 500: Internal Server Error"
			});
			return;
		}
		res.status(200).send({
			message: "Todo list name updated successfully",
		});
	}

	async function updateColor(req: Request, res: Response) {
		let newColor = req.body.color; // We already known this exists
		let list_id = parseInt(req.params.id as string); // We've also verified that this is a number
		if (!RegexVerifier.hexColor(newColor)) {
			res.status(400).send({
				message: "Invalid color"
			});
			return;	
		}
		let queryResult = await TodoListModel.updateColor(list_id, newColor);
		if (queryResult.err) {
			res.status(500).send({
				message: "Error 500: Internal Server Error"
			});
			return;
		}
		res.status(200).send({
			message: "Todo list color updated successfully",
		});
	}

	export async function deleteTodoList(req: Request, res: Response) {
		res.type("application/json");
		const token = req.headers.authorization; // Token has already been verified at middleware
		const tokenData = JWTManager.decodeToken(token!);
		const userID = tokenData!.id;
		let list_id = parseInt(req.params.id as string);
		if (isNaN(list_id)) {
			res.status(400).send({
				message: "Invalid list id"
			});
			return;
		}
		const userOwnsList = await TodoListModel.userOwnsList(userID, list_id);
		if (userOwnsList.err !== null) {
			res.status(500).send({
				message: "Error 500: Internal Server Error"
			});
			return;
		}
		if (!userOwnsList.data) {
			res.status(403).send({
				message: "You do not have permission to delete this list"
			});
			return;
		}
		// For this function, we must set all todos in the list to be unassigned (list_id = null)
		const itemsInList = await TodoModel.getTodosInList(list_id);
		if (itemsInList.err !== null) {
			res.status(500).send({
				message: "Error 500: Internal Server Error"
			});
			return;
		}
		for (let i = 0; i < itemsInList.data!.length; i++) {
			const item = itemsInList.data![i];
			const queryResult = await TodoModel.updateListID(item.id, null);
			if (queryResult.err !== null) {
				res.status(500).send({
					message: "Error 500: Internal Server Error"
				});
				return;
			}
		}
		const queryResult = await TodoListModel.deleteTodoList(list_id);
		if (queryResult.err !== null) {
			res.status(500).send({
				message: "Error 500: Internal Server Error"
			});
			return;
		}
		return res.status(200).send({
			message: "Todo list deleted successfully"
		});
	}

}

export {
	TodoController,
	TodoListController
}

