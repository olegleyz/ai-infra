#!/usr/bin/env python3
"""One-time conversion: extracts DATA + CONNECTIONS from index.html → topics/ai-dc.json"""

import json
import os
import re
import sys

base_dir = os.path.dirname(os.path.abspath(__file__))
html_path = os.path.join(base_dir, 'index.html')

with open(html_path, 'r', encoding='utf-8') as f:
    html = f.read()

# Extract script content
script_match = re.search(r'<script>(.*?)</script>', html, re.DOTALL)
if not script_match:
    print('No <script> found'); sys.exit(1)

script = script_match.group(1)

# Strategy: use a JS-to-Python approach
# Since the data uses JS template literals (backticks) and JS object syntax,
# we need to carefully parse it.

# Step 1: Extract CONNECTIONS (simpler - no template literals, just JSON-like array)
conn_match = re.search(r'const CONNECTIONS = (\[[\s\S]*?\n\]);', script)
if not conn_match:
    print('Could not find CONNECTIONS'); sys.exit(1)

conn_str = conn_match.group(1)
# Convert JS object syntax to JSON: unquoted keys → quoted keys
# Pattern: word followed by colon (but not inside strings)
# Remove JS comments
conn_str = re.sub(r'//[^\n]*', '', conn_str)
# Quote unquoted keys: only at start of line or after { or ,
# Use a function to avoid matching inside strings
def quote_keys_simple(s):
    """Quote JS object keys that appear right after { or , (not inside strings)."""
    result = []
    i = 0
    while i < len(s):
        ch = s[i]
        if ch == '"':
            # Skip entire string
            j = i + 1
            while j < len(s):
                if s[j] == '\\': j += 2; continue
                if s[j] == '"': break
                j += 1
            result.append(s[i:j+1])
            i = j + 1
            continue
        # Check for unquoted key: word followed by :
        if ch.isalpha() or ch == '_':
            # Look back — should be after {, comma, or whitespace after those
            prev_non_ws = ''.join(result).rstrip()
            if prev_non_ws and prev_non_ws[-1] in '{,':
                # This is likely a key
                j = i
                while j < len(s) and (s[j].isalnum() or s[j] == '_' or s[j] == '-'):
                    j += 1
                # Check if followed by :
                k = j
                while k < len(s) and s[k] in ' \t': k += 1
                if k < len(s) and s[k] == ':':
                    result.append('"' + s[i:j] + '"')
                    i = j
                    continue
        result.append(ch)
        i += 1
    return ''.join(result)

conn_json = quote_keys_simple(conn_str)
# Remove trailing commas before ] or }
conn_json = re.sub(r',\s*([}\]])', r'\1', conn_json)

try:
    CONNECTIONS = json.loads(conn_json)
    print(f'Parsed {len(CONNECTIONS)} connections')
except json.JSONDecodeError as e:
    print(f'Failed to parse CONNECTIONS: {e}')
    sys.exit(1)

# Step 2: Extract DATA tree
# This is more complex because it uses template literals (backticks) for details/narrative
# Strategy: Parse the JS object manually

# Find where DATA starts and ends
data_start = script.find('const DATA = {')
if data_start == -1:
    print('Could not find DATA'); sys.exit(1)

# Find the matching closing brace by counting braces/brackets
# But we need to handle template literals and strings
pos = script.find('{', data_start)
depth = 0
in_template = False
in_single = False
in_double = False
i = pos
while i < len(script):
    ch = script[i]

    if in_template:
        if ch == '\\':
            i += 2; continue
        if ch == '`':
            in_template = False
    elif in_single:
        if ch == '\\':
            i += 2; continue
        if ch == "'":
            in_single = False
    elif in_double:
        if ch == '\\':
            i += 2; continue
        if ch == '"':
            in_double = False
    else:
        if ch == '`':
            in_template = True
        elif ch == "'":
            in_single = True
        elif ch == '"':
            in_double = True
        elif ch == '{' or ch == '[':
            depth += 1
        elif ch == '}' or ch == ']':
            depth -= 1
            if depth == 0:
                break
    i += 1

data_str = script[pos:i+1]

# Now we need to parse this JS object.
# Convert template literals to JSON strings:
# Replace `...` with "..." but escape internal double quotes and newlines

def convert_template_literal(match):
    content = match.group(1)
    # Escape backslashes first, then double quotes, then newlines
    content = content.replace('\\', '\\\\')
    content = content.replace('"', '\\"')
    content = content.replace('\n', '\\n')
    content = content.replace('\r', '\\r')
    content = content.replace('\t', '\\t')
    return '"' + content + '"'

# Replace backtick strings with JSON strings
# Backtick strings can contain ${} expressions, but in this data they don't
result = []
i = 0
in_bt = False
bt_start = 0

while i < len(data_str):
    ch = data_str[i]
    if not in_bt:
        if ch == '`':
            in_bt = True
            bt_start = i + 1
            i += 1
            continue
        elif ch == "'":
            # Convert single-quoted strings to double-quoted
            # Find end of single-quoted string
            j = i + 1
            while j < len(data_str):
                if data_str[j] == '\\':
                    j += 2; continue
                if data_str[j] == "'":
                    break
                j += 1
            content = data_str[i+1:j]
            # Escape double quotes in content
            content = content.replace('"', '\\"')
            result.append('"' + content + '"')
            i = j + 1
            continue
        else:
            result.append(ch)
    else:
        if ch == '\\':
            i += 2
            continue
        if ch == '`':
            # End of template literal
            content = data_str[bt_start:i]
            content = content.replace('\\', '\\\\')
            content = content.replace('"', '\\"')
            content = content.replace('\n', '\\n')
            content = content.replace('\r', '\\r')
            content = content.replace('\t', '\\t')
            result.append('"' + content + '"')
            in_bt = False
    i += 1

json_str = ''.join(result)

# Now convert JS object syntax to JSON using safe key quoting
json_str = quote_keys_simple(json_str)
# Remove trailing commas
json_str = re.sub(r',\s*([}\]])', r'\1', json_str)

try:
    DATA = json.loads(json_str)
    print(f'Parsed DATA tree successfully')
except json.JSONDecodeError as e:
    # Find the error location
    line = json_str.count('\n', 0, e.pos) + 1
    col = e.pos - json_str.rfind('\n', 0, e.pos)
    context = json_str[max(0, e.pos-100):e.pos+100]
    print(f'Failed to parse DATA at line {line} col {col}: {e.msg}')
    print(f'Context: ...{context}...')
    # Write debug file
    with open(os.path.join(base_dir, 'debug_json.txt'), 'w') as f:
        f.write(json_str)
    print('Written debug_json.txt for inspection')
    sys.exit(1)

# Step 3: Flatten tree into nodes + hierarchy
nodes = {}
hierarchy = {}

def flatten_node(node):
    entry = {
        'label': node['label'],
        'icon': node['icon'],
        'category': node['category'],
        'summary': node['summary']
    }
    if 'narrative' in node and node['narrative']:
        entry['narrative'] = node['narrative']
    if 'details' in node and node['details']:
        entry['details'] = node['details']
    if 'tags' in node and node['tags']:
        entry['tags'] = node['tags']

    nodes[node['id']] = entry

    if 'children' in node and node['children']:
        hierarchy[node['id']] = [c['id'] for c in node['children']]
        for child in node['children']:
            flatten_node(child)

flatten_node(DATA)

print(f'Extracted {len(nodes)} nodes')
print(f'Hierarchy entries: {len(hierarchy)}')

# Step 4: Build topic JSON
topic_json = {
    'meta': {
        'id': 'ai-dc',
        'label': 'AI Data Centers',
        'icon': '🏗️',
        'description': 'Value chain, players, opportunities in the $300B+ AI infrastructure boom'
    },
    'nodes': nodes,
    'hierarchy': hierarchy,
    'edges': CONNECTIONS
}

# Write output
out_path = os.path.join(base_dir, 'topics', 'ai-dc.json')
with open(out_path, 'w', encoding='utf-8') as f:
    json.dump(topic_json, f, indent=2, ensure_ascii=False)

print(f'Written to {out_path}')

# Step 5: Validate
with open(out_path, 'r', encoding='utf-8') as f:
    parsed = json.load(f)

print(f'\nValidation:')
print(f'  Valid JSON: ✓')
print(f'  Nodes: {len(parsed["nodes"])}')
print(f'  Hierarchy entries: {len(parsed["hierarchy"])}')
print(f'  Edges: {len(parsed["edges"])}')
print(f'  Root exists: {"✓" if "root" in parsed["nodes"] else "✗"}')

# Check hierarchy refs
missing = 0
for parent, children in parsed['hierarchy'].items():
    if parent not in parsed['nodes']:
        print(f'  MISSING: hierarchy parent "{parent}" not in nodes')
        missing += 1
    for child_id in children:
        if child_id not in parsed['nodes']:
            print(f'  MISSING: hierarchy child "{child_id}" (parent: "{parent}") not in nodes')
            missing += 1

# Check edge refs
missing_edges = 0
for edge in parsed['edges']:
    if edge['from'] not in parsed['nodes']:
        print(f'  MISSING EDGE: from "{edge["from"]}" not in nodes')
        missing_edges += 1
    if edge['to'] not in parsed['nodes']:
        print(f'  MISSING EDGE: to "{edge["to"]}" not in nodes')
        missing_edges += 1

# Check reachability
reachable = set()
def walk(node_id):
    if node_id in reachable:
        return
    reachable.add(node_id)
    if node_id in parsed['hierarchy']:
        for child in parsed['hierarchy'][node_id]:
            walk(child)

walk('root')
unreachable = [nid for nid in parsed['nodes'] if nid not in reachable]

print(f'  Missing hierarchy refs: {missing}')
print(f'  Missing edge refs: {missing_edges}')
print(f'  Reachable from root: {len(reachable)}/{len(parsed["nodes"])}')
if unreachable:
    print(f'  UNREACHABLE nodes: {", ".join(unreachable)}')

if missing == 0 and missing_edges == 0 and not unreachable:
    print(f'\n✓ All checks passed!')
else:
    print(f'\n✗ Issues found — review above')
