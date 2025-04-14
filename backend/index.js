const app = require("./app");
const db = require("./config/db");
const UserModel = require("./model/user.model");
const port = 5300;
app.get("/", (req, res) => {
  res.send("Hello World!");
});
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
