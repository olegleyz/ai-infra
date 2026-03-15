#!/usr/bin/env node
// One-time conversion script: extracts DATA + CONNECTIONS from index.html → topics/ai-dc.json
// Run: node convert.js

const fs = require('fs');
const path = require('path');

const html = fs.readFileSync(path.join(__dirname, 'index.html'), 'utf8');

// Extract the script content between <script> and </script>
const scriptMatch = html.match(/<script>([\s\S]*?)<\/script>/);
if (!scriptMatch) { console.error('No <script> found'); process.exit(1); }

const scriptContent = scriptMatch[1];

// Extract CONNECTIONS array and DATA object via eval
// We need to isolate the variable declarations
const connectionsMatch = scriptContent.match(/const CONNECTIONS = (\[[\s\S]*?\n\]);/);
const dataMatch = scriptContent.match(/const DATA = (\{[\s\S]*?\n\});/);

if (!connectionsMatch) { console.error('Could not find CONNECTIONS'); process.exit(1); }
if (!dataMatch) { console.error('Could not find DATA'); process.exit(1); }

// Eval in a controlled context
let CONNECTIONS, DATA;
try {
  CONNECTIONS = eval('(' + connectionsMatch[1] + ')');
} catch (e) {
  console.error('Failed to parse CONNECTIONS:', e.message);
  process.exit(1);
}

try {
  DATA = eval('(' + dataMatch[1] + ')');
} catch (e) {
  console.error('Failed to parse DATA:', e.message);
  process.exit(1);
}

console.log(`Parsed ${CONNECTIONS.length} connections`);

// Flatten the tree into nodes + hierarchy
const nodes = {};
const hierarchy = {};

function flattenNode(node) {
  // Build node entry (without children)
  const entry = {
    label: node.label,
    icon: node.icon,
    category: node.category,
    summary: node.summary
  };

  // Convert template literal HTML content to markdown-compatible strings
  // The content is already HTML, so we store it as-is (marked.js will pass through HTML)
  if (node.narrative) entry.narrative = node.narrative;
  if (node.details) entry.details = node.details;
  if (node.tags) entry.tags = node.tags;

  nodes[node.id] = entry;

  // Build hierarchy
  if (node.children && node.children.length > 0) {
    hierarchy[node.id] = node.children.map(c => c.id);
    node.children.forEach(flattenNode);
  }
}

flattenNode(DATA);

const nodeCount = Object.keys(nodes).length;
console.log(`Extracted ${nodeCount} nodes`);
console.log(`Hierarchy entries: ${Object.keys(hierarchy).length}`);

// Build the topic JSON
const topicJson = {
  meta: {
    id: "ai-dc",
    label: "AI Data Centers",
    icon: "🏗️",
    description: "Value chain, players, opportunities in the $300B+ AI infrastructure boom"
  },
  nodes,
  hierarchy,
  edges: CONNECTIONS
};

// Write output
const outPath = path.join(__dirname, 'topics', 'ai-dc.json');
fs.writeFileSync(outPath, JSON.stringify(topicJson, null, 2), 'utf8');
console.log(`Written to ${outPath}`);

// Validate
const parsed = JSON.parse(fs.readFileSync(outPath, 'utf8'));
console.log(`\nValidation:`);
console.log(`  Valid JSON: ✓`);
console.log(`  Nodes: ${Object.keys(parsed.nodes).length}`);
console.log(`  Hierarchy entries: ${Object.keys(parsed.hierarchy).length}`);
console.log(`  Edges: ${parsed.edges.length}`);
console.log(`  Root exists: ${parsed.nodes.root ? '✓' : '✗'}`);

// Check all hierarchy children exist in nodes
let missing = 0;
for (const [parent, children] of Object.entries(parsed.hierarchy)) {
  for (const childId of children) {
    if (!parsed.nodes[childId]) {
      console.error(`  MISSING: hierarchy child "${childId}" (parent: "${parent}") not found in nodes`);
      missing++;
    }
  }
}

// Check all edge endpoints exist
let missingEdges = 0;
for (const edge of parsed.edges) {
  if (!parsed.nodes[edge.from]) { console.error(`  MISSING EDGE: from "${edge.from}" not in nodes`); missingEdges++; }
  if (!parsed.nodes[edge.to]) { console.error(`  MISSING EDGE: to "${edge.to}" not in nodes`); missingEdges++; }
}

// Check reachability from root
const reachable = new Set();
function walk(id) {
  if (reachable.has(id)) return;
  reachable.add(id);
  if (parsed.hierarchy[id]) {
    parsed.hierarchy[id].forEach(walk);
  }
}
walk('root');
const unreachable = Object.keys(parsed.nodes).filter(id => !reachable.has(id));

console.log(`  Missing hierarchy refs: ${missing}`);
console.log(`  Missing edge refs: ${missingEdges}`);
console.log(`  Reachable from root: ${reachable.size}/${Object.keys(parsed.nodes).length}`);
if (unreachable.length > 0) {
  console.error(`  UNREACHABLE nodes: ${unreachable.join(', ')}`);
}

if (missing === 0 && missingEdges === 0 && unreachable.length === 0) {
  console.log(`\n✓ All checks passed!`);
} else {
  console.error(`\n✗ Issues found — review above`);
}
