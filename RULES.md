# Content Authoring Rules

## Multilingual Content

1. **All content additions and modifications must be applied to every supported language.**
   Currently supported: English (`en`), Russian (`ru`).

2. When adding a new node, provide translations for all languages. If a translation
   is not yet available, use the English text as a placeholder for other languages —
   the `L()` accessor will fall back to English automatically and log a console warning.

3. When modifying content for one language, propagate the equivalent change to all
   other languages.

4. Translatable fields in topic JSON: `label`, `summary`, `narrative`, `details`.
   These must be objects keyed by language code: `{"en": "...", "ru": "..."}`.

5. Edge labels (`edges[].label`) are also translatable and follow the same format.

6. **`node:xxx` link targets in `details` HTML must NEVER be translated.** They are
   node IDs, not display text. Only the surrounding link text should be translated.
   Example: `<a href="node:gpu-accelerators">Ускорители GPU</a>` — the href stays English.

7. Translated `details` fields must preserve the same HTML structure (tags, nesting,
   `node:` links) as the English original. Only text content should differ.

8. Non-translatable fields (do not wrap in language objects): `id`, `icon`, `category`,
   `tags`, `hierarchy`, edge `type`/`from`/`to`.

## Adding a New Language

To add a new language (e.g., German `de`):

1. Add `{ code: 'de', label: 'DE', name: 'Deutsch' }` to the `LANGUAGES` array in `index.html`
2. Add a `de` key to `UI_STRINGS` with all UI chrome translations
3. Add `"de": "..."` to all translatable fields in all `topics/*.json` files and `topics/index.json`

No other HTML, CSS, or JS code changes required.
