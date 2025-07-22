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

_Fetch user completion progress for a specific language_

**URL:** `GET /api/v1/user/progress?language=en`

**Query Parameters:**

- `language` (required): `en` or `fr`

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

**Note:** Progress is tracked separately per language. Completing prompt #1 in English doesn't affect prompt #1 in French.

---

### **5. PUT /user/progress/{promptId}**

_Update completion status for a specific prompt in a specific language_

**URL:** `PUT /api/v1/user/progress/1?language=en`

**Path Parameters:**

- `promptId`: The ID of the prompt to update

**Query Parameters:**

- `language` (required): `en` or `fr`

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
    language VARCHAR(2) NOT NULL,
    is_completed BOOLEAN DEFAULT false,
    completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, prompt_id, language)
);

CREATE INDEX idx_user_progress_user_id ON user_progress(user_id);
CREATE INDEX idx_user_progress_language ON user_progress(language);
CREATE INDEX idx_user_progress_user_lang ON user_progress(user_id, language);
```

**Important:** The `user_progress` table includes a `language` column and unique constraint on `(user_id, prompt_id, language)` to track completion separately for each language.

---

## 🔧 **Implementation Checklist**

- [ ] **GET /user** - Return user data and language preference
- [ ] **GET /prompts?language=en** - Return prompts filtered by language
- [ ] **PUT /user/language** - Update user's preferred language
- [ ] **GET /user/progress?language=en** - Return completion status for specific language
- [ ] **PUT /user/progress/{promptId}?language=en** - Update prompt completion for specific language

---

## 🚀 **When Ready to Deploy**

1. Replace base URL in `cue/cueApp.swift`:

   ```swift
   self.apiService = NetworkManager(baseURL: "https://your-api-domain.com/api/v1")
   ```

2. Test each endpoint with your iOS app

3. The app handles all error cases gracefully and falls back to local storage

**Your iOS app now tracks completion separately for English and French prompts! 🇺🇸🇫🇷**
