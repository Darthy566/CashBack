from flask import Flask, jsonify
from config import init_db
from routes.user_routes import user_bp

app = Flask(__name__)

# Initialize database connection
init_db(app)

# Register blueprints (user routes)
app.register_blueprint(user_bp, url_prefix="/api")

# Test route
@app.route('/')
def home():
    return jsonify({"message": "Server running"}), 200

if __name__ == '__main__':
    app.run(debug=True)
