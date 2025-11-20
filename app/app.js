//app.js 

const fs = require('fs');
const path = require('path');
const express = require("express");
const { MongoClient, ObjectId } = require("mongodb");

const app = express();
const port = process.env.PORT || 3000;

const mongoUri = process.env.MONGO_URI;

function readWizExercise() {
  const wizPath = path.join(__dirname, 'wizexercise.txt');
  const result = {
    exists: false,
    content: null,
    error: null,
  };

  try {
    if (fs.existsSync(wizPath)) {
      result.exists = true;
      result.content = fs.readFileSync(wizPath, 'utf8').trim();
    }
  } catch (err) {
    result.error = err.message;
  }

  return result;
}

if (!mongoUri) {
  console.error("MONGO_URI environment variable is not set. Exiting.");
  process.exit(1);
}

let mongoClient;
let db;
let findingsCollection;

// Basic in-memory state for status
let mongoConnected = false;

async function initMongo() {
  try {
    console.log("Connecting to MongoDB...");
    mongoClient = new MongoClient(mongoUri, {
      serverSelectionTimeoutMS: 5000,
    });

    await mongoClient.connect();
    db = mongoClient.db();
    findingsCollection = db.collection("security_findings");
    mongoConnected = true;

    // Seed a couple of example findings if collection is empty
    const count = await findingsCollection.countDocuments();
    if (count === 0) {
      console.log("Seeding initial findings...");
      await findingsCollection.insertMany([
        {
          title: "MongoDB instance exposed to the internet",
          severity: "High",
          status: "Open",
          resource: "EC2: MongoDB public subnet + SG open on 27017",
          description:
            "Intentional misconfiguration for Wiz exercise: MongoDB EC2 is in a public subnet with inbound 27017 allowed.",
          createdAt: new Date(),
          updatedAt: new Date(),
        },
        {
          title: "Kubernetes service account has cluster-admin",
          severity: "Critical",
          status: "Open",
          resource: "K8s: wiz-app-sa",
          description:
            "wiz-app-sa is bound to cluster-admin for demonstration of excessive privileges.",
          createdAt: new Date(),
          updatedAt: new Date(),
        },
      ]);
    }

    console.log("Connected to MongoDB and initialized collection.");
  } catch (err) {
    console.error("Failed to connect to MongoDB at startup:", err);
    process.exit(1); // fail fast so pods CrashLoop
  }
}

// Express middleware
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

// Simple helper to render a generic error page when Mongo is unavailable
function renderMongoError(res, message) {
  res.status(500).send(`<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Wiz Security Findings - Error</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 2rem; background: #fafafa; }
    .card { background: #fff; border-radius: 8px; padding: 1.5rem; max-width: 800px; border: 1px solid #ddd; }
    .error { color: red; font-weight: bold; }
    a { color: #0366d6; text-decoration: none; }
    a:hover { text-decoration: underline; }
  </style>
</head>
<body>
  <div class="card">
    <h1>Wiz Security Findings Tracker</h1>
    <p class="error">MongoDB is unavailable. This application cannot function without MongoDB.</p>
    <p>${message || "Check the MongoDB EC2 instance and try again."}</p>
  </div>
</body>
</html>`);
}

// Health endpoint (for demo & checks)
app.get('/healthz', (req, res) => {
  const wiz = readWizExercise();

  res.json({
    status: 'OK',
    mongoConnected,          // you already track this bool in your app
    wizFileExists: wiz.exists,
    wizexerciseName: wiz.content,
  });
});


// Diagnostics JSON (nice for demo)
app.get('/diagnostics', (req, res) => {
  const wiz = readWizExercise();

  res.json({
    status: 'OK',
    mongoConnected,
    wizexercise: wiz,
    environment: {
      nodeVersion: process.version,
      pid: process.pid,
      env: {
        NODE_ENV: process.env.NODE_ENV || null,
        MONGO_URI_PRESENT: !!process.env.MONGO_URI,
      },
    },
  });
});

// List all findings (home page)
app.get("/", async (req, res) => {
  if (!findingsCollection) {
    return renderMongoError(res, "Database connection is not initialized.");
  }

  let findings = [];
  try {
    findings = await findingsCollection
      .find({})
      .sort({ updatedAt: -1 })
      .toArray();
  } catch (err) {
    console.error("Error querying findings:", err);
    return renderMongoError(res, "Failed to query findings from MongoDB.");
  }

  res.send(`<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Wiz Security Findings Tracker</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 2rem; background: #fafafa; }
    .card { background: #fff; border-radius: 8px; padding: 1.5rem; max-width: 1100px; border: 1px solid #ddd; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
    h1 { margin-top: 0; }
    table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
    th, td { padding: 0.5rem 0.75rem; border-bottom: 1px solid #eee; text-align: left; font-size: 0.95rem; }
    th { background: #f5f5f5; }
    .badge { display: inline-block; padding: 0.15rem 0.5rem; border-radius: 999px; font-size: 0.8rem; }
    .sev-Low { background: #e1f5fe; color: #01579b; }
    .sev-Medium { background: #fff3e0; color: #ef6c00; }
    .sev-High { background: #ffebee; color: #c62828; }
    .sev-Critical { background: #fbe9e7; color: #bf360c; font-weight: bold; }
    .status-Open { color: #c62828; font-weight: 600; }
    .status-In\\ Progress { color: #ef6c00; font-weight: 600; }
    .status-Resolved { color: #2e7d32; font-weight: 600; }
    a { color: #0366d6; text-decoration: none; }
    a:hover { text-decoration: underline; }
    .actions form { display: inline; margin: 0; }
    .top-bar { display: flex; justify-content: space-between; align-items: center; }
    .button { display: inline-block; padding: 0.4rem 0.9rem; border-radius: 4px; background: #0366d6; color: #fff; text-decoration: none; font-size: 0.9rem; }
    .button:hover { background: #024b9b; }
    .meta { font-size: 0.85rem; color: #666; margin-top: 0.5rem; }
  </style>
</head>
<body>
  <div class="card">
    <div class="top-bar">
      <div>
        <h1>Wiz Security Findings Tracker</h1>
        <div class="meta">
          Backend: MongoDB (via <code>MONGO_URI</code>) · 
          Collection: <code>security_findings</code>
        </div>
      </div>
      <div>
        <a class="button" href="/findings/new">+ New Finding</a>
      </div>
    </div>

    <table>
      <thead>
        <tr>
          <th>Title</th>
          <th>Severity</th>
          <th>Status</th>
          <th>Resource</th>
          <th>Updated</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody>
        ${
          findings.length === 0
            ? `<tr><td colspan="6" style="text-align:center; padding: 1rem;">No findings yet. Create one using the button above.</td></tr>`
            : findings
                .map((f) => {
                  const sevClass = `sev-${f.severity}`;
                  const statusClass = `status-${(f.status || "").replace(
                    " ",
                    "\\ "
                  )}`;
                  const updated =
                    f.updatedAt ? new Date(f.updatedAt).toLocaleString() : "";
                  return `<tr>
                    <td>${f.title || ""}</td>
                    <td><span class="badge ${sevClass}">${f.severity}</span></td>
                    <td><span class="${statusClass}">${f.status}</span></td>
                    <td>${f.resource || ""}</td>
                    <td>${updated}</td>
                    <td class="actions">
                      <a href="/findings/${f._id}/edit">Edit</a>
                      &nbsp;|&nbsp;
                      <form method="POST" action="/findings/${f._id}/delete" onsubmit="return confirm('Delete this finding?');">
                        <button type="submit" style="border:none; background:none; color:#c62828; cursor:pointer; padding:0;">Delete</button>
                      </form>
                    </td>
                  </tr>`;
                })
                .join("")
        }
      </tbody>
    </table>
  </div>
</body>
</html>`);
});

// Render "New finding" form
app.get("/findings/new", (req, res) => {
  res.send(`<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>New Finding - Wiz Security Findings</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 2rem; background: #fafafa; }
    .card { background: #fff; border-radius: 8px; padding: 1.5rem; max-width: 700px; border: 1px solid #ddd; }
    label { display:block; margin-top: 0.75rem; font-weight: 600; }
    input[type="text"], textarea, select {
      width: 100%; padding: 0.4rem; margin-top: 0.2rem; border-radius: 4px; border: 1px solid #ccc; font-size: 0.95rem;
    }
    textarea { min-height: 120px; }
    .actions { margin-top: 1rem; }
    button { padding: 0.4rem 0.9rem; border-radius: 4px; border:none; background:#0366d6; color:#fff; cursor:pointer; }
    button:hover { background:#024b9b; }
    a { color:#0366d6; text-decoration:none; }
    a:hover { text-decoration:underline; }
  </style>
</head>
<body>
  <div class="card">
    <h1>New Security Finding</h1>
    <form method="POST" action="/findings">
      <label>Title
        <input type="text" name="title" required />
      </label>

      <label>Severity
        <select name="severity">
          <option>Low</option>
          <option>Medium</option>
          <option>High</option>
          <option>Critical</option>
        </select>
      </label>

      <label>Status
        <select name="status">
          <option>Open</option>
          <option>In Progress</option>
          <option>Resolved</option>
        </select>
      </label>

      <label>Resource
        <input type="text" name="resource" placeholder="e.g. EC2: i-0abc..., SG: sg-12345, S3: wiz-backups-..." />
      </label>

      <label>Description
        <textarea name="description" placeholder="Describe the issue, its impact, and any context..."></textarea>
      </label>

      <div class="actions">
        <button type="submit">Create</button>
        &nbsp;&nbsp;
        <a href="/">Cancel</a>
      </div>
    </form>
  </div>
</body>
</html>`);
});

// Handle "Create finding"
app.post("/findings", async (req, res) => {
  if (!findingsCollection) {
    return renderMongoError(res, "Database connection is not initialized.");
  }

  const { title, severity, status, resource, description } = req.body;

  const doc = {
    title: title || "",
    severity: severity || "Low",
    status: status || "Open",
    resource: resource || "",
    description: description || "",
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  try {
    await findingsCollection.insertOne(doc);
    res.redirect("/");
  } catch (err) {
    console.error("Error inserting finding:", err);
    return renderMongoError(res, "Failed to insert finding into MongoDB.");
  }
});

// Render "Edit finding" form
app.get("/findings/:id/edit", async (req, res) => {
  if (!findingsCollection) {
    return renderMongoError(res, "Database connection is not initialized.");
  }

  let finding;
  try {
    finding = await findingsCollection.findOne({
      _id: new ObjectId(req.params.id),
    });
  } catch (err) {
    console.error("Error finding document:", err);
    return renderMongoError(res, "Failed to load finding from MongoDB.");
  }

  if (!finding) {
    return res.status(404).send("Finding not found");
  }

  const severityOptions = ["Low", "Medium", "High", "Critical"]
    .map((sev) => `<option ${
      finding.severity === sev ? "selected" : ""
    }>${sev}</option>`)
    .join("");

  const statusOptions = ["Open", "In Progress", "Resolved"]
    .map((st) => `<option ${
      finding.status === st ? "selected" : ""
    }>${st}</option>`)
    .join("");

  res.send(`<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Edit Finding - Wiz Security Findings</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 2rem; background: #fafafa; }
    .card { background: #fff; border-radius: 8px; padding: 1.5rem; max-width: 700px; border: 1px solid #ddd; }
    label { display:block; margin-top: 0.75rem; font-weight: 600; }
    input[type="text"], textarea, select {
      width: 100%; padding: 0.4rem; margin-top: 0.2rem; border-radius: 4px; border: 1px solid #ccc; font-size: 0.95rem;
    }
    textarea { min-height: 120px; }
    .actions { margin-top: 1rem; }
    button { padding: 0.4rem 0.9rem; border-radius: 4px; border:none; background:#0366d6; color:#fff; cursor:pointer; }
    button:hover { background:#024b9b; }
    a { color:#0366d6; text-decoration:none; }
    a:hover { text-decoration:underline; }
  </style>
</head>
<body>
  <div class="card">
    <h1>Edit Security Finding</h1>
    <form method="POST" action="/findings/${finding._id}/update">
      <label>Title
        <input type="text" name="title" value="${finding.title || ""}" required />
      </label>

      <label>Severity
        <select name="severity">
          ${severityOptions}
        </select>
      </label>

      <label>Status
        <select name="status">
          ${statusOptions}
        </select>
      </label>

      <label>Resource
        <input type="text" name="resource" value="${finding.resource || ""}" />
      </label>

      <label>Description
        <textarea name="description">${finding.description || ""}</textarea>
      </label>

      <div class="actions">
        <button type="submit">Save</button>
        &nbsp;&nbsp;
        <a href="/">Cancel</a>
      </div>
    </form>
  </div>
</body>
</html>`);
});

// Handle "Update finding"
app.post("/findings/:id/update", async (req, res) => {
  if (!findingsCollection) {
    return renderMongoError(res, "Database connection is not initialized.");
  }

  const { title, severity, status, resource, description } = req.body;

  try {
    await findingsCollection.updateOne(
      { _id: new ObjectId(req.params.id) },
      {
        $set: {
          title: title || "",
          severity: severity || "Low",
          status: status || "Open",
          resource: resource || "",
          description: description || "",
          updatedAt: new Date(),
        },
      }
    );
    res.redirect("/");
  } catch (err) {
    console.error("Error updating finding:", err);
    return renderMongoError(res, "Failed to update finding in MongoDB.");
  }
});

// Handle "Delete finding"
app.post("/findings/:id/delete", async (req, res) => {
  if (!findingsCollection) {
    return renderMongoError(res, "Database connection is not initialized.");
  }

  try {
    await findingsCollection.deleteOne({
      _id: new ObjectId(req.params.id),
    });
    res.redirect("/");
  } catch (err) {
    console.error("Error deleting finding:", err);
    return renderMongoError(res, "Failed to delete finding from MongoDB.");
  }
});

initMongo()
  .then(() => {
    app.listen(port, () => {
      console.log(`Security Findings app listening on port ${port}`);
    });
  })
  .catch((err) => {
    console.error("Error during startup:", err);
    process.exit(1);
  });

process.on("SIGINT", async () => {
  if (mongoClient) {
    await mongoClient.close();
  }
  process.exit(0);
});

process.on("SIGTERM", async () => {
  if (mongoClient) {
    await mongoClient.close();
  }
  process.exit(0);
});
