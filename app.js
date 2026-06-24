require("dotenv").config();
const express = require("express");
const app = express();

const port = Number(process.env.PORT) || 3000;
const appName = process.env.APP_NAME || "node-js-app";

app.use(express.json());

app.get("/health", (req, res) => {
  res.json({
    status: "ok",
    app: appName,
    uptime: process.uptime(),
  });
});

app.get("/", (req, res) => {
  res.send(
    process.env.WELCOME_MESSAGE || `Welcome to ${appName}! Your CI/CD pipeline is working.`
  );
});

if (require.main === module) {
  app.listen(port, () => {
    console.log(`Server running on port ${port}`);
  });
}

module.exports = app;
