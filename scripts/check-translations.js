#!/usr/bin/env node
// Checks all topic JSON files for missing language keys.
// Usage: node scripts/check-translations.js

const fs = require('fs');
const path = require('path');

const REQUIRED_LANGS = ['en', 'ru'];
const TRANSLATABLE_FIELDS = ['label', 'summary', 'narrative', 'details'];
let warnings = 0;

function checkField(filePath, nodeId, fieldName, value) {
  if (value === null || value === undefined) return;
  if (typeof value === 'string') {
    console.warn('WARN: ' + filePath + ' → ' + nodeId + '.' + fieldName + ' is a plain string, not multilingual');
    warnings++;
    return;
  }
  if (typeof value === 'object') {
    for (const lang of REQUIRED_LANGS) {
      if (!value[lang]) {
        console.warn('WARN: ' + filePath + ' → ' + nodeId + '.' + fieldName + ' missing lang "' + lang + '"');
        warnings++;
      }
    }
  }
}

const indexPath = path.join(__dirname, '..', 'topics', 'index.json');
if (fs.existsSync(indexPath)) {
  const index = JSON.parse(fs.readFileSync(indexPath, 'utf8'));
  (Array.isArray(index) ? index : index.topics || []).forEach(topic => {
    checkField('topics/index.json', topic.id, 'label', topic.label);
    checkField('topics/index.json', topic.id, 'description', topic.description);
  });
}

const topicsDir = path.join(__dirname, '..', 'topics');
fs.readdirSync(topicsDir).filter(f => f.endsWith('.json') && f !== 'index.json').forEach(file => {
  const filePath = path.join(topicsDir, file);
  const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));

  if (data.meta) {
    checkField(file, 'meta', 'label', data.meta.label);
    checkField(file, 'meta', 'description', data.meta.description);
  }

  if (data.nodes && typeof data.nodes === 'object') {
    Object.entries(data.nodes).forEach(([nodeId, node]) => {
      TRANSLATABLE_FIELDS.forEach(field => {
        if (node[field] !== undefined) {
          checkField(file, nodeId, field, node[field]);
        }
      });
    });
  }

  (data.edges || []).forEach((edge, i) => {
    if (edge.label) {
      checkField(file, 'edge[' + i + '](' + edge.from + '->' + edge.to + ')', 'label', edge.label);
    }
  });
});

if (warnings > 0) {
  console.log('\n' + warnings + ' translation warning(s) found.');
  process.exit(1);
} else {
  console.log('All translation keys present.');
  process.exit(0);
}
