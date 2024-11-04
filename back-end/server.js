const express = require("express");
const path = require("path");
const multer = require("multer");
const { exec } = require("child_process");

const app = express();
const port = 3000;

const publicDirectory = path.join(__dirname, "/../front-end/");

app.use(express.static(publicDirectory, { index: false }));

app.get("/", (req, res) => {
  res.sendFile(path.join(publicDirectory, "index.html"));
});

const storage = multer.diskStorage({
  destination: path.join(__dirname, "../Ai/input-folder"),
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(null, `canvas-${uniqueSuffix}.png`);
  },
});

const upload = multer({ storage: storage });

app.post("/traiter-canvas", upload.single("canvas"), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: "No file uploaded" });
  }

  exec("cd ../Ai && python ai-recognition.py", (error, stdout, stderr) => {
    if (error) {
      console.error(`Execution error: ${error}`);
      return res.status(500).json({ error: "Failed to process the image" });
    }

    try {
      const result = JSON.parse(stdout);
      res.json(result);
    } catch (parseError) {
      console.error(`Parsing error: ${parseError}`);
      res.status(500).json({ error: "Failed to parse output" });
    }
  });
});

app.get("*", (req, res, next) => {
  res.sendFile(path.join(publicDirectory, req.path), (err) => {
    if (err) {
      next();
    }
  });
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}/`);
});
