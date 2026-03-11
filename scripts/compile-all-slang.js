#!/usr/bin/env node
"use strict";

const fs = require("node:fs");
const path = require("node:path");
const { spawnSync } = require("node:child_process");

const repoRoot = path.resolve(__dirname, "..");
const compiler = path.join(repoRoot, "slang.exe");
const outputDir = path.join(repoRoot, "compiled");
const skipDirs = new Set([".git", "compiled", "node_modules"]);

function findSlangFiles(dir) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  const files = [];

  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);

    if (entry.isDirectory()) {
      if (!skipDirs.has(entry.name)) {
        files.push(...findSlangFiles(fullPath));
      }
      continue;
    }

    if (entry.isFile() && entry.name.toLowerCase().endsWith(".slang")) {
      files.push(fullPath);
    }
  }

  return files;
}

function runCompile(inputPath, outputPath) {
  return spawnSync(compiler, ["-z", "-i", inputPath, "-o", outputPath], {
    stdio: "inherit",
  });
}

if (!fs.existsSync(compiler)) {
  console.error(`Compiler not found: ${compiler}`);
  process.exit(1);
}

if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}

const slangFiles = findSlangFiles(repoRoot).sort((a, b) =>
  a.localeCompare(b, "en")
);

if (slangFiles.length === 0) {
  console.log("No .slang files found.");
  process.exit(0);
}

let failed = false;

for (const inputPath of slangFiles) {
  const outputName = `${path.parse(inputPath).name}.compiled.ic10`;
  const outputPath = path.join(outputDir, outputName);

  console.log(`Compiling: ${path.basename(inputPath)} -> ${outputName}`);
  let result = runCompile(inputPath, outputPath);

  if ((result.status !== 0 || result.error) && fs.existsSync(outputPath)) {
    try {
      fs.unlinkSync(outputPath);
      result = runCompile(inputPath, outputPath);
    } catch {
      // Ignore cleanup errors and report compiler failure below.
    }
  }

  if (result.status !== 0 || result.error) {
    failed = true;
    if (result.error) {
      console.error(`Process error: ${result.error.message}`);
    }
    console.error(`Compilation failed: ${inputPath}`);
  }
}

if (failed) {
  process.exit(1);
}

console.log(`Done. Compiled ${slangFiles.length} file(s) into '${outputDir}'.`);
