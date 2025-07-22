# 🌐 API Endpoints Required for Cue App Backend

**Base URL:** `https://your-api-domain.com/api/v1`

---

## 📋 **Required Endpoints (5 total)**

### **1. GET /user**

_Fetch user data and language preference_

**URL:** `GET /api/v1/user`

**Response:**

```json
{
  "preferredLanguage": "en",
  "userId": "user_123"
}
```

---

### **2. GET /prompts**

_Fetch conversation prompts for a specific language_

**URL:** `GET /api/v1/prompts?language=en`

**Query Parameters:**

- `language` (required): `en` or `fr`

**Response:**

```json
[
  {
    "id": 1,
    "main_prompt": "Describe Something You Do That Can Help You Concentrate",
    "followup_1": "What is it?",
    "followup_2": "When do you do it?",
    "followup_3": "How did you learn about it?",
    "followup_4": "How does it help you concentrate?"
  }
]
```

---

### **3. PUT /user/language**

_Update user's language preference_

**URL:** `PUT /api/v1/user/language`

**Request Body:**

```json
{
  "language": "fr"
}
```

**Response:** `200 OK`

---

### **4. GET /user/progress**

_Fetch all user completion progress_

**URL:** `GET /api/v1/user/progress`

**Response:**

```json
[
  {
    "promptId": 1,
    "isCompleted": true,
    "completedAt": "2025-07-22T10:30:00Z"
  },
  {
    "promptId": 3,
    "isCompleted": false,
    "completedAt": null
  }
]
```

---

### **5. PUT /user/progress/{promptId}**

_Update completion status for a specific prompt_

**URL:** `PUT /api/v1/user/progress/1`

**Path Parameters:**

- `promptId`: The ID of the prompt to update

**Request Body:**

```json
{
  "isCompleted": true,
  "completedAt": "2025-07-22T10:30:00Z"
}
```

**Response:** `200 OK`

---

## 🗄️ **PostgreSQL Database Tables**

### **users**

```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) UNIQUE NOT NULL,
    preferred_language VARCHAR(2) DEFAULT 'en',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### **prompts**

```sql
CREATE TABLE prompts (
    id SERIAL PRIMARY KEY,
    language VARCHAR(2) NOT NULL,
    main_prompt TEXT NOT NULL,
    followup_1 TEXT NOT NULL,
    followup_2 TEXT NOT NULL,
    followup_3 TEXT NOT NULL,
    followup_4 TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_prompts_language ON prompts(language);
```

### **user_progress**

```sql
CREATE TABLE user_progress (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) REFERENCES users(user_id),
    prompt_id INTEGER REFERENCES prompts(id),
    is_completed BOOLEAN DEFAULT false,
    completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, prompt_id)
);

CREATE INDEX idx_user_progress_user_id ON user_progress(user_id);
CREATE INDEX idx_user_progress_prompt_id ON user_progress(prompt_id);
```

---

## 🔧 **Implementation Checklist**

- [ ] **GET /user** - Return user data and language preference
- [ ] **GET /prompts?language=en** - Return prompts filtered by language
- [ ] **PUT /user/language** - Update user's preferred language
- [ ] **GET /user/progress** - Return all completion status for user
- [ ] **PUT /user/progress/{promptId}** - Update prompt completion status

---

## 🚀 **When Ready to Deploy**

1. Replace base URL in `cue/cueApp.swift`:

   ```swift
   self.apiService = NetworkManager(baseURL: "https://your-api-domain.com/api/v1")
   ```

2. Test each endpoint with your iOS app

3. The app handles all error cases gracefully and falls back to local storage

**Your iOS app is ready to consume these 5 endpoints immediately!**
