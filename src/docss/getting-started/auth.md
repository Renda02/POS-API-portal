---
title: "Authentication & Authorization"
---

Our API utilizes OAuth 2.0 authorization framework for secure authentication and authorization, ensuring that only authorized users can access specific resources and perform actions based on their roles and permissions.

The image below outlines a successful authentication flow
<img src="../../static/images/authentication.svg" alt="Food application flow" style="display: block;
  margin-left: auto;
  margin-right: auto;
  max-width: 750px; width: 100%;"/>

  ## Authentication

Authentication verifies **who you are** by validating your credentials. This process establishes your identity with our system.

### Creating account

Before authenticating, you must first create a user account using the `POST /users` endpoint.

**Request:**
```json
{
  "username": "user@example.com",
  "password": "your_password"
}
```

**Response:**
```json
{
  "id": "674d0bf5c28b69001f8e03a1",
  "created_at": "2024-04-22T10:00:00Z",
  "updated_at": "2024-04-22T10:00:00Z",
  "user_name": "john_doe",
  "email": "johndoe@gmail.com",
  "password": "P@ssw0rd!",
  "role": "manager"
}
```

### Obtaining access tokens

Once your account is created, you can authenticate the user and obtain an access token. This is done by sending a `POST/auth/token` endpoint.

**Request:**
```json
{
  "username": "user@example.com",
  "password": "your_password"
}
```

**Response:**
```json
{
  "auth_id": "674d0bf5c28b69001f8e03a1",
  "created_at": "2024-04-22T10:00:00Z",
  "updated_at": "2024-04-22T10:00:00Z",
  "access_token": "fa0b97b2-445f-41d2-b50f-fb3b014a301e",
  "expires_at": "2024-04-22T10:00:00Z",
  "refresh_token": "d1a3e281-96b6-4f77-a587-7b6c8c2a96d9",
  "token_type": "Bearer",
  "user_name": "john_doe"
}
```

## Authorization

Authorization determines **what you can access** after authentication. It controls permissions to specific resources and actions based on your user role.

### Using access tokens

Include your access token in the `Authorization` header for every API request:

```http
Authorization: Bearer fa0b97b2-445f-41d2-b50f-fb3b014a301e
```

### Token management

- **Access tokens** expire at the time specified in `expires_at`
- **Refresh tokens** can be used to obtain new access tokens without re-authentication

## Error handling

### 401 Unauthorized

This error occurs when authorization fails:

**Common causes:**
- Missing `Authorization` header
- Invalid or expired access token
- Malformed token format

**Resolution:**
1. Verify the `Authorization` header is included
2. Check that your access token is valid and not expired
3. Use your refresh token to obtain a new access token if needed
4. Re-authenticate if your refresh token has also expired

### Example Error Response

```json
{
  "error": "unauthorized",
  "message": "Invalid or expired access token",
  "code": 401
}
```

## Quick start summary

1. **Create account** → `POST /users` (one-time setup)
2. **Authenticate** → `POST /auth/token` (get tokens)
3. **Authorize requests** → Include `Authorization: Bearer <token>` header
4. **Handle expiration** → Use refresh token or re-authenticate as needed
