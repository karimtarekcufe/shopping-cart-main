const mongoose = require("mongoose");

const db = mongoose.createConnection(
  "mongodb+srv://peterboles06:f7vfMoXYcxCZ3RiT@shoppingapp.mlufp.mongodb.net/Shopping"
);

db.on("open", () => console.log("Connected to MongoDB"));
db.on("error", (err) => console.error("Error connecting to MongoDB:", err));

module.exports = db; // Export the connection object
