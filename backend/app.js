require('dotenv').config();
const express = require("express");
const body_parser = require("body-parser");
const userRouter = require("./routers/user.router");
const itemRouter = require("./routers/itemRoutes");

const app = express();

app.use(body_parser.json());

app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    message: "Something went wrong!",
    error: err.message,
  });
});

app.use("/", userRouter);
app.use("/", itemRouter);
app.use("/api/user", userRouter);

module.exports = app;
