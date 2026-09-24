# Full Stack Lab - Ex 1 to 10 (short version)

Open any `ex*.html` in a browser. No server, no install.
`bootstrap.min.css` does all the styling, so the HTML files stay tiny.

| File | Lines | Aim |
|---|---|---|
| ex1.html | 13 | HTML5 semantic elements - **zero classes**, the tags style themselves |
| ex2.html | 19 | digits-only phone, password 8+ characters |
| ex3.html | 12 | grid - three plain divs in `.row`, colours picked by CSS |
| ex4.html | 10 | navbar that collapses into a Menu button (no JavaScript) |
| ex5.html | 9 | scrollspy (logic in `spy.js`, 11 lines) |
| ex6.html | 19 | AngularJS add (`push`) |
| ex7.html | 22 | AngularJS add + remove (`push`, `splice`) |
| ex8.html | 40 | Django Hello World app |
| ex9.html | 35 | Django HTML template with `render()` |
| ex10.html | 39 | Django Student model, SQLite data, display, and delete |

For Ex 8 on Windows, double-click `ex8-setup.bat`. It keeps the command
window open, shows only step status, and saves detailed output to
`ex8-setup.log`.

For Ex 9 on Windows, double-click `ex9-setup.bat`. It displays each command,
keeps the command window open, and saves detailed output to `ex9-setup.log`.

For Ex 10 on Windows, double-click `ex10-setup.bat`. It creates the model,
runs migrations, displays each command, keeps the command window open, and
saves detailed output to `ex10-setup.log`.

Only one class name exists in the whole lab: **`row`** (in ex3).
Everything else is a plain HTML tag.

## Two things done differently from the manual

- **Ex 4** collapses with a hidden checkbox + label in CSS. No jQuery, no `data-toggle`, no Bootstrap JS.
- **Ex 5** uses `IntersectionObserver` instead of `data-spy="scroll"`.

## Public CDN link

`bootstrap.min.css` is served free from jsDelivr once this repo is public:

```html
<link rel=stylesheet href=https://cdn.jsdelivr.net/gh/ASCrafts/bootstrap@main/bootstrap.min.css>
<script defer src=https://cdn.jsdelivr.net/gh/ASCrafts/bootstrap@main/spy.js></script>
```

Use that instead of the local filename and an `ex*.html` file works on its own,
anywhere, with nothing next to it.
