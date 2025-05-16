# Geek-Up E-commerce Demo

An e-commerce demonstration project built with Express.js and PostgreSQL(Docker).

## 📋 Overview

Geek-Up is a backend-focused e-commerce platform that showcases:
- RESTful API design
- Database integration with PostgreSQL

## 🚀 Tech Stack

- **Backend**: Node.js, Express.js
- **Database**: PostgreSQL
- **Utilities**: nodemailer, express-async-handler
- **Dev Tools**: nodemon

## 🛠️ Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/geek-up.git
   cd geek-up
   ```

2. Install dependencies:
   ```
   npm install
   ```

3. Set up environment variables by creating a `.env` file in the root directory:
   ```
   PORT=3000
   
   # Database Configuration
   DB_USER=your_db_user
   DB_HOST=localhost
   DB_NAME=geekup_db
   DB_PASSWORD=your_password
   DB_PORT=5432
   
   # Additional configs as needed
   ```

4. Set up PostgreSQL database:
   - Install PostgreSQL if not already installed
   - Create a database with the name specified in your `.env` file
   - The application will handle table creation and initial setup

## 🚀 Running the Application

### Development Mode
```
npm run dev
```
This starts the server with nodemon for automatic restarts on code changes.



## 📝 API Endpoints

- **Base URL**: `http://localhost:3000/api/geek-up/`


## 📂 Project Structure

```
geek-up/
├── backend/             # Backend source files
│   ├── controllers/     # Request handlers
│   ├── db/              # Database configuration
│   ├── models/          # Data models
│   ├── routes/          # API routes
│   ├── utils/           # Utility functions
│   ├── docs/            # API documentation
│   ├── data/            # Seed data
│   └── server.js        # Entry point
├── .env                 # Environment variables (create this)
├── package.json         # Project dependencies
└── README.md            # Project documentation
```

## 🔧 Additional Configuration

For additional configuration options, please refer to the documentation in the `backend/docs/` directory.

## 📫 Contact

For questions or support, please reach out to the project maintainers.

## 📄 License

This project is licensed under the ISC License. 
