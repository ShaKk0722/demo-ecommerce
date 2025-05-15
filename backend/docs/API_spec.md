**API Specification** for Geek-up Intern

---

## **API Overview**

### Base URL: `/api/geek-up`

---

## **1. API (Get and send data)**

### **1.1. Fetch All Product Categories**
- **Method**: `GET`
- **Endpoint**: `/category`
- **Description**:  Fetches a list of all product categories available in the e-commerce
platform.
- **Query Parameters**:
    - `NO`: No query parameters needed.
- **Request Body**:
    - `NO`: No request body needed.
- **Response**:
    - **200 OK**:
    ```json
    {
        "success": "true",
        "data": 
        [
            {
                "category_id": 1,
                "category_name": "Shoes",
                "category_description": "All kinds of shoes",
                "category_imageURL": "shoes.jpg"
            },
            {
                "category_id": 2,
                "category_name": "Clothing",
                "category_description": "Men and women clothing",
                "category_imageURL": "clothing.jpg"
            }
        ]
    }
    ```
    - **500: Server error**:
  
---

### **1.2. Fetch Products by Category**
- **Method**: `GET`
- **Endpoint**: `/categories/{categoryId}/products`
- **Description**: Fetches a list of products that belong to a specific category.
- **Query Parameters**:
    - `categoryId (path)` : ID of the category to fetch products from.
    - `page (query)`: Page number for pagination (default = 1).
    - `limit (query)`: Number of products per page (default = 20).
- **Example Request**: `/categories/{categoryId}/products?page1&limit=20`
- **Request Body**:
    - `NO`: No request body needed.
- **Response**:
    - **200 OK**:
    ```json
    {
        "success": true,
        "data": {
        "category": {
            "category_id": 1,
            "category_name": "Shoes",
            "category_description": "All kinds of shoes"
        },
        "products": [
            {
            "product_id": 1,
            "product_name": "Air Max 90",
            "model": "AM90",
            "color": "Red",
            "product_imageURL": "airmax90.jpg",
            "brand": "Nike",
            "size": "42",
            "price": 120.00
            }
        ],
        "pagination": {
            "total": 1,
            "page": 1,
            "limit": 20,
            "pages": 1
        }
        }
    }
    ```
    - **404 Not Found**:
    ```json
    {
    "success": false,
    "error": {
        "code": 404,
        "message": "Category not found"
    }
    }
    ```
    - **500: Server error**:
---

### **1.3. Search Products with Filters**
- **Method**: `GET`
- **Endpoint**: `/products/search`
- **Description**: Allows users to search (full-text search) for products using various filters and
search terms.
- **Query Parameters**:
    - `q (query) - (optional)` : Search term for full-text search across product names, descriptions, brands
    - `category (query) - (optional)` : Filter by category ID
    - `brand (query) - (optional)` : Filter by brand name
    - `color (query) - (optional)` : Filter by color
    - `size (query) - (optional) ` : Filter by size
    - `min_price (query) - (optional)` : Minimum price
    - `max_price (query) - (optional)` : Maximum price
    - `page (query)`: Page number for pagination (default = 1).
    - `limit (query)`: Number of products per page (default = 20).
- **Request Body**:
    - `NO`: No request body needed.
- **Example Request**: `/products/search?q=air&brand=Nike&color=Red&page=1&limit=20`
- **Response**:
    - **200 OK**:
    ```json
    {
  "success": true,
  "data": {
    "products": [
      {
        "product_id": 1,
        "product_name": "Air Max 90",
        "model": "AM90",
        "color": "Red",
        "product_imageURL": "airmax90.jpg",
        "brand": "Nike",
        "size": "42",
        "price": 120.00,
        "category": {
          "category_id": 1,
          "category_name": "Shoes"
        }
      }
    ],
    "pagination": {
      "total": 1,
      "page": 1,
      "limit": 20,
      "pages": 1
    },
    "filters": {
      "brands": [
        {"brand": "Nike", "count": 1}
      ],
      "colors": [
        {"color": "Red", "count": 1}
      ]
    }
  }
}
    ```
- **404 Not Found**:
    ```json
    {
    "success": false,
    "error": {
        "code": 404,
        "message": "Invalid parameters"
    }
    }
    ```
    - **500: Server error**:

---

### **1.4. Create Order and Process Payment**
- **Method**: `POST`
- **Endpoint**: `/orders`
- **Description**: Creates a new order and processes payment.
- **Query Parameters**:
    - `NO`: No query parameters needed.
- **Request Body**:
    ```json
    {
  "customer_id": 1,
  "address": "123 ABC Street, District 1, HCMC",
  "products": [
    {
      "product_id": 101,
      "quantity": 2,
      "unit_price": 150.00
    }
  ],
  "payment": {
    "method": "credit_card",
    "amount": 300.00
  },
  "voucher_id": 5
}
    ```
- **Response**:
    - **201 Created**:
    - **400 Bad Request**:
    - **401 Unauthorized**:
    - **403 Forbidden**: 
    - **500: Server error**:


---
### **1.5. LOG OUT**
- **Method**: `POST`
- **Description**: Logs out the user by invalidating their session or JWT token.

- **Response**:
    - **200 OK**:
      ```json
      {
        "message": "Logout successful"
      }
      ```
---

---

**Documentation and Error Handling**
---
**Common Responses**

`200 OK`: Thao tác thành công.

`201 Created`: Tài nguyên được tạo thành công.

`204 No Content`: Thao tác thành công, không có nội dung trả về.

`400 Bad Request`: Dữ liệu không hợp lệ hoặc thiếu thông tin.

`401 Unauthorized`: Người dùng không được phép truy cập tài nguyên.

`404 Not Found`: Tài nguyên không tìm thấy.

`500 Internal Server Error`: Lỗi không xác định trên server.

**Security Considerations**

