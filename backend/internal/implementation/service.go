package implementation

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
	repo "github.com/saurabhj/lld-interview/backend/internal/adapter/postgresql/sqlc"
)

// TodoService implements the business logic for todos
type TodoService struct {
	queries *repo.Queries
	pool    *pgxpool.Pool
}

// NewTodoService creates a new TodoService
func NewTodoService(pool *pgxpool.Pool) *TodoService {
	return &TodoService{
		queries: repo.New(pool),
		pool:    pool,
	}
}

// CreateTodo creates a new todo
func (s *TodoService) CreateTodo(ctx context.Context, title, description string) (*repo.Todo, error) {
	if title == "" {
		return nil, fmt.Errorf("title cannot be empty")
	}

	todo, err := s.queries.CreateTodo(ctx, repo.CreateTodoParams{
		Title: title,
		Description: pgtype.Text{
			String: description,
			Valid:  description != "",
		},
		Completed: pgtype.Bool{
			Bool:  false,
			Valid: true,
		},
	})
	if err != nil {
		return nil, fmt.Errorf("failed to create todo: %w", err)
	}

	return &todo, nil
}

// GetTodo retrieves a todo by ID
func (s *TodoService) GetTodo(ctx context.Context, id int64) (*repo.Todo, error) {
	todo, err := s.queries.GetTodo(ctx, id)
	if err != nil {
		return nil, fmt.Errorf("failed to get todo: %w", err)
	}

	return &todo, nil
}

// ListTodos retrieves a paginated list of todos
func (s *TodoService) ListTodos(ctx context.Context, pageSize, page int32) ([]repo.Todo, int64, error) {
	if pageSize <= 0 {
		pageSize = 10
	}
	if page < 0 {
		page = 0
	}

	offset := page * pageSize

	todos, err := s.queries.ListTodos(ctx, repo.ListTodosParams{
		Limit:  pageSize,
		Offset: offset,
	})
	if err != nil {
		return nil, 0, fmt.Errorf("failed to list todos: %w", err)
	}

	count, err := s.queries.CountTodos(ctx)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to count todos: %w", err)
	}

	return todos, count, nil
}

// UpdateTodo updates an existing todo
func (s *TodoService) UpdateTodo(ctx context.Context, id int64, title, description string, completed bool) (*repo.Todo, error) {
	if title == "" {
		return nil, fmt.Errorf("title cannot be empty")
	}

	todo, err := s.queries.UpdateTodo(ctx, repo.UpdateTodoParams{
		Title: title,
		Description: pgtype.Text{
			String: description,
			Valid:  description != "",
		},
		Completed: pgtype.Bool{
			Bool:  completed,
			Valid: true,
		},
		ID: id,
	})
	if err != nil {
		return nil, fmt.Errorf("failed to update todo: %w", err)
	}

	return &todo, nil
}

// DeleteTodo deletes a todo by ID
func (s *TodoService) DeleteTodo(ctx context.Context, id int64) error {
	err := s.queries.DeleteTodo(ctx, id)
	if err != nil {
		return fmt.Errorf("failed to delete todo: %w", err)
	}

	return nil
}
