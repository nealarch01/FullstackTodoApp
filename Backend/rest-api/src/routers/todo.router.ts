// Express imports
import { Router } from 'express';

// Controller imports
import { TodoController, TodoListController } from '../controllers/todo.controller';

// Middleware imports
import { AuthMiddleware } from '../middlewares/auth.middleware';

const TodoRouter = Router();

TodoRouter.use(AuthMiddleware.authenticate)

// Todo list
TodoRouter.get("/lists", TodoListController.getUserTodoLists); // Get all todo lists for a user
TodoRouter.post("/list", TodoListController.createTodoList); // Create a new todo list
TodoRouter.put("/list/:id", TodoListController.updateTodoList); // Update a todo list
TodoRouter.delete("/list/:id", TodoListController.deleteTodoList); // Delete a todo list
TodoRouter.get("/list/:id/items", TodoController.getTodosInList); // Get all todos in a list

// Todo item
TodoRouter.get("/item/:id", TodoController.getTodoById); // Get a todo item by id
TodoRouter.get("/items", TodoController.getUserTodos); // Get all todo items for a user
TodoRouter.put("/item/complete/:id", TodoController.updateCompleted); // Update the completed status of a todo item
TodoRouter.put("/item/:id", TodoController.updateTodo); // Update a todo item
TodoRouter.post("/item", TodoController.createTodo); // Create a new todo item
TodoRouter.delete("/item/:id", TodoController.deleteTodoById); // Delete a todo item

export {
	TodoRouter
}


