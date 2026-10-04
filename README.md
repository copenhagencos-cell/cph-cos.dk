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
| `privatlivspolitik.html` / `handelsbetingelser.html` | Privacy policy, terms & cancellations |

## Changing prices, treatments or opening hours
Everything is in **`js/data.js`**. The price page and the booking calendar both read from there, so a price only needs changing in one place.
Menu and footer: `js/layout.js`. Colours and fonts: the top of `css/style.css`.

## Booking: demo now, EasyPractice when the site goes live
The calendar currently runs in **demo mode** (`booking.mode: "demo"` in `js/data.js`): it shows example free times and sends nothing.

To avoid double bookings, the live booking should go through EasyPractice / Terapeut Booking, where Nancy's real calendar is:
1. In EasyPractice: go to *Online Booking*, switch it on and copy the booking link.
2. In `js/data.js`, set `mode: "easypractice"` and `easyPracticeUrl: "<the link>"`.
The booking page then shows EasyPractice's calendar, and bookings land directly in Nancy's calendar with automatic confirmation emails.

**Note (2026-10-04):** the old link `system.easypractice.net/book/copenhagen-cosmetology` says the page "does not exist anymore",
so online booking on the current site is broken. The new link needs to be found in EasyPractice.

## Viewing the site locally
Open `index.html` in a browser, or start a small web server in the folder.
