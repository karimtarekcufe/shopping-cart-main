const UserService = require("../services/user.services");
const StripeService = require("../services/stripe.service");

exports.register = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    const successRes = await UserService.registerUser(email, password);
    res.json({ status: true, success: "User registered successfully" });
  } catch (error) {
    throw error;
  }
};
exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    const user = await UserService.checkUser(email);
    if (!user) {
      throw new Error("User not found");
    }
    const isValidPassword = await user.isValidPassword(password);
    if (!isValidPassword) {
      throw new Error("Invalid password");
    }
    let tokenData = { _id: user._id, email: user.email };
    const token = await UserService.generateToken(tokenData, "secretkey", "1h");
    res.status(200).json({ status: true, token: token });
  } catch (error) {
    throw error;
  }
};
exports.createPaymentIntent = async (req, res, next) => {
  try {
    const { amount } = req.body; 
    
    const paymentIntent = await StripeService.createPaymentIntent(amount);

    res.status(200).json({
      clientSecret: paymentIntent.client_secret,
      message: "Payment intent created successfully"
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

