-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS todos (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Create index on completed for filtering
CREATE INDEX idx_todos_completed ON todos(completed);

-- Create index on created_at for sorting
CREATE INDEX idx_todos_created_at ON todos(created_at DESC);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP INDEX IF EXISTS idx_todos_created_at;
DROP INDEX IF EXISTS idx_todos_completed;
DROP TABLE IF EXISTS todos;
-- +goose StatementEnd
