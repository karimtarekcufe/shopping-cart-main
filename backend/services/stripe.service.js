const stripe = require('stripe')('sk_test_51RDfOUKDhO7xg8xY7pcgxStRFTQrEJ4C5Cn8lGOKQPdKp4Y429C8Q2x4SAcsQV5nJErNkiTgX3cszqWjo9mLu4rQ00WxvyX6R9');
module.exports = stripe;
exports.createPaymentIntent = async (amount, currency = "usd") => {
  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount * 100,
      currency: currency,
    });
    return paymentIntent;
  } catch (error) {
    throw new Error("Error creating payment intent: " + error.message);
  }
}