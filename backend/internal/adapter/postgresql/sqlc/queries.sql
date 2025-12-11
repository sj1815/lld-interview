-- name: CreateTodo :one
INSERT INTO todos (title, description, completed)
VALUES ($1, $2, $3)
RETURNING *;

-- name: GetTodo :one
SELECT * FROM todos
WHERE id = $1;

-- name: ListTodos :many
SELECT * FROM todos
ORDER BY created_at DESC
LIMIT $1 OFFSET $2;

-- name: CountTodos :one
SELECT COUNT(*) FROM todos;

-- name: UpdateTodo :one
UPDATE todos
SET title = $1,
    description = $2,
    completed = $3,
    updated_at = NOW()
WHERE id = $4
RETURNING *;

-- name: DeleteTodo :exec
DELETE FROM todos
WHERE id = $1;
