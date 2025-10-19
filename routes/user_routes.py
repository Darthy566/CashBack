from flask import Blueprint, jsonify

user_bp = Blueprint('user_bp', __name__)

@user_bp.route('/test', methods=['GET'])
def test():
    return jsonify({"message": "User route working"}), 200
