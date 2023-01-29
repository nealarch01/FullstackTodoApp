import express from "express";
import process from "process";

import { Connection } from "./database/connection";

// Routers
import { AuthRouter } from "./routers/auth.router";
import { TodoRouter } from "./routers/todo.router";

import config from "./configs/config.json";

const app = express();

app.use(express.urlencoded({ // Parse URL-encoded bodies
	extended: true
}));

// Create a function that logs incoming requests
app.use((req: express.Request, res: express.Response, next: express.NextFunction) => {
	console.log(`${req.method} ${req.path}`);
	next();
});

app.get("/", (req: express.Request, res: express.Response) => {
	res.type("application/json");
	res.status(200).send({
		"message": "Server is up and running"
	});
});

Connection.init()
	.then((status: boolean) => {
		if (!status) {
			console.log("Failed to initialize database connection");
			console.log("Exiting with status code 1");
			process.exit(1);
		}
	});

app.use("/auth", AuthRouter);
app.use("/todo", TodoRouter);

app.listen(config.port, () => {
	console.log(`Server is running on port ${config.port}`);
});
