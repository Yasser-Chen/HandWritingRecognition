const express = require("express");
const path = require("path");
const multer = require("multer");
const { exec } = require("child_process");
const cors = require("cors");
const sqlite3 = require("sqlite3").verbose();
const bcrypt = require("bcrypt"); // For password hashing

const app = express();
app.use(cors());
const port = 3000;

// Serve static files from input-folder
app.use(
  "/input-folder",
  express.static(path.join(__dirname, "../Ai/input-folder"))
);

// Create/open the SQLite database
const db = new sqlite3.Database("db.sqlite", (err) => {
  if (err) {
    console.error("Failed to open database:", err);
  } else {
    // Create users table
    db.run(`
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        email TEXT,
        password TEXT,
        name TEXT,
        family_name TEXT
      )
    `);

    // Create images table with created_at field
    db.run(`
      CREATE TABLE IF NOT EXISTS images (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        path TEXT,
        prediction TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(user_id) REFERENCES users(id)
      )
    `);

    // Initialize existing records with a default created_at value
    const updateCreatedAt = `
      UPDATE images
      SET created_at = datetime('now')
      WHERE created_at IS NULL
    `;
    db.run(updateCreatedAt, (err) => {
      if (err) {
        console.error("Failed to update existing records:", err);
      }
    });
  }
});

// Register endpoint
app.post("/register", express.json(), async (req, res) => {
  // Expect { username, email, password, name, family_name }
  const { username, email, password, name, family_name } = req.body;
  const hashed = await bcrypt.hash(password, 8);
  db.run(
    `INSERT INTO users (username, email, password, name, family_name) VALUES (?, ?, ?, ?, ?)`,
    [username, email, hashed, name, family_name],
    function (err) {
      if (err) {
        console.error(err);
        return res.status(400).json({ error: "User creation failed" });
      }
      res.json({ success: true, userId: this.lastID });
    }
  );
});

// Login endpoint
app.post("/login", express.json(), (req, res) => {
  // Expect { username, password }
  const { username, password } = req.body;
  db.get(
    `SELECT * FROM users WHERE username = ?`,
    [username],
    async (err, row) => {
      if (err || !row) {
        return res.status(401).json({ error: "Invalid credentials" });
      }
      const match = await bcrypt.compare(password, row.password);
      if (!match) {
        return res.status(401).json({ error: "Invalid credentials" });
      }
      // Return minimal user info
      res.json({
        success: true,
        user: {
          id: row.id,
          name: row.name,
          family_name: row.family_name,
        },
      });
    }
  );
});

const storage = multer.diskStorage({
  destination: path.join(__dirname, "../Ai/input-folder"),
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    const same_name = `canvas-${uniqueSuffix}.png`;
    cb(null, same_name);
  },
});

const upload = multer({ storage: storage });

app.post("/traiter-canvas", upload.single("canvas"), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: "No file uploaded" });
  }
  const userId = req.body.userId; // Ensure userId is received
  if (!userId) {
    return res.status(400).json({ error: "User ID is required" });
  }

  exec(
    `cd ../Ai && python ai-recognition.py ${req.file.filename}`,
    (error, stdout, stderr) => {
      // Use req.file.filename instead of same_name
      if (error) {
        console.error(`Execution error: ${error}`);
        return res.status(500).json({ error: "Failed to process the image" });
      }
      try {
        const result = JSON.parse(stdout);
        // Insert record into images table
        db.run(
          `INSERT INTO images (user_id, path, prediction) VALUES (?, ?, ?)`,
          [userId, req.file.filename, result.text],
          (err) => {
            if (err) {
              console.error(err);
              // Optionally handle the error, e.g., delete the uploaded file
            }
          }
        );
        res.json(result);
      } catch (parseError) {
        console.error(`Parsing error: ${parseError}`);
        res.status(500).json({ error: "Failed to parse output" });
      }
    }
  );
});

// Modify the /images/:userId endpoint to include created_at
app.get("/images/:userId", (req, res) => {
  const { userId } = req.params;
  db.all("SELECT * FROM images WHERE user_id = ?", [userId], (err, rows) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ error: "Failed to get images" });
    }
    res.json({ success: true, images: rows });
  });
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}/`);
});
