-- PostgreSQL version 15
-- For a todo list full stack app

DROP DATABASE IF EXISTS todo_db;
CREATE DATABASE todo_db;

\c todo_db

CREATE TABLE account (
	id BIGSERIAL PRIMARY KEY,
	username VARCHAR(32) NOT NULL,
	password VARCHAR(65) NOT NULL,
	email VARCHAR(255) NOT NULL,
	created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

INSERT INTO account(username, password, email) VALUES ('nealarch01', 'password', 'nealarch01@mail.com');

CREATE TABLE todo_list (
	id BIGSERIAL PRIMARY KEY,
	creator_id BIGINT NOT NULL REFERENCES account(id),
	name VARCHAR(255) NOT NULL,
	created_at TIMESTAMP NOT NULL DEFAULT NOW(),
	color VARCHAR(7) NOT NULL DEFAULT '#ffffff'
);

INSERT INTO todo_list(creator_id, name, color) VALUES (1, 'Programming', '#ff0000');
INSERT INTO todo_list(creator_id, name, color) VALUES (1, 'School', '#0000ff');

CREATE TABLE todo (
	id BIGSERIAL PRIMARY KEY,
	title VARCHAR(255) NOT NULL,
	creator_id BIGINT NOT NULL REFERENCES account(id),
	description TEXT DEFAULT NULL,
	created_at TIMESTAMP NOT NULL DEFAULT NOW(),
	due_at TIMESTAMP DEFAULT NULL,
	completed BOOLEAN NOT NULL DEFAULT FALSE,
	list_id BIGINT NULL REFERENCES todo_list(id) ON DELETE CASCADE, 
	priority INTEGER NOT NULL DEFAULT 0
);

INSERT INTO todo(title, creator_id, description, due_at, list_id, priority) VALUES ('Learn PostgreSQL', 1, NULL, NULL, 1, 0);
INSERT INTO todo(title, creator_id, description, due_at, list_id, priority) VALUES ('Learn Node.js', 1, NULL, NULL, 1, 0);
INSERT INTO todo(title, creator_id, description, due_at, list_id, priority) VALUES ('Create a web server', 1, NULL, NULL, 1, 0);
INSERT INTO todo(title, creator_id, description, due_at, list_id, priority) VALUES ('Finish essay', 1, NULL, NULL, 2, 0);
INSERT INTO todo(title, creator_id, description, due_at, list_id, priority) VALUES ('Study for exam', 1, NULL, NULL, 2, 0);
INSERT INTO todo(title, creator_id, description, due_at, list_id, priority) VALUES ('Register for Spring 2023 courses', 1, NULL, NULL, 2, 0);
INSERT INTO todo(title, creator_id, description, due_at, list_id, priority, completed) VALUES ('Finish homework', 1, NULL, NULL, 2, 0, TRUE);

CREATE TABLE token_blacklist (
	id BIGSERIAL PRIMARY KEY,
	token VARCHAR(255) NOT NULL,
	created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

