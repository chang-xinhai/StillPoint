# StillPoint GitHub Pages site

Static GitHub Pages site for StillPoint. It is intentionally limited to this `site/` directory and uses only `index.html`, `styles.css`, and the copied app icon asset.

Open locally:

```bash
open site/index.html
```

Or serve it with a local HTTP server:

```bash
python3 -m http.server 4173 --directory site
```

Publishing is handled by `.github/workflows/pages.yml`, which uploads this directory to GitHub Pages on pushes to `main`.
