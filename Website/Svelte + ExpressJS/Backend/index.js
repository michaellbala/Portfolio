const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const router = require("./routes/index.js");
const app = express();

const port = 3000;

app.use(cors());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

app.use("/api", router);

app.get("/", (req, res) => {
    res.send("Test Backend");
});

app.listen(port, () => {
    console.log(`Backend started on port ${port}`);
});