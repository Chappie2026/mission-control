#!/usr/bin/env node
// Converts ontology graph.jsonl to JSON for the Mind Board API
// Reads: /root/.openclaw/workspace/memory/ontology/graph.jsonl
// Writes: /root/sites/mission-control/api/brain-graph.json

const fs = require('fs');
const path = require('path');

const GRAPH_PATH = '/root/.openclaw/workspace/memory/ontology/graph.jsonl';
const OUTPUT_PATH = '/root/sites/mission-control/api/brain-graph.json';

function loadGraph() {
  const entities = {};
  const relations = [];

  if (!fs.existsSync(GRAPH_PATH)) {
    return { entities, relations };
  }

  const lines = fs.readFileSync(GRAPH_PATH, 'utf8').split('\n').filter(l => l.trim());

  for (const line of lines) {
    try {
      const record = JSON.parse(line);
      const op = record.op;

      if (op === 'create') {
        const entity = record.entity;
        entities[entity.id] = entity;
      } else if (op === 'update') {
        if (entities[record.id]) {
          Object.assign(entities[record.id].properties, record.properties || {});
          entities[record.id].updated = record.timestamp;
        }
      } else if (op === 'delete') {
        delete entities[record.id];
      } else if (op === 'relate') {
        relations.push({
          from: record.from,
          rel: record.rel,
          to: record.to,
          properties: record.properties || {}
        });
      } else if (op === 'unrelate') {
        const idx = relations.findIndex(r =>
          r.from === record.from && r.rel === record.rel && r.to === record.to
        );
        if (idx >= 0) relations.splice(idx, 1);
      }
    } catch (e) {
      // Skip malformed lines
    }
  }

  return { entities, relations };
}

try {
  const graph = loadGraph();
  fs.writeFileSync(OUTPUT_PATH, JSON.stringify(graph, null, 2));
  const entityCount = Object.keys(graph.entities).length;
  const relCount = graph.relations.length;
  console.log(`Brain graph exported: ${entityCount} entities, ${relCount} relations → ${OUTPUT_PATH}`);
} catch (err) {
  console.error('Error:', err.message);
  process.exit(1);
}