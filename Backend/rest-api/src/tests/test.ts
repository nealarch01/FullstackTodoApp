import { Connection } from "../database/connection";
import { AccountModel } from "../models/account.model";
import { TodoListModel } from "../models/todo-list.model";
import { TodoModel } from "../models/todo.model";
import { JWTManager } from "../auth/jwt";
import { assert } from "console";

async function todoModelTest() {
	let queryResult: any = await TodoModel.getTodosInList(1);
	console.log("Getting all todos in list with id: 1");
	assert(queryResult.err === null, "Error in getTodosInList");
	console.log(queryResult);

	console.log("=======================================");
	console.log("Creating new todo in list");
	// title: string, creatorId: number, description: string | null, dueAt: Date | null, listId: number, priority: number
	queryResult = await TodoModel.createTodo("Test todo", 1, "Test description", null, 1, 1);
	assert(queryResult.err === null, "Error in createTodo");
	const newTodoId = queryResult.data.id;
	console.log(queryResult);
	// console.log(newTodoId);

	console.log("=======================================");
	console.log("Removing new todo id");
	queryResult = await TodoModel.deleteTodo(newTodoId);
	assert(queryResult.err === null, "Error in deleteTodo");
	console.log(queryResult);
}

async function todoListModelTest() {
	console.log("Getting all todo lists for user with id: 1");
	let queryResult: any = await TodoListModel.getUserTodoLists(1);
	assert(queryResult.err === null, "Error in getUserTodoLists");
	console.log(queryResult);

	console.log("=======================================");
	console.log("Checking if user 1 owns todo list 1");
	queryResult = await TodoListModel.userOwnsList(1, 1);
	assert(queryResult.err === null, "Error in userOwnsTodoList");
	console.log(queryResult);
	
	console.log("=======================================");
	console.log("Checking if user 2 owns todo list 2 (should fail)");
	queryResult = await TodoListModel.userOwnsList(2, 1);
	console.log(queryResult);

	console.log("=======================================");
	console.log("Changing title of todo list 1 to: `coding`");
	queryResult = await TodoListModel.updateName(1, "coding");
	assert(queryResult.err === null, "Error in updateName");
	console.log(queryResult);

	console.log("=======================================");
	console.log("Changing color to black for todo list 1");
	queryResult = await TodoListModel.updateColor(1, "#000000");
	assert(queryResult.err === null, "Error in updateColor");
	console.log(queryResult);
}

async function accountModelTests() {
	let queryResult: any = await AccountModel.getAllAccounts();
	console.log("Getting all accounts: ");
	console.log(queryResult);

	console.log("=======================================");
	console.log("Getting account with id: 1");
	queryResult = await AccountModel.getAccountById(1);
	// Assert that err is not null
	assert(queryResult.err === null, "Error in getAccountById");
	console.log(queryResult);

	console.log("=======================================");
	console.log("Getting account id with 9999 (should not exist)");
	queryResult = await AccountModel.getAccountById(9999);
	assert(queryResult.err === null, "Error in getAccountById");
	console.log(queryResult);

	console.log("=======================================");
	console.log("Authenticating with username: test and password: test");
	queryResult = await AccountModel.login("test", "test");
	assert(queryResult.err === null, "Error in login");
	console.log(queryResult);

	console.log("=======================================");
	console.log("Authenticating with username: nealarch01 and password: password");
	queryResult = await AccountModel.login("nealarch01", "password");
	assert(queryResult.err === null, "Error in login");
	console.log(queryResult);

	console.log("=======================================");
	console.log("Authenticating with username: nealarch01 and password: wrongpassword");
	queryResult = await AccountModel.login("nealarch01", "wrongpassword");
	assert(queryResult.err === null, "Error in login");
	console.log(queryResult);

	console.log("=======================================");
	console.log("Checking if username: test exists");
	queryResult = await AccountModel.usernameExists("test");
	assert(queryResult.err === null, "Error in usernameExists");
	console.log(queryResult);

	console.log("=======================================");
	console.log("Checking if username: nealarch01 exists");
	queryResult = await AccountModel.usernameExists("nealarch01");
	assert(queryResult.err === null, "Error in usernameExists")
	console.log(queryResult);

	console.log("=======================================");
	console.log("Checking if email: test exists");
	queryResult = await AccountModel.emailExists("test");
	assert(queryResult.err === null, "Error in emailExists");
	console.log(queryResult);

	console.log("=======================================");
	console.log("Checking if email: nealarch01@mail.com exists");
	queryResult = await AccountModel.emailExists("nealarch01@mail.com");
	assert(queryResult.err === null, "Error in emailExists");
	console.log(queryResult);

	console.log("=======================================");
	console.log("Creating new account with username: test2 and email: test2");
	queryResult = await AccountModel.register("test2", "test2@mail.com", "test2");
	assert(queryResult.err === null, "Error in register");
	let newAccountId = queryResult.data;
	console.log(queryResult);

	console.log("=======================================");
	console.log("Updating username to test3 for account with id: newAccountId");
	queryResult = await AccountModel.updateUsername("test3", newAccountId);
	assert(queryResult.err === null, "Error in updateUsername");
	console.log(queryResult);

	console.log("=======================================");
	console.log("Updating email to test3@mail.com with id: newAccountId");
	queryResult = await AccountModel.updateEmail("test3@mail.com", newAccountId);
	assert(queryResult.err === null, "Error in updateEmail");
	console.log(queryResult);

	console.log("=======================================");
	console.log("Deleting account with id: newAccountId");
	queryResult = await AccountModel.deleteAccountById(newAccountId);
	assert(queryResult.err === null, "Error in deleteAccountById");
	console.log(queryResult);
}

async function main() {
	const connectionStatus = await Connection.init();
	if (!connectionStatus) {
		console.log("Failed to initialize database connection");
		return;
	}
	console.log("\n\n");
	console.log("Running account model tests");
	await accountModelTests();

	console.log("\n\n");
	console.log("Completed account model tests");
	console.log("Running todo list model tests");
	await todoListModelTest();

	console.log("\n\n");
	await todoModelTest();
}


main()
	.then(() => {
		console.log("End of test.");
		process.exit(0);
	});
