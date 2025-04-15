const config = require("../config/config");
const stripe = require("stripe")(config.STRIPE_SECRET_KEY);

class StripeService {
  static async createPaymentIntent(amount) {
    try {
      const paymentIntent = await stripe.paymentIntents.create({
        amount: amount * 100, // Convert to cents
        currency: "usd",
        payment_method_types: ["card"],
      });

      return paymentIntent;
    } catch (error) {
      throw new Error(`Error creating payment intent: ${error.message}`);
    }
  }
}

module.exports = StripeService;
