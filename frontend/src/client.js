import { createPromiseClient } from '@connectrpc/connect'
import { createConnectTransport } from '@connectrpc/connect-web'
import { TodoService } from './gen/proto/todo/v1/todo_connect'

// Get backend URL from environment or use default
const BACKEND_URL = import.meta.env.VITE_BACKEND_URL || 'http://localhost:8080'

// Create a transport for the client
const transport = createConnectTransport({
  baseUrl: BACKEND_URL,
})

// Create the ConnectRPC client
export const todoClient = createPromiseClient(TodoService, transport)
