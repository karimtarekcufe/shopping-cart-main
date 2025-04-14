const UserModel = require("../model/user.model.js");
const jwt = require("jsonwebtoken");
class UserService {
  static async registerUser(email, password) {
    try {
      const createUser = new UserModel({ email, password });
      return await createUser.save();
    } catch (error) {
      throw error;
    }
  }
  static async checkUser(email) {
    try {
      return await UserModel.findOne({ email: email });
    } catch (error) {
      throw error;
    }
  }
  static async generateToken(tokenData, secretKey, jwt_expiration) {
    try {
      return jwt.sign(tokenData, secretKey, { expiresIn: jwt_expiration });
    } catch (error) {
      throw error;
    }
  }
}

module.exports = UserService;
