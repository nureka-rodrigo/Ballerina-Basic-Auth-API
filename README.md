# Ballerina JWT Authentication API

This repository contains a RESTful API built with Ballerina that demonstrates JWT-based authentication and authorization. The API manages a collection of music albums with different access levels based on user roles.

## Features

- JWT-based authentication and authorization
- Role-based access control (Admin and User roles)
- CRUD operations for album management
- Secure API endpoints with scope validation

## Prerequisites

- Ballerina (Swan Lake Update 12)
- Basic understanding of REST APIs and JWT authentication

## Project Structure

- `main.bal`: Contains the API implementation
- `resources/`: Contains certificate files for JWT signing/validation
  - `private.key`: Private key for signing JWT tokens
  - `public.crt`: Public certificate for validating JWT tokens

## API Endpoints

| Method | Path | Description | Required Role |
|--------|------|-------------|--------------|
| POST | /login | Authenticate and get JWT token | None (Public) |
| GET | /albums | Get all albums | Admin or User |
| GET | /albums/{id} | Get album by ID | Admin or User |
| POST | /albums | Create a new album | Admin only |
| PUT | /albums/{id} | Update an existing album | Admin only |
| DELETE | /albums/{id} | Delete an album | Admin only |

## Authentication Flow

1. **Login**: Send username and password to `/login` endpoint
2. **Get Token**: Receive JWT token in response
3. **Access Protected Resources**: Include token in Authorization header for subsequent requests

## Sample Usage

### 1. Login and get token

```bash
curl -X POST http://localhost:8080/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin"}'
```

Response:
```json
{
  "success": true,
  "message": "Login successful",
  "payload": {
    "token": "eyJhbGciOiJSUzI1NiIsICJ0eXAiOiJKV1QifQ..."
  }
}
```

### 2. Access protected resources with token

```bash
curl -X GET http://localhost:8080/albums \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIsICJ0eXAiOiJKV1QifQ..."
```

## Running the Project

1. Clone the repository
2. Navigate to the project directory
3. Start the Ballerina service:

```bash
bal run
```

The service will start on port 8080 (configurable in the code).

## User Credentials

Two predefined users are available for testing:

- Admin user: 
  - Username: `admin`
  - Password: `admin`
  - Role: `admin`
  - Access: All endpoints

- Regular user:
  - Username: `user`
  - Password: `user`
  - Role: `user`
  - Access: Read-only operations

## License

This project is licensed under the terms of the [Apache-2.0 license](https://github.com/nureka-rodrigo/Ballerina-Basic-Auth-API/blob/main/LICENSE).