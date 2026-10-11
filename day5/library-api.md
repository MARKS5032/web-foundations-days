# Library Books REST API Design

## Overview

This API manages books in a library. The resource is called `books`, and the base URL is `/api/books`.

## Endpoints

### 1. List all books

- **Method:** `GET`
- **Path:** `/api/books`
- **Description:** Retrieves a list of all books in the library.
- **Example request body:** None.
- **Success status:** `200 OK`

### 2. Get one book

- **Method:** `GET`
- **Path:** `/api/books/42`
- **Description:** Retrieves the book with ID 42.
- **Example request body:** None.
- **Success status:** `200 OK`

### 3. Create a book

- **Method:** `POST`
- **Path:** `/api/books`
- **Description:** Adds a new book to the library.
- **Example request body:**

```json
{
  "title": "Things Fall Apart",
  "author": "Chinua Achebe",
  "year": 1958
}
```

- **Success status:** `201 Created`

### 4. Update a book

- **Method:** `PUT`
- **Path:** `/api/books/42`
- **Description:** Replaces the details of the book with ID 42.
- **Example request body:**

```json
{
  "title": "Things Fall Apart",
  "author": "Chinua Achebe",
  "year": 1958
}
```

- **Success status:** `200 OK`

### 5. Delete a book

- **Method:** `DELETE`
- **Path:** `/api/books/42`
- **Description:** Deletes the book with ID 42.
- **Example request body:** None.
- **Success status:** `204 No Content`

### 6. List books by author

- **Method:** `GET`
- **Path:** `/api/books?author=Chinua%20Achebe`
- **Description:** Retrieves books written by the specified author using a query parameter.
- **Example request body:** None.
- **Success status:** `200 OK`

## Error responses

### 400 Bad Request

- **Meaning:** The request contains invalid data.
- **Example:** A client tries to create a book without a required title or supplies an invalid year.

### 404 Not Found

- **Meaning:** The requested resource does not exist.
- **Example:** A client requests `/api/books/9999`, but no book has ID 9999.

## REST design principles

- Use nouns such as `books` to identify resources.
- Use HTTP methods to describe actions.
- Use resource IDs to identify individual books.
- Use query parameters to filter collections.
- Return appropriate HTTP status codes.
