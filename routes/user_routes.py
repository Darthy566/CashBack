from flask import Blueprint, jsonify, request
from database.models import get_db_connection
from utils.helpers import hash_password, verify_password

user_bp = Blueprint('user_bp', __name__)

# ---------------- TEST ROUTE ----------------
@user_bp.route('/test', methods=['GET'])
def test():
    return jsonify({"message": "User route working"}), 200


# ---------------- REGISTER ENDPOINT ----------------
@user_bp.route('/register', methods=['POST'])
def register_user():
    data = request.get_json()

    required_fields = ['first_name', 'last_name', 'email', 'mobile', 'password']
    if not all(field in data and data[field] for field in required_fields):
        return jsonify({"error": "All fields are required."}), 400

    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM users WHERE email = ?", (data['email'],))
    existing_user = cursor.fetchone()

    if existing_user:
        conn.close()
        return jsonify({"error": "Email already registered."}), 409

    hashed_pw = hash_password(data['password'])
    full_name = f"{data['first_name']} {data.get('middle_name', '')} {data['last_name']}".strip()

    cursor.execute("""
        INSERT INTO users (name, email, password)
        VALUES (?, ?, ?)
    """, (full_name, data['email'], hashed_pw))

    conn.commit()
    conn.close()

    return jsonify({"message": "Account created successfully!"}), 201


# ---------------- LOGIN ENDPOINT ----------------
@user_bp.route('/login', methods=['POST'])
def login_user():
    data = request.get_json()

    if not data.get('email') or not data.get('password'):
        return jsonify({"error": "Email and password are required."}), 400

    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM users WHERE email = ?", (data['email'],))
    user = cursor.fetchone()

    conn.close()

    if user and verify_password(user['password'], data['password']):
        return jsonify({
            "message": "Login successful!",
            "user": {"name": user['name'], "email": user['email']}
        }), 200
    else:
        return jsonify({"error": "Invalid email or password."}), 401
