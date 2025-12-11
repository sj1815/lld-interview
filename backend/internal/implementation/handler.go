package implementation

import (
	"context"

	"connectrpc.com/connect"
	todov1 "github.com/saurabhj/lld-interview/backend/gen/proto/todo/v1"
	repo "github.com/saurabhj/lld-interview/backend/internal/adapter/postgresql/sqlc"
)

// TodoHandler implements the ConnectRPC TodoService
type TodoHandler struct {
	service *TodoService
}

// NewTodoHandler creates a new TodoHandler
func NewTodoHandler(service *TodoService) *TodoHandler {
	return &TodoHandler{
		service: service,
	}
}

// CreateTodo handles the CreateTodo RPC
func (h *TodoHandler) CreateTodo(
	ctx context.Context,
	req *connect.Request[todov1.CreateTodoRequest],
) (*connect.Response[todov1.CreateTodoResponse], error) {
	todo, err := h.service.CreateTodo(ctx, req.Msg.Title, req.Msg.Description)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&todov1.CreateTodoResponse{
		Todo: convertTodoToProto(todo),
	}), nil
}

// GetTodo handles the GetTodo RPC
func (h *TodoHandler) GetTodo(
	ctx context.Context,
	req *connect.Request[todov1.GetTodoRequest],
) (*connect.Response[todov1.GetTodoResponse], error) {
	todo, err := h.service.GetTodo(ctx, req.Msg.Id)
	if err != nil {
		return nil, connect.NewError(connect.CodeNotFound, err)
	}

	return connect.NewResponse(&todov1.GetTodoResponse{
		Todo: convertTodoToProto(todo),
	}), nil
}

// ListTodos handles the ListTodos RPC
func (h *TodoHandler) ListTodos(
	ctx context.Context,
	req *connect.Request[todov1.ListTodosRequest],
) (*connect.Response[todov1.ListTodosResponse], error) {
	pageSize := req.Msg.PageSize
	if pageSize == 0 {
		pageSize = 10
	}

	todos, total, err := h.service.ListTodos(ctx, pageSize, req.Msg.Page)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	protoTodos := make([]*todov1.Todo, len(todos))
	for i, todo := range todos {
		t := todo // Create a copy for pointer safety
		protoTodos[i] = convertTodoToProto(&t)
	}

	return connect.NewResponse(&todov1.ListTodosResponse{
		Todos: protoTodos,
		Total: int32(total),
	}), nil
}

// UpdateTodo handles the UpdateTodo RPC
func (h *TodoHandler) UpdateTodo(
	ctx context.Context,
	req *connect.Request[todov1.UpdateTodoRequest],
) (*connect.Response[todov1.UpdateTodoResponse], error) {
	todo, err := h.service.UpdateTodo(
		ctx,
		req.Msg.Id,
		req.Msg.Title,
		req.Msg.Description,
		req.Msg.Completed,
	)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&todov1.UpdateTodoResponse{
		Todo: convertTodoToProto(todo),
	}), nil
}

// DeleteTodo handles the DeleteTodo RPC
func (h *TodoHandler) DeleteTodo(
	ctx context.Context,
	req *connect.Request[todov1.DeleteTodoRequest],
) (*connect.Response[todov1.DeleteTodoResponse], error) {
	err := h.service.DeleteTodo(ctx, req.Msg.Id)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&todov1.DeleteTodoResponse{
		Success: true,
	}), nil
}

// Helper function to convert sqlc Todo to proto Todo
func convertTodoToProto(todo *repo.Todo) *todov1.Todo {
	description := ""
	if todo.Description.Valid {
		description = todo.Description.String
	}

	completed := false
	if todo.Completed.Valid {
		completed = todo.Completed.Bool
	}

	createdAt := ""
	if todo.CreatedAt.Valid {
		createdAt = todo.CreatedAt.Time.Format("2006-01-02T15:04:05Z")
	}

	updatedAt := ""
	if todo.UpdatedAt.Valid {
		updatedAt = todo.UpdatedAt.Time.Format("2006-01-02T15:04:05Z")
	}

	return &todov1.Todo{
		Id:          todo.ID,
		Title:       todo.Title,
		Description: description,
		Completed:   completed,
		CreatedAt:   createdAt,
		UpdatedAt:   updatedAt,
	}
}
