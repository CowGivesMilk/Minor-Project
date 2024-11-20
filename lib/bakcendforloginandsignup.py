from flask import Flask, request, jsonify
from flask_cors import CORS
import bcrypt
import mysql.connector

app = Flask(__name__)
CORS(app)  # Allow cross-origin requests

# Database configuration
db_config = {
    'host': 'localhost',
    'user': 'root',
    'password': '1234',
    'database': 'user_auth'
}

def get_db_connection():
    return mysql.connector.connect(**db_config)

@app.route('/login', methods=['POST'])
def login():
    # Parse JSON data from the request
    data = request.json
    email = data.get('email')
    password = data.get('password')

    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)

        # Fetch user with the given email
        cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
        user = cursor.fetchone()

        if user and bcrypt.checkpw(password.encode('utf-8'), user['password_hash'].encode('utf-8')):
            return jsonify({'message': 'Login successful', 'user': {'id': user['id'], 'username': user['username']}})
        else:
            return jsonify({'error': 'Invalid email or password'}), 401
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        connection.close()

if __name__ == '__main__':
    app.run(debug=True)
