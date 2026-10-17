# cph-cos.dk – new website for Copenhagen Cosmetology

A simple website made of plain HTML/CSS/JavaScript, with no build step. It's meant to be hosted for free on GitHub Pages
(repository: https://github.com/copenhagencos-cell/cph-cos.dk).

## Pages
| File | Page |
|---|---|
| `index.html` | Home page |
| `behandlinger.html` | Treatments & prices (generated from `js/data.js`) |
| `booking.html` | Online booking: treatment → day & time → details → confirmation |
| `om.html` | About Nancy, education, values |
| `kontakt.html` | Contact, opening hours, MobilePay, gift cards |
| `permanent-makeup.html` | Permanent makeup brows: techniques, comparison guide, prices, certificates, aftercare, FAQ |
| `faq.html` | All FAQ questions grouped by topic (from `faq` and `faqPmu` in `site.json`); the only page with FAQPage markup |
| `privatlivspolitik.html` / `handelsbetingelser.html` | Privacy policy, terms & cancellations |

## Changing prices, treatments, FAQ or the menu
1. Edit **`data/site.json`** (prices, treatments, FAQ, contact details, booking setup).
2. Run the build: `powershell -ExecutionPolicy Bypass -File tools\build.ps1`

The build writes the price list, menu, footer, FAQ and Google data **straight into the HTML pages**, so search engines and AI crawlers (ChatGPT, Perplexity…) can read them without JavaScript. It also writes `js/data.js` (for the booking calendar), `sitemap.xml`, `robots.txt`, `llms.txt` (short overview for AI assistants, llmstxt.org format) and `llms-full.txt` (the same plus every FAQ answer).
Don't edit the content between `<!-- BUILD:… -->` markers in the pages, because the build replaces it. The menu and footer templates live in `tools/build.ps1`. Colours and fonts are at the top of `css/style.css`.

## Booking: EasyPractice (Terapeut Booking)
Booking uses **EasyPractice** (decided 2026-10-12): `"mode": "easypractice"` and `"easyPracticeUrl": "https://system.easypractice.net/book/copenhagen-cosmetology"` in `data/site.json`. The booking page embeds Nancy's Terapeut Booking page, so bookings land directly in her EasyPractice calendar. Other modes: `"demo"` (example times, sends nothing) and `"calcom"` (below).

### Cal.com (set up 2026-10-12, not in use)
To switch to Cal.com instead:
1. In `data/site.json`, set `"mode": "calcom"` and `"calLink"` to the public booking link, e.g. `"copenhagen-cosmetology"` for https://cal.com/copenhagen-cosmetology. Then run the build.
2. Optional: to open a specific treatment from a "Book" button, add `"calEvent": "<event slug>"` to that service in `site.json` (the slug is the last part of the event's Cal.com link).
The booking page then shows Cal.com's calendar (official inline embed), and bookings land directly in Nancy's calendar with automatic confirmation emails.

**Never put a Cal.com API key (`cal_live_…`) in this repository.** The site is public, so anyone could read the key and control the calendar. The embed only needs the public link.


## SEO
- Every page has a title, description, canonical link and share preview in the `<!-- SEO -->` block in its `<head>`.
- `index.html` has the business data for Google (schema.org). **No street address, on purpose.**
- The old Hostinger addresses (e.g. `ansigtsbehandling-kobenhavn.html`, `priser.html`) are small forwarding pages to the new pages.
- `sitemap.xml`, `robots.txt` and `404.html` assume the site runs on https://cph-cos.dk/ (the 404 page doesn't style correctly on the github.io test address).
- Launched on cph-cos.dk 2026-10-16: `noindex` removed from all pages except `404.html`, and the `CNAME` file points GitHub Pages at cph-cos.dk.

## Viewing the site locally
Open `index.html` in a browser, or start a small web server in the folder.

## IndexNow (Bing, Yandex, Seznam, Naver)
`4bbe5bcea5e44c06a8a787200e790931.txt` in the root is the IndexNow key. Don't delete it. After publishing changes, send the changed URLs to https://api.indexnow.org/indexnow with `host=cph-cos.dk`, that key and `keyLocation=https://cph-cos.dk/4bbe5bcea5e44c06a8a787200e790931.txt`.
