<template>
  <div>
    <h1>📝 Todo App</h1>
    
    <div class="tabs">
      <button 
        :class="['tab-button', { active: activeTab === 'create' }]"
        @click="activeTab = 'create'"
      >
        Create Todo
      </button>
      <button 
        :class="['tab-button', { active: activeTab === 'get' }]"
        @click="activeTab = 'get'"
      >
        Get Todo
      </button>
    </div>

    <div class="container">
      <!-- Create Todo Tab -->
      <div v-if="activeTab === 'create'" class="tab-content">
        <h2>Create a New Todo</h2>
        <div class="form-group">
          <label for="title">Title:</label>
          <input 
            id="title"
            v-model="createForm.title" 
            type="text" 
            placeholder="Enter todo title"
            class="input-field"
          />
        </div>
        <div class="form-group">
          <label for="description">Description:</label>
          <textarea 
            id="description"
            v-model="createForm.description" 
            placeholder="Enter todo description"
            class="input-field textarea-field"
            rows="4"
          ></textarea>
        </div>
        <button @click="handleCreateTodo" class="action-button">
          Create Todo
        </button>
        <div v-if="createResponse" class="response-box">
          <h3>Response:</h3>
          <pre>{{ JSON.stringify(createResponse, null, 2) }}</pre>
        </div>
        <div v-if="createError" class="error-box">
          <strong>Error:</strong> {{ createError }}
        </div>
      </div>

      <!-- Get Todo Tab -->
      <div v-if="activeTab === 'get'" class="tab-content">
        <h2>Get Todo by ID</h2>
        <div class="form-group">
          <label for="todoId">Todo ID:</label>
          <input 
            id="todoId"
            v-model.number="getTodoId" 
            type="number" 
            placeholder="Enter todo ID"
            class="input-field"
          />
        </div>
        <button @click="handleGetTodo" class="action-button">
          Get Todo
        </button>
        <div v-if="getResponse" class="response-box">
          <h3>Response:</h3>
          <pre>{{ JSON.stringify(getResponse, null, 2) }}</pre>
        </div>
        <div v-if="getError" class="error-box">
          <strong>Error:</strong> {{ getError }}
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue'
import { todoClient } from './client'

export default {
  name: 'App',
  setup() {
    // Active tab state
    const activeTab = ref('create')

    // Create Todo form state
    const createForm = ref({
      title: '',
      description: ''
    })
    const createResponse = ref(null)
    const createError = ref(null)

    // Get Todo form state
    const getTodoId = ref(null)
    const getResponse = ref(null)
    const getError = ref(null)

    // Create Todo handler
    const handleCreateTodo = async () => {
      try {
        createError.value = null
        createResponse.value = null

        if (!createForm.value.title.trim()) {
          createError.value = 'Title is required'
          return
        }

        const response = await todoClient.createTodo({
          title: createForm.value.title,
          description: createForm.value.description
        })

        createResponse.value = response
        
        // Clear form on success
        createForm.value.title = ''
        createForm.value.description = ''
      } catch (error) {
        createError.value = error.message || 'Failed to create todo'
        console.error('Create todo error:', error)
      }
    }

    // Get Todo handler
    const handleGetTodo = async () => {
      try {
        getError.value = null
        getResponse.value = null

        if (!getTodoId.value || getTodoId.value <= 0) {
          getError.value = 'Please enter a valid todo ID'
          return
        }

        const response = await todoClient.getTodo({
          id: getTodoId.value
        })

        getResponse.value = response
      } catch (error) {
        getError.value = error.message || 'Failed to get todo'
        console.error('Get todo error:', error)
      }
    }

    return {
      activeTab,
      createForm,
      createResponse,
      createError,
      getTodoId,
      getResponse,
      getError,
      handleCreateTodo,
      handleGetTodo
    }
  },
}
</script>
