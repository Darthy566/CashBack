from werkzeug.security import generate_password_hash, check_password_hash

def hash_password(password):
    """Hash a plain-text password using werkzeug"""
    return generate_password_hash(password)

def verify_password(hashed_password, input_password):
    """Check if input password matches the hashed password"""
    return check_password_hash(hashed_password, input_password)
